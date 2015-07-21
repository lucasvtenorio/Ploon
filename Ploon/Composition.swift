//
//  Composition.swift
//  Ploon
//
//  Created by Lucas Tenório on 20/07/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//
import AVFoundation
struct Composition {
    let states: [AudioEngineState]
    let channels: Dictionary<String, AVAudioFile>
    private var currentStateIndex: Int = 0
    init (channels: Dictionary<String, AVAudioFile>, states: [AudioEngineState]) {
        self.states = states
        self.channels = channels
    }
    mutating func nextState(looping: Bool = false) {
        if self.currentStateIndex < self.states.count - 1 {
            self.currentStateIndex += 1
        }else{
            if looping {
                self.currentStateIndex = 0
            }
        }
    }
    var currentState: AudioEngineState {
        return self.states[currentStateIndex]
    }
    
    static func ploonMainTrack() -> Composition{
        let bass = AVAudioFile.readAudioFile(name: "Bass", type: "caf")!
        let chord = AVAudioFile.readAudioFile(name: "Chord", type: "caf")!
        let kick = AVAudioFile.readAudioFile(name: "Kick", type: "caf")!
        let hihat = AVAudioFile.readAudioFile(name: "Hi-hat-clap", type: "caf")!
        let pad = AVAudioFile.readAudioFile(name: "Pad", type: "caf")!
        let channels = [
            "bass": bass,
            "chord":chord,
            "kick":kick,
            "hihat":hihat,
            "pad":pad
        ]
        //[kick, hihat, bass, pad, chord]
        let first = AudioEngineState(channelDescription: [
            "kick": true,
            "hihat": false,
            "bass": false,
            "pad": false,
            "chord": false
            ])
        
        let second = AudioEngineState(channelDescription: [
            "kick": true,
            "hihat": true,
            "bass": false,
            "pad": false,
            "chord": false
            ])
        
        let third = AudioEngineState(channelDescription: [
            "kick": true,
            "hihat": true,
            "bass": true,
            "pad": false,
            "chord": false
            ])
        
        let fourth = AudioEngineState(channelDescription: [
            "kick": true,
            "hihat": true,
            "bass": true,
            "pad": true,
            "chord": false
            ])
        
        let fifth = AudioEngineState(channelDescription: [
            "kick": true,
            "hihat": true,
            "bass": true,
            "pad": true,
            "chord": true
            ])
        
        
        return Composition(channels: channels, states: [first, second, third, fourth, fifth])
    }
    
    static func ploonFastTrack() -> Composition{
        let bass = AVAudioFile.readAudioFile(name: "Bass2", type: "caf")!
        let arpeggiator = AVAudioFile.readAudioFile(name: "Arpeggiator", type: "caf")!
        let kick = AVAudioFile.readAudioFile(name: "Kick2", type: "caf")!
        let hihat = AVAudioFile.readAudioFile(name: "Hi-hat-clap-2", type: "caf")!
        let channels = [
            "bass": bass,
            "arpeggiator":arpeggiator,
            "kick":kick,
            "hihat":hihat
        ]
        //[kick, hihat, bass, arpeggiator]
        let first = AudioEngineState(channelDescription: [
            "kick": true,
            "hihat": false,
            "bass": false,
            "arpeggiator": false
            ])
        
        let second = AudioEngineState(channelDescription: [
            "kick": true,
            "hihat": true,
            "bass": false,
            "arpeggiator": false
            ])
        
        let third = AudioEngineState(channelDescription: [
            "kick": true,
            "hihat": true,
            "bass": true,
            "arpeggiator": false
            ])
        
        let fourth = AudioEngineState(channelDescription: [
            "kick": false,
            "hihat": false,
            "bass": false,
            "arpeggiator": true
            ])
        
        let fifth = AudioEngineState(channelDescription: [
            "kick": true,
            "hihat": true,
            "bass": true,
            "arpeggiator": true
            ])
        
        return Composition(channels: channels, states: [first, second, third, fourth, fifth])
    }
}
