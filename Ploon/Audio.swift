//
//  Audio.swift
//  Ploon
//
//  Created by Lucas Tenório on 16/07/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

import UIKit

protocol Interpolable {
    static func lerp(#from: Self, to: Self, t: Float) -> Self
}

func lerpGroup<T: Interpolable>(group: Array<T>,var t: Float) -> T{
    assert(group.count > 0, "Cannot interpolate empty group")
    if t <= 0 {
        t = 0.0
    }else if t >= 1.0 {
        t = 1.0
    }
    if group.count == 1 {
        return group.first!
    }
    let step = 1.0 / Float(group.count-1)
    
    let low = Int(t / step)
    let high = min(low+1, group.count-1)
    let relativePercentage: Float
    if low != high {
        relativePercentage = (t - Float(low) * step) / (Float(high) * step - Float(low) * step)
    } else{
        relativePercentage = 1.0
    }
    
    return T.lerp(from: group[low], to: group[high], t: relativePercentage)
}


struct AudioEngineState: Interpolable{
    private var dictionary = Dictionary<String, ChannelConfiguration>()
    var configurations:Dictionary<String, ChannelConfiguration> {
        get {
            return self.dictionary
        }
    }
    init() {
        
    }
    init(channelDescription: Dictionary<String, Bool>) {
        for (channel, normal) in channelDescription {
            if normal {
                self.addConfiguration(channelName: channel, configuration: ChannelConfiguration.identity)
            } else {
                self.addConfiguration(channelName: channel, configuration: ChannelConfiguration.silentNormalRate)
            }
            
        }
    }
    mutating func addConfiguration(#channelName: String, configuration: ChannelConfiguration) {
        self.dictionary[channelName] = configuration
    }
    static func lerp(#from: AudioEngineState, to: AudioEngineState, t: Float) -> AudioEngineState {
        var result = AudioEngineState()
        assert(from.dictionary.keys.array == to.dictionary.keys.array, "Interpolation between AudioEngineStates needs to have the same channels on both ends!")
        
        for (name, fromConfiguration) in from.dictionary {
            if let toConfiguration = to.dictionary[name] {
                result.addConfiguration(channelName: name, configuration: ChannelConfiguration.lerp(from: fromConfiguration, to: toConfiguration, t: t))
            }
        }
        return result
    }
}

extension Float: Interpolable{
    static func lerp(#from: Float, to: Float, t: Float) -> Float {
        if t <= 0.0 {
            return from
        }else if t >= 1 {
            return to
        }else{
            return t * (to - from) + from
        }
    }
}

struct ChannelConfiguration: Interpolable {
    let volume: Float
    let rate: Float
    static func lerp(#from: ChannelConfiguration, to: ChannelConfiguration, t: Float) -> ChannelConfiguration {
        let v = Float.lerp(from:from.volume, to: to.volume, t: t)
        let r = Float.lerp(from:from.rate, to: to.rate, t: t)
        return ChannelConfiguration(volume: v, rate: r)
    }
    static let identity = ChannelConfiguration(volume: 1.0, rate: 1.0)
    static let silentNormalRate = ChannelConfiguration(volume: 0.0, rate: 1.0)
    static let silentVerySlow = ChannelConfiguration(volume: 0.0, rate: 0.1)
    
}