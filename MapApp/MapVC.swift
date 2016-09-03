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
    }
    
    //MARK: Helper Methods:
    func istantiateViewController(viewControllerToIstantiate: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let istantiatedVC = storyboard.instantiateViewControllerWithIdentifier(viewControllerToIstantiate)
        self.presentViewController(istantiatedVC, animated: true, completion: nil)
    }
    
    //MARK: Map Methods
    
    func setupMapView() {
        guard let mapView = mapView else {return}
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        guard let manager = locationManager else {
            return
        }
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        manager.distanceFilter = 100
        manager.startUpdatingLocation()
        
        guard let managerLocation = manager.location else {
            return
        }
        newestLocation = managerLocation
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let lastLocation = locations.last else {
            return
        }
        newestLocation = lastLocation
        userLocation = MKCoordinateRegionMakeWithDistance(newestLocation.coordinate, 800, 800)
        mapView.setRegion(userLocation, animated: true)
    }

    @IBAction func profileButtonSelected(sender: AnyObject) {
        guard FIRAuth.auth()?.currentUser == nil else {return}
        istantiateViewController("LogInNavController")
    }
    
    

}
