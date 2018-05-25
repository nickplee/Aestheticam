//
//  AppDelegate.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/21/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import UIKit
import ADTransitionController
import AVFoundation
import Then

final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties
    
    var window: UIWindow?
    
    // MARK: Private Properties
    
    private let navDelegate = ADNavigationControllerDelegate()
    
    private let player = (try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "chill", withExtension: "mp3")!)).then {
        $0.numberOfLoops = -1
        $0.volume = 0.1
    }

    // MARK: Delegate Methods

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FileManager.default.purgeTempDir()
        
        Analytics.configure()
        
        if let nav = window?.rootViewController as? UINavigationController {
            nav.delegate = navDelegate
            nav.setNavigationBarHidden(true, animated: false)
        }
        
        ImageDownloader.sharedInstance.refreshImages()
        
        if #available(iOS 10.0, *) {
            FeedbackGenerator.shared.start()
        }
        
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Synthesizer.shared.startEngine()
        player.play()
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        player.pause()
    }
    
}

