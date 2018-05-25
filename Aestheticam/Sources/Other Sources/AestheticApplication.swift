//
//  AestheticApplication.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/23/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import UIKit

final class AestheticApplication: UIApplication {
    
    private var experience: ShittyExperience!
    
    override init() {
        super.init()
        experience = ShittyExperience(application: self) 
    }
    
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        guard let w = keyWindow else {
            return
        }
        
        if event.type == .touches, let touches = event.touches(for: w) {
            if let _ = touches.filter({ $0.phase == .began }).first {
                Synthesizer.shared.play(true)
                
                if UInt8.random(within: 0...5) == 4 {
                    experience.messUpWindow()
                }
                
                if #available(iOS 10, *) {
                    FeedbackGenerator.shared.fire()
                }
            }
            else if let _ = touches.filter({ $0.phase  == .ended || $0.phase == .cancelled }).first {
                Synthesizer.shared.stop(true)
                experience.resetWindow()
            }
        }
        
    }
    
}
