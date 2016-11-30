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
    private var lastImageTime = Date()
    private var opQueue = OperationQueue()
    private var processed = false
    private var processor: ImageProcessor!
    private var opMutex = DispatchSemaphore(value: 1)
    private var operations: Int = 0
    private var progress: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.opMutex.wait()
                let prog = self.progress
                let tot = self.operations
                self.opMutex.signal()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ReviewViewController, segue.identifier == "review" {
            controller.image = processor.outputImage
            controller.originalImage = image
        }
    }
    
    // MARK: Queue
    
    private func enqueue(_ sleep: Bool = false, _ block: @escaping () -> ())  {
        opMutex.wait()
        let op = BlockOperation {
            Synthesizer.shared.play()
            block()
            if sleep {
                Thread.sleep(forTimeInterval: 0.02)
            }
            else {
                Thread.sleep(forTimeInterval: 0.001)
            }
            Synthesizer.shared.stop()
        }
        op.completionBlock = {
            self.opMutex.wait()
            self.progress += 1
            self.opMutex.signal()
        }
        operations += 1
        opMutex.signal()
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
        
        opQueue.isSuspended = true
        
        guard let p = processor else {
            return
        }
        
        enqueue {
            p.apply(.starfield)
        }
        
        for _ in 0 ..< Int.random(within: 0...1000) {
            enqueue {
                p.apply(.sprinkle)
            }
        }
        
        for _ in 0 ..< Int.random(within: 1 ... 3) {
            enqueue(true) {
                Int.random(within: 0 ... 4) == 2 ? p.apply(.copy) : p.apply(.copyTint)
            }
        }
        
        for _ in 0 ..< Int.random(within: 1 ... 3) {
            enqueue(true) {
                p.apply(.faceMash)
            }
        }
        
        for _ in 0 ..< Int.random(within: 1 ... 3) {
            enqueue(true) {
                p.apply(.placeImage)
            }
        }
        
        opQueue.isSuspended = false
        
    }
    
    private func handleProgress(_ completed: Int, total: Int) {
        
        let percent = CGFloat(completed) / CGFloat(total)
        
        self.imageView.transform = CGAffineTransform(scaleX: 1.0 + percent, y: 1.0 + percent)
        
        colorView.backgroundColor = UIColor.neonColors.random
        
        DispatchQueue.global(qos: .background).async {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
        
        if let image = ImageDownloader.sharedInstance.getRandomImage(), Date().timeIntervalSince(lastImageTime) >= 0.25 {
            let size = image.size
            let imageView = UIImageView(image: image)
            imageView.alpha = CGFloat.random(within: 0.25...0.75)
            imageView.frame = CGRect(origin: CGPoint.zero, size: size)
            imageView.center = CGPoint.random(within: 0.0...CGFloat(view.frame.width), 0.0...CGFloat(view.frame.height))
            view.addSubview(imageView)
            lastImageTime = Date()
        }
        
        if completed == total {
            performSegue(withIdentifier: "review", sender: self)
        }
    }
    
}
