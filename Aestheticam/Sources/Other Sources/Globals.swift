//
//  Constants.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/29/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation

struct Globals {
    
    static let apiURL = "http://api.nicholasleedesigns.com/aesthetic.php"
    
    static var lastDownloadDate: NSDate {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.synchronize()
            return (defaults.objectForKey("lastDownloadDate") as? NSDate) ?? NSDate.distantPast()
        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(newValue, forKey: "lastDownloadDate")
            defaults.synchronize()
        }
    }
    
    static let downloadThreshold: NSTimeInterval = 60 * 60 * 24 * 3 // every three days
    
    static var needsDownload: Bool {
        get {
            return NSDate().timeIntervalSinceDate(lastDownloadDate) >= downloadThreshold
        }
    }
    
}