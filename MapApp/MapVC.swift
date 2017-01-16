//
//  MapVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//
// AIzaSyCDFhefMFtHul5d-RNCVy_1QMIasy8K78o 

import UIKit
import Cloudinary
import MapKit
import GoogleMaps
import GooglePlaces
import FirebaseAuth
import RealmSwift
import Alamofire

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GMSMapViewDelegate, CustomCalloutActionDelegate {
    
    //MARK: **IBOutlets**
    @IBOutlet weak var mapStyleBarButton: UIBarButtonItem!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet var mapTapGesture: UITapGestureRecognizer!
    
    typealias isUsernameUniqueHandler = (Bool) -> Void
    
    //MARK: **Private properties**
    
    fileprivate var resultSearchController:UISearchController? = nil
    fileprivate var searchedLocation:MKPlacemark? = nil
    fileprivate var locationManager: CLLocationManager?
    fileprivate var newestLocation = CLLocation()
    fileprivate var userLocation: CLLocation?
    fileprivate var calloutView: CalloutView?
    fileprivate var signUpView: SignUpView?
    fileprivate var venueIDForSelectedMarker = ""
    fileprivate var rlmDBManager = RLMDBManager()
    fileprivate let keyboardAnimationDuration = 0.25
    fileprivate var updateProfile = false
    fileprivate var profileImageChanged = false
    fileprivate var profileImage: UIImage?
    fileprivate var imageSourceType = UIImagePickerControllerSourceType.camera
    fileprivate let imagePicker = ImagePicker()
    
    //MARK: **Life Cycle**
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CurrentUser.sharedInstance.resetProperties()
        setUpCalloutView()
        setupGoogleMaps()

        setUpKeyboardNotification()

        if !currentUserExists() {
            setUpSignUpView()
        }
        
        let results = RLMDBManager().getRealmObjects(objectType: RLMVenuePhoto.self)
        print("\(results)")
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        profileImageChanged = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: **Google Maps Methods**
    func setupGoogleMaps() {
        googleMapView?.isMyLocationEnabled = true
        googleMapView.delegate = self
        userLocation = getUserLocation()
        guard let userLocation = userLocation else { return }
        let camera = createMapCameraWithCoordinateAndZoomLevel(coordinate: userLocation.coordinate, zoom: 15.0)
        googleMapView.camera = camera
    }
    
    func addMapMarkerForGMSPlace(place: GMSPlace) {
        let marker = GMSMarker(position: place.coordinate)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = googleMapView
    }
    
    func addMapMarkerForVenue(venue: Venue) {
        let marker = Marker(venueID: venue.venueID!, markerPosition: venue.coordinate!.coordinate)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.title = venue.name
        marker.map = googleMapView
    }
    
    func createMapCameraWithCoordinateAndZoomLevel(coordinate: CLLocationCoordinate2D, zoom: Float) -> GMSCameraPosition {
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: zoom)
        return camera
    }
    
    func getMapCenterCoordinate() -> CLLocationCoordinate2D {
        return googleMapView.projection.coordinate(for: googleMapView.center)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        DispatchQueue.main.async {
            if let calloutView = self.calloutView {
                self.view.addSubview(calloutView)
                
                //Set up a function that sets the callout view's properties by passing in a dict.
                let customMarker = marker as! Marker
               self.venueIDForSelectedMarker = customMarker.venueID
                calloutView.nameLabel.text = customMarker.title
                self.navigationController?.navigationBar.isHidden = true
            }
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async {
            if let calloutView = self.calloutView {
                calloutView.removeFromSuperview()
                self.navigationController?.navigationBar.isHidden = false
            }
            if let signUpView = self.signUpView {
                signUpView.removeFromSuperview()
            }
        }
    }
    
    func setUpCalloutView() {
        let viewRectSize = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 3)
        calloutView = CalloutView(frame: viewRectSize)
        calloutView?.delegate = self
    }
    
    
    func moreInfoButtonSelected(sender: AnyObject) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let venueDetailVC = storyboard.instantiateViewController(withIdentifier: "VenueChatDisplayDetailVC") as? VenueChatDisplayDetailVC {
//            venueDetailVC.venueID = venueIDForSelectedMarker
//            self.navigationController?.pushViewController(venueDetailVC, animated: true)
//        }
    }
    
    //IF THIS IS THE BOT CHAT THEN SET IT THERE.
    func enterChatSelected(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let venueChatVC = storyboard.instantiateViewController(withIdentifier: "VenueChatViewController") as? ChatVC {
            venueChatVC.venueID = venueIDForSelectedMarker
            self.navigationController?.pushViewController(venueChatVC, animated: true)
        }
    }
 
    func getUserProfileFromRealm(_ completion: (Bool) -> Void) {
            rlmDBManager.getCurrentUserProfileFromRealm()
    }
    
    func getUserProfileFromFirebase() {
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        let query = FirebaseOperation().firebaseDatabaseRef.ref.child("users").child("userID").queryEqual(toValue: userID)
        FirebaseOperation().queryChildWithConstraints(query, firebaseDataEventType: .value, observeSingleEventType: true) {
            (result) in
            CurrentUser.sharedInstance.setCurrentUserWithFirebase(snapshot: result)
        }
    }

    //MARK: **Location Methods**
    func getUserLocation() -> CLLocation? {
        locationManager = CLLocationManager()
        guard let manager = locationManager else { return nil }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        manager.distanceFilter = 100
        manager.startUpdatingLocation()
        guard let managerLocation = manager.location else { return nil }
        newestLocation = managerLocation
        return newestLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        newestLocation = lastLocation
        userLocation = newestLocation
        guard let userLocation = userLocation else { return }
        googleMapView?.camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 15.0)
    }
    
    @IBAction func myLocationButtonSelected(_ sender: AnyObject) {
        guard let userLocationCoordinates = googleMapView.myLocation?.coordinate else { return }
        let camera = createMapCameraWithCoordinateAndZoomLevel(coordinate: userLocationCoordinates, zoom: 15.0)
        googleMapView.camera = camera
    }

    @IBAction func profileButtonSelected(_ sender: AnyObject) {
        if CurrentUser.sharedInstance.userID != "" {
            profileImageChanged = false
            setUpSignUpView()
            configureSignUpViewWithCurrentUserInfo()
            updateProfile = true
        }
    }
    
    @IBAction func searchForPlaces(_ sender: AnyObject) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func mapTapGestureSelected(_ sender: UITapGestureRecognizer) {
        print("Sender&& \(sender)")
        if sender.state == .began {
            print("SENDER**: \(sender)")
        }
    }
    func presentImageEditorVC() {
        self.performSegue(withIdentifier: "showImageEditorVC", sender: self)
    }

    func currentUserExists() -> Bool {
        rlmDBManager.getCurrentUserProfileFromRealm()
        if CurrentUser.sharedInstance.userID != "" {
            return true
        } else {
            return false
        }
    }
}

