//
//  ImageDownloader.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/21/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import RealmSwift
import RandomKit

final class ImageDownloader {
    
    // MARK: Singleton
    
    static let sharedInstance = ImageDownloader()
    
    // MARK: Private Properties
    
    private static let saveQueue = DispatchQueue(label: "com.nicholasleedesigns.aestheticam.save", attributes: [])
    
    // MARK: Initialiaztion
    
    private init() {}
    
    // MARK: DB
    
    private class func ImageRealm() throws -> Realm {
        
        let folder = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as NSString
        let realmPath = folder.appendingPathComponent("data.realm")
        var realmURL = URL(fileURLWithPath: realmPath)
        
        var config = Realm.Configuration()
        config.fileURL = realmURL
        
        let realm = try Realm(configuration: config)
        
        defer {
            do {
                var values = URLResourceValues()
                values.isExcludedFromBackup = true
                try realmURL.setResourceValues(values)
            }
            catch {}
        }
        
        return realm
    }
    
    // MARK: Download
    
    func download() {
        
        guard Globals.needsDownload else {
            return
        }
        
        let url = Globals.apiURL
        
        request(url).responseJSON { result in
            guard let v = result.result.value as? [String: AnyObject], let images = v["images"] as? [String] else {
                return
            }
            let urls = images.flatMap(URL.init(string:))
            self.getImages(urls)
            Globals.lastDownloadDate = Date()
        }
        
    }
    
    private func getImages(_ urls: [URL]) {
        let requests = urls.map({ request($0) })
        requests.forEach {
            $0.responseImage { result in
                guard let image = result.result.value else {
                    return
                }
                ImageDownloader.saveQueue.async {
                    let realm = try! type(of: self).ImageRealm()
                    guard let data = UIImagePNGRepresentation(image) else {
                        return
                    }
                    do {
                        
                        let urlString = result.request!.url!.absoluteString
                        
                        let pred = NSPredicate(format: "%K = %@", argumentArray: ["url", urlString])
                        
                        guard realm.objects(Image.self).filter(pred).first == nil else {
                            return
                        }
                        
                        try realm.write {
                            let img = Image()
                            img.data = data
                            img.url = urlString
                            realm.add(img)
                        }
                    }
                    catch {}
                }
            }
        }
    }
    
    // MARK: Random
    
    func getRandomImage() -> UIImage? {
        guard let realm = try? type(of: self).ImageRealm(), let entry = realm.objects(Image.self).random else {
            return nil
        }
        return UIImage(data: entry.data)
    }
    
}
