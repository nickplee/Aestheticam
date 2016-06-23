//
//  CameraViewController.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/21/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import UIKit
import FastttCamera
import PureLayout
import ADTransitionController

private let animationImages = (1...10).flatMap { UIImage(named: "stalin\($0)") }

final class CameraViewController: BaseController {
    
    // MARK: Outlets
    
    @IBOutlet weak var controls: UIView!
    @IBOutlet weak var animationImageView: UIImageView!
    @IBOutlet weak var captureButton: UIButton!

    // MARK: Private Properties
    
    private let camera = FastttCamera()
    private var image: UIImage?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationImageView.animationImages = animationImages
        animationImageView.animationDuration = 0.25
        animationImageView.startAnimating()
        configureCamera()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        debugGenerator()
    }

    private func debugGenerator() {
        image = UIImage(named: "Hillary_Clinton_official_Secretary_of_State_portrait_crop")
        performSegueWithIdentifier("process", sender: self)
    }
    
    private func configureUI() {
        captureButton.imageView?.contentMode = .ScaleToFill
        captureButton.imageView?.layer.minificationFilter = kCAFilterNearest
        captureButton.imageView?.layer.magnificationFilter = kCAFilterNearest
    }
    
    private func configureCamera() {
        camera.delegate = self
        camera.interfaceRotatesWithOrientation = false
        fastttAddChildViewController(camera, belowSubview: controls)
        camera.view.autoPinEdgesToSuperviewEdges()
        camera.view.backgroundColor = UIColor.clearColor()
    }
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? ProcessViewController where segue.identifier == "process" {
            dest.image = image
            image = nil
        }
    }
    
    // MARK: Actions
 
    @IBAction private func toggleCamera(sender: AnyObject?) {
        
        var newDevice = camera.cameraDevice
        
        if camera.cameraDevice == .Front {
            newDevice = .Rear
        }
        else {
            newDevice = .Front
        }
        
        guard FastttCamera.isCameraDeviceAvailable(newDevice) else {
            return
        }
        
        camera.cameraDevice = newDevice
        
    }
    
    @IBAction private func takePhoto(sender: AnyObject?) {
        camera.view.hidden = true
        camera.takePicture()
    }
    
}

// MARK: FastttCameraDelegate
extension CameraViewController: FastttCameraDelegate {
    func cameraController(cameraController: FastttCameraInterface!, didFinishNormalizingCapturedImage capturedImage: FastttCapturedImage!) {
        image = capturedImage.scaledImage
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("process", sender: self)
        }
    }
}

