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

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapStyleBarButton: UIBarButtonItem!
    @IBOutlet weak var googleMapView: GMSMapView!
    
    fileprivate var resultSearchController:UISearchController? = nil
    fileprivate var searchedLocation:MKPlacemark? = nil
    fileprivate var locationManager: CLLocationManager?
    fileprivate var newestLocation = CLLocation()
    fileprivate var userLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGoogleMaps()
        getCurrentUser()
        
        
        
        Venue.getAllVenuesWithCoordinate(coordinate: userLocation!.coordinate)
        
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
    }
    
    func addMapMarkerForGMSPlace(place: GMSPlace) {
        let marker = GMSMarker(position: place.coordinate)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.title = place.name
        marker.map = googleMapView
    }
    
    func createMapCameraWithCoordinateAndZoomLevel(coordinate: CLLocationCoordinate2D, zoom: Float) -> GMSCameraPosition {
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: zoom)
        return camera
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
    var dataSource: [String] {
        get {
            return ["Bar", "Club", "Restaurant", "Casino", "Sports", "Parks", "Music"]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VenueCell", for: indexPath)
        let cellImageView = cell.viewWithTag(101) as! UIImageView
        cellImageView.layer.cornerRadius = cellImageView.frame.size.width / 2
        cellImageView.clipsToBounds = true

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //MKVenueSearch.searchVenuesInRegion(mapView.region, searchQueries: [.Pubs, .IrishPubs, .Pub, .DrinkingPubs]) { (venues) in
            //MKVenueSearch.addVenueAnnotationsToMap(self.mapView, venues: venues)
      //  }
    }
    
}
