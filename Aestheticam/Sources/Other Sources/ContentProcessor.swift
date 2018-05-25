//
//  ContentProcessor.swift
//  Aestheticam
//
//  Created by Nick Lee on 5/25/18.
//  Copyright © 2018 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation
import UIKit
import Then
import AVFoundation

struct ContentProcessor {
    
    typealias ProgressBlock = (Int, Int) -> ()
    typealias CompletionBlock = (CaptureOutput?) -> ()
    
    private static let context = CIContext()
    
    static func process(input: CaptureOutput, progress: @escaping ProgressBlock, completion: @escaping CompletionBlock) {
        switch input {
        case .still(let image):
            
            process(image: image, progress: { completed, total in
                DispatchQueue.main.async { progress(completed, total) }
            }) { image in
                DispatchQueue.main.async {
                    guard let image = image else {
                        completion(nil)
                        return
                    }
                    completion(.still(image: image))
                }
            }
            
        case .video(let url):
            // Get tracks
            
            let asset = AVAsset(url: url)
            
            let audioTracks = asset.tracks(withMediaType: AVMediaTypeAudio)
            let videoTracks = asset.tracks(withMediaType: AVMediaTypeVideo)
            
            guard let videoTrack = videoTracks.first, let audioTrack = audioTracks.first else {
                return
            }
            
            // Video
            
            let duration = Int(asset.duration.seconds * 100)
            
            let minDuration = videoTrack.minFrameDuration
            let frameDuration = CMTimeMakeWithSeconds(0.2, minDuration.timescale)
            
            var lastFrame: CMTime = kCMTimeZero
            var lastFrameImage: CIImage?
            
            let composition = AVMutableVideoComposition(asset: asset) { request in
                let completed = Int(request.compositionTime.seconds * 100)
                
                DispatchQueue.main.async {
                    progress(completed, duration)
                }
                
                let delta = CMTimeSubtract(request.compositionTime, lastFrame)
                if delta.value < frameDuration.value, let output = lastFrameImage {
                    request.finish(with: output, context: nil)
                    return
                }
                
                guard let sourceCG = self.context.createCGImage(request.sourceImage, from: request.sourceImage.extent) else {
                    request.finish(with: request.sourceImage, context: nil)
                    return
                }
                
                let sourceUI = UIImage(cgImage: sourceCG)
                
                self.process(image: sourceUI, sounds: false, progress: nil) { image in
                    if let image = image, let outputCG = image.cgImage {
                        let output = CIImage(cgImage: outputCG)
                        lastFrameImage = output
                        lastFrame = request.compositionTime
                        request.finish(with: output, context: nil)
                    }
                    else {
                        request.finish(with: request.sourceImage, context: nil)
                    }
                }
            }
            
            // Audio
            
            let params = AVMutableAudioMixInputParameters(track: audioTrack)
            params.setVolume(50, at: kCMTimeZero)
            
            let mix = AVMutableAudioMix()
            mix.inputParameters = [params]
            
            
            // Export
            
            guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            exporter.videoComposition = composition
            exporter.audioMix = mix
            
            let destinationURL = FileManager.default.tempURL(withExtension: "mp4")
            exporter.outputURL = destinationURL
            exporter.outputFileType = AVFileTypeMPEG4
            
            exporter.exportAsynchronously {
                if exporter.error == nil {
                    DispatchQueue.main.async { completion(.video(url: destinationURL)) }
                }
                else {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
            
        }
    }
    
    fileprivate static func process(image: UIImage, sounds: Bool = true, progress progressBlock: ProgressBlock?, completion: @escaping (UIImage?) -> ()) {
        // Set up state to track progress
        let p = ImageProcessor(image: image)
        
        var operations = 0
        var progress = 0 {
            didSet {
                progressBlock?(progress, operations)
                if progress >= operations {
                    completion(p.outputImage)
                }
            }
        }
        
        let opQueue = OperationQueue()
        opQueue.maxConcurrentOperationCount = 1
        opQueue.isSuspended = true
        
        let opMutex = DispatchSemaphore(value: 1)
        
        // Enqueueing Function
        
        func enqueue(_ sleep: Bool = false, _ block: @escaping () -> ())  {
            opMutex.wait()
            let op = BlockOperation {
                if sounds {
                    Synthesizer.shared.play()
                }
                
                block()
                
                if sounds {
                    if sleep {
                        Thread.sleep(forTimeInterval: 0.02)
                    }
                    else {
                        Thread.sleep(forTimeInterval: 0.001)
                    }
                    Synthesizer.shared.stop()
                }
            }
            op.completionBlock = {
                opMutex.wait()
                progress += 1
                opMutex.signal()
            }
            operations += 1
            opMutex.signal()
            opQueue.addOperation(op)
        }
        
        // Enqueue Random Operations
        
        let deepFry = Bool.random()
        if deepFry {
            for _ in 0 ..< Int.random(within: 10 ... 30) {
                enqueue {
                    p.apply(.deepFry)
                }
            }
            enqueue {
                p.apply(.overSaturate)
            }
        }
        
        enqueue {
            p.apply(.starfield)
        }
        
        for _ in 0 ..< Int.random(within: 0 ... 1000) {
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
        
        for _ in 0 ..< Int.random(within: 2 ... 5) {
            enqueue(true) {
                p.apply(.placeImage)
            }
        }
        
        // Start
        
        opQueue.isSuspended = false
        
    }
    
}
