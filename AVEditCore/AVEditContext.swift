//
//  AVEditContext.swift
//  AVEdit
//
//  Created by 刘东旭 on 2020/12/5.
//  Copyright © 2020 刘东旭. All rights reserved.
//

import Foundation
import AVFoundation

public class AVEditContext {
    
    public func exportTimeline(timeline: AVEditTimeline) -> Bool {
        let session = AVAssetExportSession(asset: timeline.composition, presetName: "nil")
        return true
    }
}
