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
import Obsidian_UI_iOS
import RandomKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties
    
    var window: UIWindow?
    
    // MARK: Private Properties
    
    private let navDelegate = ADNavigationControllerDelegate()
    private let player = (try! AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("chill", withExtension: "mp3")!)).then {
        $0.numberOfLoops = -1
        $0.volume = 0.1
    }
    
    // MARK: Delegate Methods

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Analytics.configure()
        
        if let nav = window?.rootViewController as? UINavigationController {
            nav.delegate = navDelegate
            nav.setNavigationBarHidden(true, animated: false)
        }
        
        ImageDownloader.sharedInstance.download()
        
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        player.play()
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        player.pause()
    }
    
}

