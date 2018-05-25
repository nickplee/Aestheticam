//
//  Constants.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/29/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import LLSimpleCamera

struct Globals {

    static var persistedCaptureDevice: LLCameraPosition {
        get {
            let defaults = UserDefaults.standard
            defaults.synchronize()
            if let val = defaults.object(forKey: "LLPersistedCaptureDevice") as? UInt {
                return LLCameraPosition(rawValue: val)
            }
            return LLCameraPositionRear
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue.rawValue, forKey: "LLPersistedCaptureDevice")
            defaults.synchronize()
        }
    }

}
