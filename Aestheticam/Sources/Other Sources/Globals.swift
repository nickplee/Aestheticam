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
    
    static let apiURL = "http://api.nicholasleedesigns.com/aesthetic.php"
    
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
    
    static var lastDownloadDate: Date {
        get {
            let defaults = UserDefaults.standard
            defaults.synchronize()
            return (defaults.object(forKey: "lastDownloadDate") as? Date) ?? Date.distantPast
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "lastDownloadDate")
            defaults.synchronize()
        }
    }
    
    static let downloadThreshold: TimeInterval = 60 * 60 * 24 * 3 // every three days
    
    static var needsDownload: Bool {
        get {
            return Date().timeIntervalSince(lastDownloadDate) >= downloadThreshold
        }
    }
    
}
