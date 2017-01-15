//
//  BoolExtensions.swift
//  MapApp
//
//  Created by Donovan Cotter on 1/15/17.
//  Copyright © 2017 DonovanCotter. All rights reserved.
//

import Foundation

extension Bool {
    func stringValue() -> String {
        switch self {
        case true:
            return "true"
        default:
            return "false"
        }
    }
}
