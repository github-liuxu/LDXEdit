//
//  AVExport.swift
//  AVEdit
//
//  Created by 刘东旭 on 2020/12/20.
//  Copyright © 2020 刘东旭. All rights reserved.
//

import Foundation
import AVFoundation

public class AVExport {
    public class func exportAsset(outputPath: String, timeline: AVEditTimeline, complate:@escaping(_ finish: Bool)->Void) {
        let exportSession = AVAssetExportSession(asset: timeline.composition, presetName: AVAssetExportPresetMediumQuality)
        exportSession?.outputFileType = AVFileType.mp4
        exportSession?.outputURL = URL(fileURLWithPath: outputPath)
        exportSession?.exportAsynchronously {
            complate(true)
        }
    }
}
