//
//  UserType.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/10/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import UIKit

public protocol UserType {
    var name : String { get }
    var userID: String { get }
    var profileImageURL: String { get }
    var profileImage: UIImage? { get }
}
