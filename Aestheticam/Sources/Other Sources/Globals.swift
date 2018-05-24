//
//  Constants.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/29/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import FastttCamera

struct Globals {

    static var persistedCaptureDevice: FastttCameraDevice {
        get {
            let defaults = UserDefaults.standard
            defaults.synchronize()
            guard let val = defaults.object(forKey: "persistedCaptureDevice") as? Int, let position = FastttCameraDevice(rawValue: val) else {
                return .rear
            }
            return position
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue.rawValue, forKey: "persistedCaptureDevice")
            defaults.synchronize()
        }
    }

}
