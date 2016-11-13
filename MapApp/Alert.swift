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
    
   class func presentMediaActionSheet(presentingViewController: UIViewController, imagePicker: UIImagePickerController) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
        let camera = UIAlertAction(title: "Camera", style: .default) { handler -> Void in
            imagePicker.sourceType = .camera
            presentingViewController.present(imagePicker, animated: true, completion: nil)
        }
        let mediaLibrary = UIAlertAction(title: "Choose from gallery", style: .default) { handler -> Void in
            imagePicker.sourceType = .photoLibrary
            presentingViewController.present(imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { handler -> Void in
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    
        actionSheet.addAction(camera)
        actionSheet.addAction(mediaLibrary)
        actionSheet.addAction(cancel)
        presentingViewController.present(actionSheet, animated: true, completion: nil)
    }
    
}
