//
//  ImageDownloader.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/21/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import UIKit

final class ImageDownloader {
    
    // MARK: Singleton
    
    static let sharedInstance = ImageDownloader()
    
    // MARK: Private Properties
    
    private var imageURLs: [URL] = []
    
    // MARK: Initialiaztion
    
    private init() {}
    
    // MARK: Refresh
    
    func refreshImages() {
        do {
            let path = Bundle.main.bundleURL.appendingPathComponent("dank_meme_trash")
            let contents = try FileManager.default.contentsOfDirectory(atPath: path.path)
            imageURLs = contents.map { path.appendingPathComponent($0) }
        }
        catch {}
    }
    
    
    
    // MARK: Random
    
    func getRandomImage() -> UIImage? {
        let maxTries = min(imageURLs.count, 5)
        
        guard maxTries > 0 else {
            return nil
        }
        
        var tries = 1
        var outputImage: UIImage?
        
        while outputImage == nil, tries < maxTries {
            let url = imageURLs.randomElement()
            outputImage = UIImage(contentsOfFile: url.path)
            tries += 1
        }
    
        return outputImage
    }
    
}
