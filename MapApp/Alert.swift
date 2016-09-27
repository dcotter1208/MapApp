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
    
    func displayGenericAlert(_ title: String, message: String, presentingViewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        presentingViewController.present(alertController, animated: true, completion: nil)
    }
    
}
