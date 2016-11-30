//
//  main.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/23/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import UIKit

UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc)),
    NSStringFromClass(AestheticApplication.self),
    NSStringFromClass(AppDelegate.self)
)
