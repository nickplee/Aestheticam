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
    
    private static let saveQueue = dispatch_queue_create("com.nicholasleedesigns.aestheticam.save", DISPATCH_QUEUE_SERIAL)
    
    // MARK: Initialiaztion
    
    private init() {}
    
    // MARK: DB
    
    private class func ImageRealm() throws -> Realm {
        
        let folder = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as NSString
        let realmPath = folder.stringByAppendingPathComponent("data.realm")
        let realmURL = NSURL(fileURLWithPath: realmPath)
        
        var config = Realm.Configuration()
        config.fileURL = realmURL
        
        let realm = try Realm(configuration: config)
        
        defer {
            do {
                try realmURL.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
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
        
        request(.GET, url).responseJSON { result in
            guard let v = result.result.value as? [String: AnyObject], images = v["images"] as? [String] else {
                return
            }
            let urls = images.flatMap({ NSURL(string: $0) })
            self.getImages(urls)
            Globals.lastDownloadDate = NSDate()
        }
        
    }
    
    private func getImages(urls: [NSURL]) {
        let requests = urls.map({ request(.GET, $0) })
        requests.forEach {
            $0.responseImage { result in
                guard let image = result.result.value else {
                    return
                }
                dispatch_async(ImageDownloader.saveQueue) {
                    let realm = try! self.dynamicType.ImageRealm()
                    guard let data = UIImagePNGRepresentation(image) else {
                        return
                    }
                    do {
                        
                        let urlString = result.request!.URLString
                        
                        let pred = NSPredicate(format: "%K = %@", argumentArray: ["url", urlString])
                        
                        guard realm.objects(Image).filter(pred).first == nil else {
                            return
                        }
                        
                        try realm.write {
                            let img = Image()
                            img.data = data
                            img.url = result.request!.URLString
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
        guard let realm = try? self.dynamicType.ImageRealm(), entry = realm.objects(Image).random else {
            return nil
        }
        return UIImage(data: entry.data)
    }
    
}