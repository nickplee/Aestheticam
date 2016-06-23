//
//  Analytics.swift
//  Aestheticam
//
//  Created by Nick Lee on 6/23/16.
//  Copyright © 2016 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import Try

struct Analytics {
    
    private static var configured = false
    
    private static func safe(closure: Void -> Void) {
        do {
            try trap(closure)
        }
        catch {}
    }
    
    static func configure() {
        safe {
            FIRApp.configure()
            self.configured = true
        }
    }
    
    static func logEvent(name: String, _ parameters: [String : NSObject]? = nil) {
        guard configured else {
            return
        }
        safe {
            FIRAnalytics.logEventWithName(name, parameters: parameters)
        }
    }
    
}

func LogEvent(name: String, _ parameters: [String : NSObject]? = nil) {
    Analytics.logEvent(name, parameters)
}
