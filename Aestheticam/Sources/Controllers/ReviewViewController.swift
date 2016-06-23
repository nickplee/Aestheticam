//
//  ReviewViewController.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/23/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import UIKit

final class ReviewViewController: BaseController {
    
    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Properties
    
    var image: UIImage?
    var originalImage: UIImage?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        Synthesizer.sharedInstance.playAesthetic()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? ProcessViewController where segue.identifier == "process" {
            dest.image = originalImage
            image = nil
        }
    }
    
    // MARK: Shaking
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            performSegueWithIdentifier("process", sender: self)
            LogEvent("shake_reprocess")
        }
    }
    
    // MARK: Actions
    
    @IBAction private func share(sender: AnyObject?) {
        guard let img = image else {
            return
        }
        
        let text = "I created my A E S T H E T I C with #aestheticam"
        
        let controller = UIActivityViewController(activityItems: [text, img], applicationActivities: nil)
        
        controller.completionWithItemsHandler = { (activity, success, items, error) -> Void in
            
            guard error == nil else {
                return
            }
            
            var params: [String : NSObject] = [
                "success" : success
            ]
            
            if let a = activity {
                params["activity"] = a
            }
            
            LogEvent("share", params)
            
        }
        
        presentViewController(controller, animated: true) {
            LogEvent("began_share")
        }
    }
    
}