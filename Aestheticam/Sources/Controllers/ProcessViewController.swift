//
//  ProcessViewController.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/21/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import UIKit
import RandomKit
import PureLayout
import AudioToolbox

final class ProcessViewController: BaseController {
    
    // MARK: Outlets
    
    @IBOutlet weak var colorView: UIView!
    
    // MARK: Properties
    
    var image: UIImage? {
        didSet {
            reset()
        }
    }
    
    
    // MARK: Private Properties
    
    private let imageView = UIImageView()
    private var lastImageTime = NSDate()
    private var opQueue = NSOperationQueue()
    private var processed = false
    private var processor: ImageProcessor!
    private var opMutex = dispatch_semaphore_create(1)
    private var operations: Int = 0
    private var progress: Int = 0 {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                dispatch_semaphore_wait(self.opMutex, DISPATCH_TIME_FOREVER)
                let prog = self.progress
                let tot = self.operations
                dispatch_semaphore_signal(self.opMutex)
                self.handleProgress(prog, total: tot)
            }
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "shot_2")!)
        
        opQueue.maxConcurrentOperationCount = 1
        
        view.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
        imageView.image = ImageDownloader.sharedInstance.getRandomImage()
        
        process()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? ReviewViewController where segue.identifier == "review" {
            controller.image = processor.outputImage
            controller.originalImage = image
        }
    }
    
    // MARK: Queue
    
    private func enqueue(sleep: Bool = false, _ block: () -> ())  {
        dispatch_semaphore_wait(opMutex, DISPATCH_TIME_FOREVER)
        let op = NSBlockOperation {
            Synthesizer.sharedInstance.play()
            block()
            if sleep {
                NSThread.sleepForTimeInterval(0.02)
            }
            else {
                NSThread.sleepForTimeInterval(0.001)
            }
            Synthesizer.sharedInstance.stop()
        }
        op.completionBlock = {
            dispatch_semaphore_wait(self.opMutex, DISPATCH_TIME_FOREVER)
            self.progress += 1
            dispatch_semaphore_signal(self.opMutex)
        }
        operations += 1
        dispatch_semaphore_signal(opMutex)
        opQueue.addOperation(op)
    }
    
    // MARK: Processing
    
    private func reset() {
        processed = false
        guard let i = image else {
            processor = nil
            return
        }
        processor = ImageProcessor(image: i)
    }
    
    private func process() {
        
        guard !processed else {
            return
        }
        
        processed = true
        
        opQueue.suspended = true
        
        let p = processor
        
        enqueue {
            p.apply(.Starfield)
        }
        
        for _ in 0 ..< Int.random(0...1000) {
            enqueue {
                p.apply(.Sprinkle)
            }
        }
        
        for _ in 0 ..< Int.random(1 ... 3) {
            enqueue(true) {
                Int.random(0 ... 4) == 2 ? p.apply(.Copy) : p.apply(.CopyTint)
            }
        }
        
        for _ in 0 ..< Int.random(1 ... 3) {
            enqueue(true) {
                p.apply(.FaceMash)
            }
        }
        
        for _ in 0 ..< Int.random(1 ... 3) {
            enqueue(true) {
                p.apply(.PlaceImage)
            }
        }
        
        opQueue.suspended = false
        
    }
    
    private func handleProgress(completed: Int, total: Int) {
        
        let percent = CGFloat(completed) / CGFloat(total)
        
        self.imageView.transform = CGAffineTransformMakeScale(1.0 + percent, 1.0 + percent)
        
        colorView.backgroundColor = UIColor.neonColors.random
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
        
        if let image = ImageDownloader.sharedInstance.getRandomImage() where NSDate().timeIntervalSinceDate(lastImageTime) >= 0.25 {
            let size = image.size
            let imageView = UIImageView(image: image)
            imageView.alpha = CGFloat.random(0.25...0.75)
            imageView.frame = CGRect(origin: CGPoint.zero, size: size)
            imageView.center = CGPoint.random(0...CGFloat.NativeType(view.frame.width), 0...CGFloat.NativeType(view.frame.height))
            view.addSubview(imageView)
            lastImageTime = NSDate()
        }
        
        if completed == total {
            performSegueWithIdentifier("review", sender: self)
        }
    }
    
}