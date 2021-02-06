//
//  AVEditTimeline.swift
//  AVEdit
//
//  Created by 刘东旭 on 2020/12/5.
//  Copyright © 2020 刘东旭. All rights reserved.
//

import Foundation
import AVFoundation


public class AVEditTimeline {
    public var composition = AVMutableComposition()
    private var videoTracks = [Any]()
    private var audioTracks = [Any]()
    
    init(width: UInt32, height: UInt32) {
        
    }
    
    public func addVideoTrack() ->AVAssetTrack? {
        return composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
    }
    
}
