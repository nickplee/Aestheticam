//
//  CaptureOutput.swift
//  Aestheticam
//
//  Created by Nick Lee on 5/25/18.
//  Copyright © 2018 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation
import UIKit

enum CaptureOutput {
    case still(image: UIImage)
    case video(url: URL)
}
