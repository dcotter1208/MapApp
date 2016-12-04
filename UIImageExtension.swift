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
    case colorSwap = "CIColorCrossPolynomial"
    case beauty = "CIColorCubeWithColorSpace"
    case blackAndWhite = "CIPhotoEffectNoir"
    case effectiveness = "CIPhotoEffectProcess"
    case chromedOut = "CIPhotoEffectChrome"
    case heat = "CIColorMap"
    case feelinBlue = "CIColorMonochrome"
    case blur = "CIGaussianBlur"
    case cali = "CIColorClamp"
    case bright = "CIColorMatrix"
    case mellow = "CITemperatureAndTint"
    
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
    
    func applyFilter(filterType: ImageFilter) -> UIImage? {
        let originalImage = CIImage(image: self)
        let filter = CIFilter(name: filterType.rawValue)
        filter?.setDefaults()
        filter?.setValue(originalImage, forKey: kCIInputImageKey)
        let outputImage = filter?.outputImage
        if let outputImage = outputImage {
            let filteredImage = UIImage(ciImage: outputImage)
            return filteredImage
        }
        return nil
    }
    
}
