//
//  LocationManagement.swift
//  MapApp
//
//  Created by Donovan Cotter on 1/10/17.
//  Copyright © 2017 DonovanCotter. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {

    fileprivate var newestLocation = CLLocation()
    fileprivate var userLocation = CLLocation()
    
    func getUserLocation() -> CLLocation? {
        let manager = CLLocationManager()
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
    }
    
}
