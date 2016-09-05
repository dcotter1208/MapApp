//
//  AlamoFireOperation.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

typealias NetworkResult = (UIImage?, ErrorType?) -> Void

class AlamoFireOperation {
        
   class func downloadProfileImageWithAlamoFire(URL: String, completion: NetworkResult) {
        Alamofire.request(.GET, URL)
            .responseImage { response in
                guard let image = response.result.value else {
                    if let error = response.result.error {
                        completion(nil, error)
                    }
                    return
                }
                completion(image, nil)
        }
    }
    
}

