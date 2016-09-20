//
//  MapVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import RealmSwift

protocol HandleMapSearch: class {
    func dropPinAtSearchedLocation(_ placemark:MKPlacemark)
}

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, HandleMapSearch {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapStyleBarButton: UIBarButtonItem!
    
    fileprivate var resultSearchController:UISearchController? = nil
    fileprivate var searchedLocation:MKPlacemark? = nil
    fileprivate var locationManager: CLLocationManager?
    fileprivate var newestLocation = CLLocation()
    fileprivate var userLocation = MKCoordinateRegion()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setUpSearchControllerWithSearchTable()
        setUpSearchBar()
        getUserLocation()
        getCurrentUser()
        
        print("NAAAAMMMMEEEE \(CurrentUser.sharedInstance.name)")
        print(Realm.Configuration.defaultConfiguration)
    
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        print("trying to get profile from firebase")
        
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        let query = FirebaseOperation().firebaseDatabaseRef.ref.child("users").child("userID").queryEqual(toValue: userID)
        FirebaseOperation().queryChildWithConstraints(query, firebaseDataEventType: .value, observeSingleEventType: true) {
            (result) in
            
            print("Firebase")
            
            CurrentUser.sharedInstance.setCurrentUserWithFirebase(snapshot: result)
        }
    }
    
    func isCurrentUserLoggedIn() -> Bool {
        guard FIRAuth.auth()?.currentUser != nil else {
            return false
        }
        return true
    }
    
    //MARK: Map Methods
    
    func setupMapView() {
        guard let mapView = mapView else { return }
        mapView.delegate = self
        mapView.showsPointsOfInterest = false
        mapView.showsUserLocation = true
    }
    
    func adjustMapViewCamera() {
        let newCamera = mapView.camera
        guard mapView.camera.pitch < 30.0 else {
            newCamera.pitch = mapView.camera.pitch
            return
        }
        newCamera.pitch = 30
        self.mapView.camera = newCamera
    }

    //Creates SearchController
    func setUpSearchControllerWithSearchTable()  {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let locationSearchTable = storyboard.instantiateViewController(withIdentifier: "LocationSearchTVC") as! LocationSearchTVC
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
    }
    
    //Configures the Search Bar
    func setUpSearchBar() {
        let searchBar = resultSearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search For Places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    //This drops the pin at the searched location when using the search bar.
    func dropPinAtSearchedLocation(_ placemark:MKPlacemark) {
        searchedLocation = placemark
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    //MARK: Location Methods
    func getUserLocation() {
        locationManager = CLLocationManager()
        guard let manager = locationManager else { return }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        manager.distanceFilter = 100
        manager.startUpdatingLocation()
        guard let managerLocation = manager.location else { return }
        newestLocation = managerLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        newestLocation = lastLocation
        userLocation = MKCoordinateRegionMakeWithDistance(newestLocation.coordinate, 800, 800)
        mapView.setRegion(userLocation, animated: true)
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
    
}


//MARK: Extension For CollectionView
extension MapVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        MKVenueSearch.searchVenuesInRegion(mapView.region, searchQueries: [.Bar, .Drinks, .DanceClub, .DiveBar, .Brewery, .SportsBar]) { (venues) in
            MKVenueSearch.addVenueAnnotationsToMap(self.mapView, venues: venues)
            print(venues.count)
        }
    }
    
}
