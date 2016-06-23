//
//  Analytics.swift
//  Aestheticam
//
//  Created by Nick Lee on 6/23/16.
//  Copyright © 2016 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation
import FirebaseAnalytics

func LogEvent(name: String, _ parameters: [String : NSObject]? = nil) {
    FIRAnalytics.logEventWithName(name, parameters: parameters)
}