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
    fileprivate var image: UIImage?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationImageView.animationImages = animationImages
        animationImageView.animationDuration = 0.25
        animationImageView.startAnimating()
        configureCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        debugGenerator()
    }

    private func debugGenerator() {
        image = UIImage(named: "Hillary_Clinton_official_Secretary_of_State_portrait_crop")
        performSegue(withIdentifier: "process", sender: self)
    }
    
    private func configureUI() {
        captureButton.imageView?.contentMode = .scaleToFill
        captureButton.imageView?.layer.minificationFilter = kCAFilterNearest
        captureButton.imageView?.layer.magnificationFilter = kCAFilterNearest
    }
    
    private func configureCamera() {
        camera.delegate = self
        camera.interfaceRotatesWithOrientation = false
        camera.cameraDevice = Globals.persistedCaptureDevice
        fastttAddChildViewController(camera, belowSubview: controls)
        camera.view.autoPinEdgesToSuperviewEdges()
        camera.view.backgroundColor = UIColor.clear
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ProcessViewController, segue.identifier == "process" {
            dest.image = image
            image = nil
        }
    }
    
    // MARK: Actions
 
    @IBAction private func toggleCamera(_ sender: AnyObject?) {
        
        var newDevice = camera.cameraDevice
        
        if camera.cameraDevice == .front {
            newDevice = .rear
        }
        else {
            newDevice = .front
        }
        
        guard FastttCamera.isCameraDeviceAvailable(newDevice) else {
            return
        }
        
        camera.cameraDevice = newDevice
        Globals.persistedCaptureDevice = newDevice
        
        LogEvent("toggle_camera", ["camera" : newDevice.rawValue as NSNumber])
        
    }
    
    @IBAction private func takePhoto(_ sender: AnyObject?) {
        camera.view.isHidden = true
        camera.takePicture()
        LogEvent("take_photo")
    }
    
}

// MARK: FastttCameraDelegate
extension CameraViewController: FastttCameraDelegate {
    func cameraController(_ cameraController: FastttCameraInterface!, didFinishNormalizing capturedImage: FastttCapturedImage!) {
        guard let scaledImage = capturedImage.scaledImage else {
            return
        }
        image = scaledImage
        DispatchQueue.main.async {
            LogEvent("image_size", ["size": String(describing: scaledImage.size) as NSString])
            self.performSegue(withIdentifier: "process", sender: self)
        }
    }
}

