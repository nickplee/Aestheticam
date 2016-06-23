//
//  Image.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/21/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import RealmSwift

final class Image: Object {
    dynamic var url: String = ""
    dynamic var data: NSData = NSData()
}