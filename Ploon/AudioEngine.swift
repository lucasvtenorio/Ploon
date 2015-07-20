//
//  AudioEngine.swift
//  Ploom
//
//  Created by Lucas Tenório on 16/07/15.
//  Copyright (c) 2015 Ploom. All rights reserved.
//

import UIKit
import AVFoundation
class AudioEngine: NSObject {
    private let engine = AVAudioEngine()
    private var channels = Dictionary<String, (AVAudioPlayerNode, AVAudioUnitTimePitch)>()
    
    static let sharedEngine = AudioEngine()
    var callbacks =  Dictionary<String, ()->() >()
    func addChannel(#name: String, file: AVAudioFile, configuration: ChannelConfiguration = ChannelConfiguration.identity, looping: Bool = true) {
        if let (player, timeNode) = self.channels[name] {
            self.apply(configuration: configuration, name: name)
            timeNode.reset()
            player.stop()
            self.readFileToChannel(channel: name, file: file, looping:looping)
        }else{
            let player = AVAudioPlayerNode()
            let timeNode = AVAudioUnitTimePitch()
            let buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
            self.engine.attachNode(player)
            self.engine.attachNode(timeNode)
            self.engine.connect(player, to: timeNode, format: buffer.format)
            self.engine.connect(timeNode, to: self.engine.mainMixerNode, format: buffer.format)
            self.channels[name] = (player, timeNode)
            self.readFileToChannel(channel: name, file: file, looping:looping)
            self.apply(configuration: configuration, name: name)
        }
    }
    
    private func readFileToChannel(#channel: String, file: AVAudioFile, looping: Bool = true) {
        if let (player, timeNode) = self.channels[channel] {
            let buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
            file.framePosition = 0
            var error: NSError?
            if file.readIntoBuffer(buffer, error: &error) {
                let options: AVAudioPlayerNodeBufferOptions
                if looping {
                    options = AVAudioPlayerNodeBufferOptions.Loops | AVAudioPlayerNodeBufferOptions.Interrupts
                } else{
                    options = AVAudioPlayerNodeBufferOptions.Interrupts
                }
                
                player.scheduleBuffer(buffer, atTime: nil, options: options){ [weak self] in
                    if let s = self, callback = s.callbacks[channel] {
                        callback()
                    }
                }
            }else{
                println("Error reading file to channel in AudioEngine(\(error?.localizedDescription))")
            }
        }
    }
    
    func apply(#configuration: ChannelConfiguration, name: String) {
        if let (playerNode, timeNode) = self.channels[name] {
            playerNode.volume = configuration.volume
            timeNode.rate = configuration.rate
        }
    }
    func apply(#state: AudioEngineState) {
        for (name, configuration) in state.configurations {
            self.apply(configuration: configuration, name: name)
        }
    }
    
    func start() {
        if self.channels.count > 0 && !engine.running{
            
        }
        engine.prepare()
        var error: NSError?
        if !engine.startAndReturnError(&error) {
            println("Error starting AudioEngine(\(error?.localizedDescription))")
        }
    }

    var running: Bool {
        return self.engine.running
    }
    
    var state: AudioEngineState {
        var result = AudioEngineState()
        for (name, (player, time)) in self.channels {
            let configuration = ChannelConfiguration(volume: player.volume, rate: time.rate)
            result.addConfiguration(channelName: name, configuration: configuration)
        }
        return result
    }
    
    func playChannel(channel: String) {
        if let (player, _) = self.channels[channel] {
            player.play()
        }
    }
    func pauseChannel(channel: String) {
        if let (player, _) = self.channels[channel] {
            player.pause()
        }
    }
    func play() {
        var startTime: AVAudioTime? = nil
        for (player, _) in self.channels.values {
            if let startTime = startTime {
                player.playAtTime(startTime)
            }else{
                let delayTime: NSTimeInterval = 0.1
                let outputFormat = player.outputFormatForBus(0)
                let startSampleTime: AVAudioFramePosition = AVAudioFramePosition(Double(player.lastRenderTime.sampleTime) + delayTime * outputFormat.sampleRate)
                let time = AVAudioTime(sampleTime: startSampleTime, atRate: outputFormat.sampleRate)
                startTime = time
                player.playAtTime(startTime)
            }
            //let delay: NSTimeInterval = 0.01
            //let now: NSTimeInterval =
            
            //player.play()
        }
    }
    func pause() {
        for (player, _) in self.channels.values {
            player.pause()
        }
    }
}

extension AVAudioFile {
    static func readAudioFile(#name: String, type: String) -> AVAudioFile? {
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: type), url =  NSURL.fileURLWithPath(path){
            let error = NSErrorPointer()
            var file = AVAudioFile(forReading: url, error: error)
            if error != nil {
                println(error.debugDescription)
                return nil
            }else{
                return file
            }
        }else{
            println("Error reading file \(name).\(type), maybe doesn't exist?")
            return nil
        }
    }
}

