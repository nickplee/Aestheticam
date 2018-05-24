//
//  RandomExtensions.swift
//  Aestheticam
//
//  Created by Nick Lee on 11/29/16.
//  Copyright © 2016 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    static func positiveRandom() -> Int {
        return random(within: 0 ..< Int.max) ?? 0
    }
    
    static func random(within: ClosedRange<Int>) -> Int {
        return Int.random(in: within, using: &DeviceRandom.default)
    }
    
    static func random(within: Range<Int>) -> Int? {
        return Int.random(in: within, using: &DeviceRandom.default)
    }
}

extension UInt8 {
    static func random(within: ClosedRange<UInt8>) -> UInt8 {
        return UInt8.random(in: within, using: &DeviceRandom.default)
    }
    
    static func random(within: CountableClosedRange<UInt8>) -> UInt8 {
        return UInt8.random(in: within, using: &DeviceRandom.default)
    }
    
    static func random(within: Range<UInt8>) -> UInt8? {
        return UInt8.random(in: within, using: &DeviceRandom.default)
    }
}

extension CGFloat {
    static func random(within: ClosedRange<CGFloat>) -> CGFloat {
        return CGFloat.random(in: within, using: &DeviceRandom.default)
    }

    static func random(within: Range<CGFloat>) -> CGFloat? {
        return CGFloat.random(in: within, using: &DeviceRandom.default)
    }
}

extension Bool {
    static func random() -> Bool {
        return Bool.random(using: &DeviceRandom.default)
    }
}
