//
//  StringExtensions.swift
//  MapApp
//
//  Created by Donovan Cotter on 12/28/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation

extension String {
    func containsWhiteSpace() -> Bool {
        if self.contains(" ") {
            return true
        } else {
            return false
        }
    }
}
