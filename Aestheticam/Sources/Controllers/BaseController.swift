//
//  BaseController.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/23/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import UIKit
import ADTransitionController

class BaseController: ADTransitioningViewController {
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    private let trans = ADCubeTransition(duration: 0.5, orientation: ADTransitionRightToLeft, sourceRect: UIScreen.main.bounds)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transition = trans
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        transition = trans
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    
}
