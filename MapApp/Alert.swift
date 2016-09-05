//
//  Alert.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/4/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    
    func displayGenericAlert(title: String, message: String, presentingViewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        presentingViewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
}