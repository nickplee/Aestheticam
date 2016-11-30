//
//  IntExtensions.swift
//  Aestheticam
//
//  Created by Nick Lee on 11/29/16.
//  Copyright © 2016 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation
import RandomKit

extension Int {
    static func positiveRandom() -> Int {
        return random(within: 0 ..< Int.max) ?? 0
    }
}
