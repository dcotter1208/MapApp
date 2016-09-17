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
    func dropPinAtSearchedLocation(placemark:MKPlacemark)
}

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, HandleMapSearch {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapStyleBarButton: UIBarButtonItem!
    
    private var resultSearchController:UISearchController? = nil
    private var searchedLocation:MKPlacemark? = nil
    private var locationManager: CLLocationManager?
    private var newestLocation = CLLocation()
    private var userLocation = MKCoordinateRegion()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setUpSearchControllerWithSearchTable()
        setUpSearchBar()
        getUserLocation()
        getCurrentUser()
    
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Helper Methods:
    func instantiateViewController(viewControllerIdentifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let istantiatedVC = storyboard.instantiateViewControllerWithIdentifier(viewControllerIdentifier)
        self.presentViewController(istantiatedVC, animated: true, completion: nil)
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
    
    func getUserProfileFromRealm(completion: Bool -> Void) {
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            let results = RLMDBManager().getCurrentUserFromRealm(userID)
            guard results.isEmpty == false else {
            completion(true)
            return
            }
            CurrentUser.sharedInstance.setCurrentUserWithRealm(results)
        }
    }
    
    func getUserProfileFromFirebase() {
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        let query = FirebaseOperation().firebaseDatabaseRef.ref.child("users").child("userID").queryEqualToValue(userID)
        FirebaseOperation().queryChildWithConstraints(query, firebaseDataEventType: .Value, observeSingleEventType: true) {
            (result) in
            CurrentUser.sharedInstance.setCurrentUserWithFirebase(result)
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
        let locationSearchTable = storyboard.instantiateViewControllerWithIdentifier("LocationSearchTVC") as! LocationSearchTVC
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
    func dropPinAtSearchedLocation(placemark:MKPlacemark) {
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        newestLocation = lastLocation
        userLocation = MKCoordinateRegionMakeWithDistance(newestLocation.coordinate, 800, 800)
        mapView.setRegion(userLocation, animated: true)
    }

    @IBAction func profileButtonSelected(sender: AnyObject) {
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
    
    var dataSource: [String] {
        get {
            return ["Bar", "Club", "Restaurant", "Casino", "Sports", "Parks", "Music"]
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VenueCell", forIndexPath: indexPath)
        let cellImageView = cell.viewWithTag(101) as! UIImageView
        cellImageView.layer.cornerRadius = cellImageView.frame.size.width / 2
        cellImageView.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        MKVenueSearch.searchVenuesInRegion(mapView.region, searchQueries: [.Bar]) { (venues) in
            MKVenueSearch.addVenueAnnotationsToMap(self.mapView, venues: venues)
        }
    }
    
}
