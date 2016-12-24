//
//  UIImageView+Alamofire.swift
//  MapApp
//
//  Created by Donovan Cotter on 12/23/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

extension UIImageView {
    func downloadAFImage(url: URL) {
        self.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholder"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .noTransition, runImageTransitionIfCached: false, completion: { (data) in })
    }
}
