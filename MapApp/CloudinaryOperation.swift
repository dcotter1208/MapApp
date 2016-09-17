//
//  CloudinaryOperation.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/3/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import Cloudinary

typealias URLResult = (String) -> Void

class CloudinaryOperation: NSObject {
    
    func uploadProfileImageToCloudinary(image:UIImage, delegate: CLUploaderDelegate, completion:URLResult) {
        let resizedImage = image.resizedImage(CGSize(width: image.size.width/10, height: image.size.width/10))
        let imageData = UIImageJPEGRepresentation(resizedImage, 1.0)
        let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!)!
        let cloudinary = CLCloudinary(url: "cloudinary://\(keys["cloudinaryAPIKey"] as! String):\(keys["cloudinaryAPISecret"] as! String)@mapspot")
        let mobileUploader = CLUploader(cloudinary, delegate: delegate)
        
        mobileUploader.upload(imageData, options: nil, withCompletion: {
            (successResult, error, code, context) in
            
            guard let photoURL = successResult["secure_url"] else {
                return
            }
            
            completion(photoURL as! String)
            
        }) { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, context) in
            
        }
    }
    
}

