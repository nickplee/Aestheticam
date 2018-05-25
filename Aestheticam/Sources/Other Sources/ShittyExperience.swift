//
//  ShittyExperience.swift
//  Aestheticam
//
//  Created by Nick Lee on 5/24/18.
//  Copyright © 2018 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation
import UIKit

final class ShittyExperience {
    
    // MARK: Private Properties
    
    private let application: UIApplication
    
    private weak var tempView: UIView?
    
    // MARK: Initialization
    
    init(application: UIApplication) {
        self.application = application
    }
    
    // MARK: Shit
    
    func messUpWindow() {
        resetWindow()
        
        guard let tv = application.keyWindow?.snapshotView(afterScreenUpdates: true) else {
            return
        }

        tv.isUserInteractionEnabled = false
        tv.alpha = 0
        
        application.keyWindow?.addSubview(tv)
    
        UIView.animate(withDuration: 0.1) {
            tv.transform = CGAffineTransform(rotationAngle: CGFloat.random(within: -0.15 ... 0.15)).scaledBy(x: CGFloat.random(within: 1.1 ... 5.15), y: CGFloat.random(within: 1.1 ... 5.15))
            tv.alpha = 0.95
        }
        
        tempView = tv
    }
    
    func resetWindow() {
        guard let tv = tempView else {
            return
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            tv.transform = .identity
            tv.alpha = 0
        }) { _ in
            tv.removeFromSuperview()
        }
    }
    
}
