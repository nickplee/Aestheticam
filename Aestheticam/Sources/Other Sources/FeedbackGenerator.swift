//
//  FeedbackGenerator.swift
//  Aestheticam
//
//  Created by Nick Lee on 11/29/16.
//  Copyright © 2016 Nicholas Lee Designs, LLC. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 10.0, *)
struct FeedbackGenerator {
    
    static let shared = FeedbackGenerator()
    
    private let generators: [Feedbackable] = [
        UIImpactFeedbackGenerator(style: .light),
        UIImpactFeedbackGenerator(style: .medium),
        UIImpactFeedbackGenerator(style: .heavy),
        UISelectionFeedbackGenerator(),
        UINotificationFeedbackGenerator()
    ]
    
    private init() {
        generators.forEach { $0.prime() }
    }
    
    func start() {
        next()
    }
    
    func fire() {
        generators.randomElement().trigger()
    }
    
    private func next() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(within: 1...4))) {
            self.fire()
            self.next()
        }
    }
    
}

fileprivate protocol Preparable {
    func prime()
}

fileprivate protocol Feedbackable: Preparable {
    func trigger()
}

@available(iOS 10.0, *)
extension UIFeedbackGenerator: Preparable {
    func prime() {
        prepare()
    }
}

@available(iOS 10.0, *)
extension UIImpactFeedbackGenerator: Feedbackable {
    func trigger() {
        impactOccurred()
    }
}

@available(iOS 10.0, *)
extension UISelectionFeedbackGenerator: Feedbackable {
    func trigger() {
        selectionChanged()
    }
}

@available(iOS 10.0, *)
extension UINotificationFeedbackGenerator: Feedbackable {
    func trigger() {
        
        var noteType: UINotificationFeedbackType = .warning
        
        switch Int.random(within: 0...2) {
        case 0:
            noteType = .error
        case 1:
            noteType = .success
        default:
            break
        }
        
        notificationOccurred(noteType)
    }
}
