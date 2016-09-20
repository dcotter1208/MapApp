//
//  LocationSearchTVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTVC: UITableViewController, UISearchResultsUpdating {
    weak var handleMapSearchDelegate: HandleMapSearch?
   fileprivate var searchResults = [MKMapItem]()
   var mapView:MKMapView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func parseAddress(_ mapItem: MKPlacemark) -> String {
        var fullAddress = String()
        let addressDict = mapItem.addressDictionary
        if let address = addressDict {
            if let street = address["Street"], let city = address["City"], let state = address["State"], let countryCode = address["CountryCode"] {
                fullAddress = "\(street), \(city), \(state), \(countryCode)"
            }
        }
        return fullAddress
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let map = mapView {
            let searchBarText = searchController.searchBar.text
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = searchBarText
            request.region = map.region
            let search = MKLocalSearch(request: request)
            search.start{
                (response, error) in
                if let response = response {
                    self.searchResults = response.mapItems
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let mapItem = searchResults[(indexPath as NSIndexPath).item]
        cell.textLabel?.text = mapItem.name
        cell.detailTextLabel?.text = parseAddress(mapItem.placemark)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchedLocation = searchResults[(indexPath as NSIndexPath).row].placemark
        handleMapSearchDelegate?.dropPinAtSearchedLocation(searchedLocation)
        dismiss(animated: true, completion: nil)
    }
    
    
}
