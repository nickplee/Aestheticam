//
//  AdManager.swift
//  Aestheticam
//
//  Created by Nick Lee on 11/30/16.
//  Copyright © 2016 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation
import RandomKit

final class AdManager {
    
    // MARK: Properties
    
    static let shared = AdManager()
    
    // MARK: Private Properties
    
    private let randomMod: Int
    private var initialLaunch = true
    private var randomNumber = 0
    
    // MARK: Initialization
    
    private init(chance: Int = 2) {
        randomMod = chance
    }
    
    // MARK: Ad State
    
    func reset() {
        initialLaunch = true
    }
    
    func adWasShown() {
        initialLaunch = false
        randomNumber = Int.random()
    }
    
    var shouldShowAd: Bool {
        return initialLaunch || (randomNumber % randomMod == 0)
    }
    
}
