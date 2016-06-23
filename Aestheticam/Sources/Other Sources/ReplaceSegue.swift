//
//  ReplaceSegue.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/23/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import UIKit

final class ReplaceSegue: UIStoryboardSegue {
    
    override func perform() {
        guard let nav = sourceViewController.navigationController else {
            return
        }
        
        let animated = UIView.areAnimationsEnabled()
        
        var controllers = nav.viewControllers
        
        if let idx = controllers.indexOf(sourceViewController) {
            controllers[idx] = destinationViewController
        }
        else {
            controllers.append(destinationViewController)
        }
        
        nav.setViewControllers(controllers, animated: animated)
    }
    
}