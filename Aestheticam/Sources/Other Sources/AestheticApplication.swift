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
    
    override func sendEvent(event: UIEvent) {
        super.sendEvent(event)
        
        guard let w = keyWindow else {
            return
        }
        
        if event.type == .Touches, let touches = event.touchesForWindow(w) {
            if let _ = touches.filter({ $0.phase == .Began }).first {
                Synthesizer.sharedInstance.play(true)
            }
            else if let _ = touches.filter({ $0.phase  == .Ended || $0.phase == .Cancelled }).first {
                Synthesizer.sharedInstance.stop(true)
            }
        }
        
    }
    
}