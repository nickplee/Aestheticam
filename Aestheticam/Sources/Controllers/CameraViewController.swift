//
//  CameraViewController.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/21/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import UIKit

import PureLayout
import ADTransitionController
import LLSimpleCamera
import MarqueeLabel

private let animationImages = (1...10).flatMap { UIImage(named: "stalin\($0)") }

final class CameraViewController: BaseController {
    
    // MARK: Outlets
    
    @IBOutlet weak var controls: UIView!
    @IBOutlet weak var animationImageView: UIImageView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var recordingLabel: MarqueeLabel!
    
    // MARK: Private Properties
    
    
    private let camera = AESCamera(quality: AVCaptureSessionPreset640x480, position: Globals.persistedCaptureDevice, videoEnabled: true).then { camera in
        camera.view.isHidden = true
        camera.fixOrientationAfterCapture = true
    }
    
    fileprivate var output: CaptureOutput?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureStalin()
        configureCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCamera()
    }
    
    private func configureUI() {
        captureButton.imageView?.contentMode = .scaleToFill
        captureButton.imageView?.layer.minificationFilter = kCAFilterNearest
        captureButton.imageView?.layer.magnificationFilter = kCAFilterNearest
        
        recordingLabel.speed = .duration(1.0)
    }
    
    private func configureStalin() {
        animationImageView.animationImages = animationImages
        animationImageView.animationDuration = 0.25
        animationImageView.startAnimating()
    }
    
    private func configureCamera() {
        camera.attach(to: self, withFrame: view.bounds)
        view.bringSubview(toFront: controls)
        view.sendSubview(toBack: animationImageView)
    }
    
    private func startCamera() {
        camera.start()
        camera.view.isHidden = false
        recordingLabel.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ProcessViewController, segue.identifier == "process" {
            dest.content = output
            output = nil
        }
    }
    
    // MARK: Actions
    
    @IBAction private func toggleCamera(_ sender: AnyObject?) {
        camera.togglePosition()
        Globals.persistedCaptureDevice = camera.position
    }
    
    @IBAction private func takePhoto(_ sender: AnyObject?) {
        camera.view.isHidden = true
        camera.capture { camera, image, metadata, error in
            guard let image = image else {
                self.startCamera()
                return
            }
            
            camera?.stop()
            
            self.output = .still(image: image)
            self.performSegue(withIdentifier: "process", sender: self)
        }
    }
    
    @IBAction private func longPress(_ sender: AnyObject?) {
        guard let sender = sender as? UILongPressGestureRecognizer else {
            return
        }
        
        switch sender.state {
        case .began:
            recordingLabel.isHidden = false
            let outputURL = FileManager.default.tempURL(withExtension: "mp4")
            camera.startRecording(withOutputUrl: outputURL)
            captureButton.isHighlighted = true
        case .ended, .cancelled:
            captureButton.isHighlighted = false
            recordingLabel.isHidden = true
            camera.view.isHidden = true
            camera.stopRecording { camera, url, error in
                guard let url = url else {
                    self.startCamera()
                    return
                }
                self.output = .video(url: url)
                self.performSegue(withIdentifier: "process", sender: self)
            }
        default:
            break
        }
    }
    
}
