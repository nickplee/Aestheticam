//
//  ReviewViewController.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/23/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

final class ReviewViewController: BaseController {
    
    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoContainer: UIView!
    
    // MARK: Properties
    
    var content: CaptureOutput?
    var original: CaptureOutput?
    
    // MARK: Private Properties
    
    private var player: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    private var looper: AVPlayerLooper?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        Synthesizer.shared.playAesthetic()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ProcessViewController, segue.identifier == "process" {
            dest.content = original
        }
    }
    
    // MARK Presentation
    
    private func presentContent() {
        guard let content = content else {
            return
        }
        switch content {
        case .still(let image):
            imageView.image = image
        case .video(let url):
            let item = AVPlayerItem(url: url)
            
            let play = AVQueuePlayer(playerItem: item)
            player = play
            
            looper = AVPlayerLooper(player: play, templateItem: item)
            
            let pl = AVPlayerLayer(player: play)
            playerLayer = pl
            pl.frame = videoContainer.bounds
            pl.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoContainer.layer.addSublayer(pl)
            
            player?.play()
        }
    }
    
    // MARK: Shaking
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            performSegue(withIdentifier: "process", sender: self)
            LogEvent("shake_reprocess")
        }
    }
    
    // MARK: Actions
    
    @IBAction private func share(_ sender: AnyObject?) {
        guard let content = content else {
            return
        }
        
        var shareItem: Any?
        
        switch content {
        case .still(let image):
            shareItem = image
        case .video(let url):
            shareItem = url
        }
        
        guard let s = shareItem else {
            return
        }

        let text = "I created my A E S T H E T I C with #aestheticam"

        let controller = UIActivityViewController(activityItems: [text, s], applicationActivities: nil)

        controller.completionWithItemsHandler = { (activity, success, items, error) -> Void in

            guard error == nil else {
                return
            }

            var params: [String : NSObject] = [
                "success" : success as NSObject
            ]

            if let a = activity {
                params["activity"] = a as NSObject?
            }

            LogEvent("share", params)

        }

        present(controller, animated: true) {
            LogEvent("began_share")
        }
    }
    
}
