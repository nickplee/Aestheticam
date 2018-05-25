//
//  FileExtensions.swift
//  Aestheticam
//
//  Created by Nick Lee on 5/25/18.
//  Copyright © 2018 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation

extension FileManager {
    func tempURL(withExtension ext: String) -> URL {
        let randomName = (0...1).reduce("") { result, _ in result + String(arc4random()) }
        return temporaryDirectory.appendingPathComponent(randomName).appendingPathExtension(ext)
    }
    
    func purgeTempDir() {
        do {
            let contents = try contentsOfDirectory(atPath: temporaryDirectory.path)
            for file in contents {
                let deleteme = temporaryDirectory.appendingPathComponent(file)
                do {
                    try removeItem(atPath: deleteme.path)
                }
                catch {}
            }
        }
        catch {}
    }
}
