//
//  Colors.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/23/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import UIKit

private let _neonColors = [
    UIColor(red:0.40, green:0.39, blue:1.00, alpha:1.00),
    UIColor(red:0.40, green:0.40, blue:0.99, alpha:1.00),
    UIColor(red:0.00, green:0.80, blue:1.00, alpha:1.00),
    UIColor(red:0.21, green:0.81, blue:0.20, alpha:1.00),
    UIColor(red:1.00, green:1.00, blue:0.02, alpha:1.00),
    UIColor(red:1.00, green:0.40, blue:0.01, alpha:1.00),
    UIColor(red:0.98, green:0.00, blue:0.00, alpha:1.00),
    UIColor(red:0.59, green:0.00, blue:0.60, alpha:1.00),
    UIColor(red:0.61, green:0.00, blue:0.78, alpha:1.00),
    UIColor(red:0.79, green:0.20, blue:0.60, alpha:1.00)
]

extension UIColor {
    class var neonColors: [UIColor] {
        return _neonColors // static let was causing compilation failure
    }
}