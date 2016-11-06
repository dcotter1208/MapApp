//
//  MapVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//
// AIzaSyCDFhefMFtHul5d-RNCVy_1QMIasy8K78o 

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
import FirebaseAuth
import RealmSwift

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, GMSMapViewDelegate, CustomCalloutActionDelegate {
    @IBOutlet weak var mapStyleBarButton: UIBarButtonItem!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet var mapTapGesture: UITapGestureRecognizer!
    
    fileprivate var resultSearchController:UISearchController? = nil
    fileprivate var searchedLocation:MKPlacemark? = nil
    fileprivate var locationManager: CLLocationManager?
    fileprivate var newestLocation = CLLocation()
    fileprivate var userLocation: CLLocation?
    fileprivate var calloutView: CalloutView?
    fileprivate var venueIDForSelectedMarker = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGoogleMaps()
        getCurrentUser()
        setUpCalloutView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Google Maps Methods
    func setupGoogleMaps() {
        userLocation = getUserLocation()
        guard let userLocation = userLocation else { return }
        let camera = createMapCameraWithCoordinateAndZoomLevel(coordinate: userLocation.coordinate, zoom: 15.0)
        googleMapView.camera = camera
        googleMapView?.isMyLocationEnabled = true
        googleMapView.delegate = self
    }
    
    func addMapMarkerForGMSPlace(place: GMSPlace) {
        let marker = GMSMarker(position: place.coordinate)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = googleMapView
    }
    
    func addMapMarkerForVenue(venue: Venue) {
        let marker = Marker(venueID: venue.venueID!, markerPosition: venue.coordinate!.coordinate)
//        let marker = GMSMarker(position: venue.coordinate!.coordinate)
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
        }
    }
    
    func setUpCalloutView() {
        let viewRectSize = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 3)
        calloutView = CalloutView(frame: viewRectSize)
        calloutView?.delegate = self
    }
    
    
    func moreInfoButtonSelected(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let venueDetailVC = storyboard.instantiateViewController(withIdentifier: "VenueChatDisplayDetailVC") as? VenueChatDisplayDetailVC {
            venueDetailVC.venueID = venueIDForSelectedMarker
            self.navigationController?.pushViewController(venueDetailVC, animated: true)
        }
    }
    
    
    //MARK: Helper Methods:
    func instantiateViewController(_ viewControllerIdentifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let istantiatedVC = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier)
        self.present(istantiatedVC, animated: true, completion: nil)
    }
    
    func getCurrentUser() {
        guard isCurrentUserLoggedIn() else {
            FirebaseOperation().loginWithAnonymousUser()
            return
        }
        getUserProfile()
    }
    
    func getUserProfile() {
        getUserProfileFromRealm {
            (isRealmProfile) in
            guard isRealmProfile == false else { return }
            self.getUserProfileFromFirebase()
        }
    }
    
    func getUserProfileFromRealm(_ completion: (Bool) -> Void) {
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            let results = RLMDBManager().getCurrentUserFromRealm(userID)
            guard results.isEmpty == false else {
            completion(true)
            return
            }
            CurrentUser.sharedInstance.setCurrentUserWithRealm(results: results)
        }
    }
    
    func getUserProfileFromFirebase() {
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        let query = FirebaseOperation().firebaseDatabaseRef.ref.child("users").child("userID").queryEqual(toValue: userID)
        FirebaseOperation().queryChildWithConstraints(query, firebaseDataEventType: .value, observeSingleEventType: true) {
            (result) in
            CurrentUser.sharedInstance.setCurrentUserWithFirebase(snapshot: result)
        }
    }
    
    func isCurrentUserLoggedIn() -> Bool {
        guard FIRAuth.auth()?.currentUser != nil else {
            return false
        }
        return true
    }

    //MARK: Location Methods
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
        guard FIRAuth.auth()?.currentUser == nil else {
            do {
                try FIRAuth.auth()?.signOut()
            } catch {
                print(error)
            }
            return
        }
        instantiateViewController("LogInNavController")
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
    
}


//MARK: Extension For CollectionView
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
