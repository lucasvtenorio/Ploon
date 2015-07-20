//
//  AudioNode.swift
//  Ploon
//
//  Created by Lucas Tenório on 16/07/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class AudioNode: SKNode {
    private let fadeInDuration: NSTimeInterval = 2.0
    private let fadeOutDuration: NSTimeInterval = 4.0
    private lazy var engine = AudioEngine.sharedEngine
    private lazy var first = AVAudioFile.readAudioFile(name: "main-1", type: "caf")
    private lazy var second = AVAudioFile.readAudioFile(name: "main-2", type: "caf")
    private lazy var third = AVAudioFile.readAudioFile(name: "main-3", type: "caf")
    
    
    private lazy var bass = AVAudioFile.readAudioFile(name: "Bass", type: "caf")!
    private lazy var chord = AVAudioFile.readAudioFile(name: "Chord", type: "caf")!
    private lazy var kick = AVAudioFile.readAudioFile(name: "Kick", type: "caf")!
    private lazy var hihat = AVAudioFile.readAudioFile(name: "Hi-hat-clap", type: "caf")!
    private lazy var pad = AVAudioFile.readAudioFile(name: "Pad", type: "caf")!
    
    private lazy var bomb = AVAudioFile.readAudioFile(name: "bomb", type: "caf")!
    private lazy var laser = AVAudioFile.readAudioFile(name: "laser", type: "caf")!
    
    private lazy var callback = AVAudioFile.readAudioFile(name: "callbackKick", type: "caf")!
    
    let initial = ChannelConfiguration(volume: 0.0, rate: 1.0)
    let final = ChannelConfiguration(volume: 1.0, rate: 1.0)
    
    private var files: [AVAudioFile] {
        return [kick, hihat, bass, pad, chord]
    }
    
    
    private var channelsPlaying = 0
    
    func fadeInChannel(index: Int) {
        if index >= 0 && index < self.files.count {
            self.channelsPlaying += 1
            let channel = "main-\(index)"
            
            let a = SKAction.customActionWithDuration(self.fadeInDuration){ (node, time) in
                let percentage = NSTimeInterval(time) / self.fadeInDuration
                let config = lerpGroup([self.initial, self.final], Float(percentage))
                
                //println("Fading channel \(channel): \(percentage)")
                self.engine.apply(configuration: config, name: channel)
            }
            self.runAction(a)
        }
//        let a = SKAction.customActionWithDuration(2.0){ (node, time) in
//            let percentage = Float(time) / 2.0
//            let state = lerpGroup([self.firstState, self.firstState,self.firstState, self.secondState, self.secondState,  self.secondState, self.thirdState], percentage)
//            
//            self.engine.apply(state: state)
//        }
    }

    
    func setupMainTrack() {
        for (index, file) in enumerate(self.files) {
            self.engine.addChannel(name: "main-\(index)", file: file, configuration: self.initial)
        }
//        self.engine.callbacks["callback"] = {[weak self] in
//            if let s = self {
////                
////                s.engine.addChannel(name: "callback", file: s.callback, configuration: s.final, looping: false)
////                s.engine.playChannel("callback")
//                println("BEAT")
//            }
//        }
//        self.engine.addChannel(name: "callback", file: callback, configuration: final, looping: true)
//        
        
    }
    
    func start() {
        self.setupMainTrack()
        engine.start()
        engine.play()
        self.increase()
//        if let first = self.first, second = self.second, third = self.third {
//            engine.addChannel(name: "first", file: bass)
//            engine.addChannel(name: "second", file: chord)
//            engine.addChannel(name: "third", file: kick)
//            
//            let a = SKAction.customActionWithDuration(30.0){ (node, time) in
//                let percentage = Float(time) / 30.0
//                println("Percentage \(percentage)")
//                let state = lerpGroup([self.firstState, self.firstState,self.firstState, self.secondState, self.secondState,  self.secondState, self.thirdState], percentage)
//                self.engine.apply(state: state)
//            }
//            self.runAction(a)
//        }
        
    }
    
    func increase() {
        self.fadeInChannel(self.channelsPlaying)
    }
    
    func fadeOutAction() -> SKAction {
        
        let a = SKAction.customActionWithDuration(self.fadeOutDuration){[weak self] (node, time) in
            if let s = self {
                let begin = s.engine.state
                var end = AudioEngineState()
                for (name, configuration) in begin.configurations {
                    end.addConfiguration(channelName: name, configuration: ChannelConfiguration(volume: 0.0, rate: 0.1))
                }
                let percentage = NSTimeInterval(time) / s.fadeOutDuration
                //println("Fading out: \(percentage)")
                let state = lerpGroup([begin, end], Float(percentage))
                s.engine.apply(state: state)
            }
        }
        return a
    }
    func playerExploded() {
        self.engine.addChannel(name: "bomb", file: bomb, configuration: ChannelConfiguration(volume: 0.5, rate: 0.7), looping: false)
        self.engine.playChannel("bomb")
    }
    func enemySpawned() {
        self.engine.addChannel(name: "laser", file: laser, configuration: ChannelConfiguration(volume: 0.1, rate: 0.3), looping: false)
        self.engine.playChannel("laser")
    }
//    func fadeOut() {
//        let begin = self.engine.state
//        var end = AudioEngineState()
//        for (name, configuration) in begin.configurations {
//            end.addConfiguration(channelName: name, configuration: ChannelConfiguration(volume: 0.0, rate: 0.1))
//        }
//        let a = SKAction.customActionWithDuration(self.fadeOutDuration){ (node, time) in
//            let percentage = NSTimeInterval(time) / self.fadeOutDuration
//            let state = lerpGroup([begin, end], Float(percentage))
//            self.engine.apply(state: state)
//        }
//        self.runAction(a)
//    }
}
