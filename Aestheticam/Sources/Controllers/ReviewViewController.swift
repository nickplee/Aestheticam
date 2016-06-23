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
        }
    }
    
    // MARK: Actions
    
    @IBAction private func share(sender: AnyObject?) {
        guard let img = image else {
            return
        }
        let controller = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        presentViewController(controller, animated: true, completion: nil)
    }
    
}