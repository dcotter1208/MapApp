//
//  ImageCacher.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/20/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class ImageCacher {
    
    let imageCache = AutoPurgingImageCache(
        memoryCapacity: 400 * 1024 * 1024,
        preferredMemoryUsageAfterPurge: 60 * 1024 * 1024)
    
    func addImageToCache(image: Image, cacheIdentifier: String) {
        imageCache.add(image, withIdentifier: cacheIdentifier)
    }
    
    func retrieveImageFromCache(cacheIdentifier: String) -> Image? {
        if let image = imageCache.image(withIdentifier: cacheIdentifier) {
            return image
        }
        return nil
    }
    
}