//MARK: **SignUpViewDelegate Extension**

extension MapVC: SignUpViewDelegate, CLUploaderDelegate {
    func setUpSignUpView() {
        let viewRectSize = CGRect(x: 5, y: self.view.frame.maxY / 3, width: self.view.frame.size.width - 10, height: self.view.frame.size.height / 3)
        signUpView = SignUpView(frame: viewRectSize)
        if let safeSignUpView = signUpView {
            safeSignUpView.delegate = self
            self.view.addSubview(safeSignUpView)
            disableMapView()
        }
    }
    
    func configureSignUpViewWithCurrentUserInfo() {
        self.signUpView?.usernameTextField.text = CurrentUser.sharedInstance.username
        guard let profileImage = CurrentUser.sharedInstance.profileImage else {
            signUpView?.profileImageView.image = #imageLiteral(resourceName: "default_user")
            return
        }
        self.signUpView?.profileImageView.image = profileImage
    }
    
    func disableMapView() {
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    
    func photoSelected(sender: Any) {
        presentImageEditorVC()
    }
    
    func createProfile(sender: Any) {
        guard let username = signUpView?.usernameTextField.text else { return }
        
        guard username.containsWhiteSpace() == false else {
            Alert().displayGenericAlert("No White Spaces Allowed", message: "Please choose another name.", presentingViewController: self)
            return
        }
        guard username.characters.count >= 6 && username.characters.count <= 15 else {
            Alert().displayGenericAlert("Whoops! Username is only \(username.characters.count) characters long.", message: "It needs to be 6-15 characters long.", presentingViewController: self)
            return
        }
        
        if let username = signUpView?.usernameTextField.text?.lowercased().replacingOccurrences(of: " ", with: "") {
        isUsernameUnique(username: username, completion: { (isUnique) in
            if isUnique {
                //Generates a UserID
                let userID = self.generateUserID()
                //Creates a user profile
                var newUserProfile: [String: AnyObject] = ["username" : username as String as AnyObject, "userID" : userID as AnyObject, "profileImageURL": "" as AnyObject]
                if self.signUpView?.profileImageView.image != #imageLiteral(resourceName: "default_user") {
                    if self.profileImageChanged == true {
                        if let profileImage = self.profileImage {
                            CloudinaryOperation().uploadImageToCloudinary(profileImage, delegate: self, completion: { (url) in
                                newUserProfile["profileImageURL"] = url as AnyObject
                                newUserProfile.updateValue(profileImage as AnyObject, forKey: "profileImage")
//                                newUserProfile.updateValue(CurrentUser.sharedInstance.botID as AnyObject, forKey: "botID")

                                self.addOrUpdateUserProfile(userProfile: newUserProfile)
                                self.signUpView?.removeFromSuperview()
                            })
                        }
                    } else {
                        newUserProfile.updateValue(CurrentUser.sharedInstance.profileImage as AnyObject, forKey: "profileImage")
                        newUserProfile.updateValue(CurrentUser.sharedInstance.profileImageURL as AnyObject, forKey: "profileImageURL")
                        newUserProfile.updateValue(CurrentUser.sharedInstance.botID as AnyObject, forKey: "botID")

                        self.addOrUpdateUserProfile(userProfile: newUserProfile)
                        self.signUpView?.removeFromSuperview()
                    }
                } else {
                    self.addOrUpdateUserProfile(userProfile: newUserProfile)
                    self.signUpView?.removeFromSuperview()
                }
            } else {
                Alert().displayGenericAlert("Username Taken", message: "Please try a different one", presentingViewController: self)
            }
        })
    }
}
    
