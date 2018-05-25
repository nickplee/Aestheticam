//
//  ProcessViewController.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/21/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import UIKit
import PureLayout
import AudioToolbox

final class ProcessViewController: BaseController {
    
    // MARK: Outlets
    
    @IBOutlet weak var colorView: UIView!
    
    // MARK: Properties
    
    var content: CaptureOutput?
    var output: CaptureOutput?
    
    // MARK: Private Properties
    
    private let imageView = UIImageView()
    private var lastImageTime = Date()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "shot_2")!)
        
        view.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
        imageView.image = ImageDownloader.sharedInstance.getRandomImage()
        
        if let content = content {
            ContentProcessor.process(input: content, progress: { completed, total in
                self.handleProgress(completed, total: total)
            }) { output in
                self.output = output
                self.performSegue(withIdentifier: "review", sender: self)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ReviewViewController, segue.identifier == "review" {
            controller.content = output
            controller.original = content
        }
    }
    
    private func handleProgress(_ completed: Int, total: Int) {
        
        let percent = CGFloat(completed) / CGFloat(total)
        
        self.imageView.transform = CGAffineTransform(scaleX: 1.0 + percent, y: 1.0 + percent)
        
        colorView.backgroundColor = UIColor.neonColors.randomElement()
        
        DispatchQueue.global(qos: .background).async {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
        
        if let image = ImageDownloader.sharedInstance.getRandomImage(), Date().timeIntervalSince(lastImageTime) >= 0.25 {
            let size = image.size
            let imageView = UIImageView(image: image)
            imageView.alpha = CGFloat.random(within: 0.25...0.75)
            imageView.frame = CGRect(origin: CGPoint.zero, size: size)
            imageView.center = CGPoint(x: CGFloat.random(within: 0.0...view.frame.width), y: CGFloat.random(within: 0.0...view.frame.height))
            view.addSubview(imageView)
            lastImageTime = Date()
        }
    }
    
}
