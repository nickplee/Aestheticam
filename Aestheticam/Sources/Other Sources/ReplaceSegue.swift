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
        guard let nav = source.navigationController else {
            return
        }
        
        let animated = UIView.areAnimationsEnabled
        
        var controllers = nav.viewControllers
        
        if let idx = controllers.index(of: source) {
            controllers[idx] = destination
        }
        else {
            controllers.append(destination)
        }
        
        nav.setViewControllers(controllers, animated: animated)
    }
    
}
