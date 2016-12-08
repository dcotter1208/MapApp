//
//  UIImageExtension.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/16/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import UIKit

enum ImageFilter: String {
    case redSky = "CISepiaTone"
    case blackAndWhite = "CIPhotoEffectNoir"
    case effectiveness = "CIPhotoEffectProcess"
    case chromedOut = "CIPhotoEffectChrome"
    case tonal = "CIPhotoEffectTonal"
    case instant = "CIPhotoEffectInstant"
    case fade = "CIPhotoEffectFade"
    case transfer = "CIPhotoEffectTransfer"
//    case beauty = "CIColorCubeWithColorSpace"
//    case heat = "CIColorMap"
//    case feelinBlue = "CIColorMonochrome"
//    case blur = "CIGaussianBlur"
//    case cali = "CIColorClamp"
//    case bright = "CIColorMatrix"
//    case mellow = "CITemperatureAndTint"
    
}

extension UIImage {
    func resizedImage(_ newSize: CGSize) -> UIImage {
        guard self.size != newSize else { return self }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
//    func applyFilter(filterType: ImageFilter) -> UIImage? {
//        let originalImage = CIImage(image: self)
//        let filter = CIFilter(name: filterType.rawValue)
//        filter?.setDefaults()
//        filter?.setValue(originalImage, forKey: kCIInputImageKey)
//        let outputImage = filter?.outputImage
//        if let outputImage = outputImage {
//            let filteredImage = UIImage(ciImage: outputImage)
//            return filteredImage
//        }
//        return nil
//    }
//    
    func applyFilter(filterType: ImageFilter, context: CIContext?) -> UIImage? {
    guard let cgImg = self.cgImage, let coreImageContext = context else { return nil }
        
    let imageScale = self.scale
    let imageOrientation = self.imageOrientation
    let coreImage = CIImage(cgImage: cgImg)
    let filter = CIFilter(name: filterType.rawValue)
    filter?.setValue(coreImage, forKey: kCIInputImageKey)
        
    if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
    let CGImg = coreImageContext.createCGImage(output, from: output.extent)
        
    guard let CGImgResult = CGImg else { return nil }
    let result = UIImage(cgImage: CGImgResult, scale: imageScale, orientation: imageOrientation)
        
    return result
        }
        return nil
    }


}
