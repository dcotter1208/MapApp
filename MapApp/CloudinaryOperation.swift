//
//  CloudinaryOperation.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/3/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import Cloudinary

class CloudinaryOperation: NSObject, CLUploaderDelegate {
    
    func uploadProfileImageToCloudinary(image:UIImage, completion:(photoURL: String)-> Void) {
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!)!
        let cloudinary = CLCloudinary(url: "cloudinary://\(keys["cloudinaryAPIKey"] as! String):\(keys["cloudinaryAPISecret"] as! String)@mapspot")
        let mobileUploader = CLUploader(cloudinary, delegate: self)
        mobileUploader.delegate = self
        
        mobileUploader.upload(imageData, options: nil, withCompletion: {
            (successResult, error, code, context) in
            
            guard let photoURL = successResult["secure_url"] else {
                return
            }
            
            completion(photoURL: photoURL as! String)
            
        }) { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, context) in
            
        }
    }
    
}

