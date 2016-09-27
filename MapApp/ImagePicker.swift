//
//  ImagePicker.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/3/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import UIKit

class ImagePicker: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    func configureImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
        imagePicker.sourceType = sourceType
    }
    
    func presentCameraSource(_ presenter: UIViewController) {
        presenter.present(imagePicker, animated: true, completion: nil)
    }
    
}
