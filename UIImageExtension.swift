//
//  UIImageExtension.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/16/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resizedImage(newSize: CGSize) -> UIImage {
        guard self.size != newSize else { return self }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}