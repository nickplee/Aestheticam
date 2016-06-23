//
//  Synthesizer.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/23/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import AudioKit
import RandomKit
import Obsidian_UI_iOS
import Then

final class Synthesizer {
    
    static let sharedInstance = Synthesizer()
    
    private let mixer = AKMixer().then {
        $0.volume = 0.7
    }
    
    private let osc = AKFMSynth(voiceCount: 10).then {
        $0.releaseDuration = 0.1
        
    }
    
    private var players: [AKAudioPlayer] = []
    
    private let aesthetic = (try! AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("push", withExtension: "aiff")!)).then {
        $0.volume = 0.1
    }
    
    private init() {
        
        AudioKit.output = mixer
        
        mixer.connect(osc)
        
        players += (1...4).map { i in
            let name = "snd\(i)"
            let path = NSBundle.mainBundle().pathForResource(name, ofType: "aiff")!
            let player = AKAudioPlayer(path)
            mixer.connect(player)
            return player
        }
        
        AudioKit.start()
    }
    
    func play(includeSounds: Bool = false) {
        dispatch_async(dispatch_get_main_queue()) {
            if !includeSounds || Bool.random() {
                self.osc.playNote(Int.random(24...84), velocity: 127)
            }
            else {
                self.players.random?.play()
            }
        }
    }
    
    func playAesthetic() {
        MainQueue.async {
            self.aesthetic.stop()
            self.aesthetic.currentTime = 0
            self.aesthetic.play()
        }
    }
    
    func stop(includeSounds: Bool = false) {
        MainQueue.async {
            
            if includeSounds {
                for p in self.players {
                    if p.isPlaying {
                        p.stop()
                        p.reloadFile()
                    }
                }
            }
            
            guard let n = self.osc.activeNotes.first else {
                return
            }
            self.osc.stopNote(n)
        }
    }
    
}