    func isUsernameUnique(username: String, completion: @escaping isUsernameUniqueHandler) {
        FirebaseOperation().validateFirebaseChildUniqueness(child: "users", queryOrderedBy: "username", equaledTo: username) { (isUnique) in
            if isUnique == true || CurrentUser.sharedInstance.username == username {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func addOrUpdateUserProfile(userProfile: [String : AnyObject]) {
        FirebaseOperation().addOrUpdateUserProfile(userProfile: userProfile) {
                (snapshotKey, botID) in
            var newUserProfileWithSnapshotKey = userProfile
            newUserProfileWithSnapshotKey.updateValue(snapshotKey as AnyObject, forKey: "snapshotKey")
            newUserProfileWithSnapshotKey.updateValue(botID as AnyObject, forKey: "botID")
            let rlmUser = RLMUser().createUser(userProfile: newUserProfileWithSnapshotKey)
            RLMDBManager().updateUserProfile(rlmUser!)
            }
    }
    
    func updateProfileInFirebase(userProfile: [String : String]) {
        if let snapshotKey = userProfile["snapshotKey"] {
        FirebaseOperation().updateChildValue(child: "users", childKey: snapshotKey, nodeToUpdate: userProfile as [String : AnyObject])
        }
    }
    
    func generateUserID() -> String {
        if CurrentUser.sharedInstance.userID != "" {
            return CurrentUser.sharedInstance.userID
        } else {
            return UUID().uuidString
        }
    }

    //SignUpView+Keyboard Animation Helper Methods
    func setUpKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        var newYPosition: CGFloat?
        if let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height {
            newYPosition = self.view.frame.minY + navigationBarHeight + 50
        }
        UIView.animate(withDuration: keyboardAnimationDuration, delay: 0.0, options: [.curveEaseIn], animations: {
            if let yPosition = newYPosition {
                self.signUpView?.frame.origin.y = yPosition
            }
        }, completion: nil)
    }
    
    func keyboardWillHideNotification() {
        let originalYPosition = self.view.frame.maxY / 3
        UIView.animate(withDuration: keyboardAnimationDuration, delay: 0.0, options: [.curveEaseIn], animations: {
            self.signUpView?.frame.origin.y = originalYPosition
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageEditorVC" {
            if let imageEditorVC = segue.destination as? ImageEditorVC {
                imageEditorVC.imageSourceType = imageSourceType
            }
        }
    }
    
    @IBAction func unwindToMapVC(segue: UIStoryboardSegue) {
        if segue.source.isKind(of: ImageEditorVC.self) {
            if let imageEditorVC = segue.source as? ImageEditorVC {
                let croppedImage = imageEditorVC.croppedImage
                self.signUpView?.profileImageView.image = croppedImage
                profileImageChanged = true
                profileImage = croppedImage
            }
        }
    }

}

//MARK: **Extension For CollectionView**
extension MapVC: UICollectionViewDataSource, UICollectionViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let newCamera = createMapCameraWithCoordinateAndZoomLevel(coordinate: place.coordinate, zoom: 15.0)
        googleMapView.camera = newCamera
        addMapMarkerForGMSPlace(place: place)
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Swift.Error) {
        // TODO: handle the error.
        print("Error: \(error.localizedDescription)")
    }

    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    
    //This will be replaced with however many categories we end up having for the filter option.
    var categories: [GooglePlacesCategoryType] {
        get {
            return [.Bar, .Casino, .Stadium, .Restaurant, .Park, .University, .Lodging, .ShoppingMall]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let category = categories[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VenueCell", for: indexPath)
        
        let cellLabel = cell.viewWithTag(101) as! UILabel
        let categoryParams = createSearchParamters(categoryType: category)
        cellLabel.text = categoryParams.type
        cell.layer.cornerRadius = cell.frame.size.width / 2
        
//        let cellImageView = cell.viewWithTag(101) as! UIImageView
//        cellImageView.layer.cornerRadius = cellImageView.frame.size.width / 2
//        cellImageView.clipsToBounds = true

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firebaseOperation = FirebaseOperation()
        let selectedCategory = categories[indexPath.item]
        let searchParams = createSearchParamters(categoryType: selectedCategory)
        
        Venue.getAllVenuesWithCoordinate(categoryType: selectedCategory, searchText: searchParams.searchText, keyword: searchParams.keyword, coordinate: getMapCenterCoordinate(), searchType: .NearbySearch) { (allVenues, error) in
            guard error == nil else { return }
            for venue in allVenues! {
                self.addMapMarkerForVenue(venue: venue)
                let firebaseVenue = ["name" : venue.name!, "latitude" : "\(venue.coordinate!.coordinate.latitude)", "longitude" : "\(venue.coordinate!.coordinate.longitude)", "venueID": venue.venueID!, "chatID": ""]
                
                firebaseOperation.validateVenueUniqueness(venue, completion: { (isUnique) in
                    if isUnique == true {
                        firebaseOperation.setValueForChild(child: "venues", value: firebaseVenue)
                    } else {
                    }
                })
            }
        }
    }

    private func createSearchParamters(categoryType: GooglePlacesCategoryType) -> (type: String, searchText: String, keyword: String) {
        switch categoryType {
        case .Bar:
            return ("Bars", "bars", "drinks")
        case .Casino:
            return ("Casinos", "casino", "casino")
        case .Stadium:
            return ("Sports", "sports", "sports")
        case .Restaurant:
            return ("Restaurants", "restaurants", "food")
        case .Park:
            return ("Parks", "parks", "outdoors")
        case .University:
            return ("Universities", "college", "education")
        case .Lodging:
            return ("Hotels", "hotels+resorts", "lodging")
        case .ShoppingMall:
            return ("Shopping", "shopping+malls", "shopping")
        default:
            return ("Place", "place", "place")
        }
    }
    
}
