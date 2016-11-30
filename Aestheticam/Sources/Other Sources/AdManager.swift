//
//  AdManager.swift
//  Aestheticam
//
//  Created by Nick Lee on 11/30/16.
//  Copyright © 2016 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation
import RandomKit
import GoogleMobileAds

final class AdManager {
    
    // MARK: Types
    
    enum ID: String {
        case AfterCapture = "ProcessingResult"
    }
    
    // MARK: Properties
    
    static let shared = AdManager()
    
    // MARK: Private Properties
    
    private let randomMod: Int
    private var initialLaunch = true
    private var randomNumber = 0
    private var googleAdUnitIDs: [String : String] = [:]
    
    // MARK: Initialization
    
    private init(chance: Int = 2) {
        randomMod = chance
        loadPlist()
    }
    
    private func loadPlist() {
        guard let url = Bundle.main.url(forResource: "Ads", withExtension: "plist") else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        guard let plist = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String : AnyObject] else { return }
        
        if let googleAds = plist["GoogleAdIDs"] as? [String : String] {
            googleAdUnitIDs = googleAds
        }
    }
    
    // MARK: Ad IDs
    
    private func get(id: ID) -> String? {
        return googleAdUnitIDs[id.rawValue]
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
    
    // MARK: UI
    
    func createInterstitial(with id: ID) -> GADInterstitial? {
        guard let id = AdManager.shared.get(id: .AfterCapture) else {
            return nil
        }
        let interstitial = GADInterstitial(adUnitID: id)
        let request = GADRequest()
        defer { interstitial.load(request) }
        return interstitial
    }
    
}
