//
//  AVEditFileReader.swift
//  AVEdit
//
//  Created by 刘东旭 on 2020/12/5.
//  Copyright © 2020 刘东旭. All rights reserved.
//

import Foundation
import AVFoundation

public class AVEditFileReader {
    
    private var assetReader: AVAssetReader?
    private var assetReaderOutput: AVAssetReaderOutput?
    private var asset: AVAsset?
    init(filePath: String) {
        asset = createInputAsset(filePath: filePath)
        guard let asset = asset else {
            print("asset error")
            return
        }
        do {
            assetReader = try AVAssetReader(asset: asset)
        } catch let error {
            print("reader create error: " + error.localizedDescription)
        }
        if !createAssetReaderOutput() {
            print("asset reader output error")
        }
        guard let assetReaderOutput = assetReaderOutput, let assetReader = assetReader else {
            return
        }
        if assetReader.canAdd(assetReaderOutput) {
            assetReader.add(assetReaderOutput)
        }
    }
    
    public func startReader(timestamp: Int64, duration: Int64) -> Bool {
        assetReader?.timeRange = CMTimeRange(start: CMTime(value: timestamp, timescale: 1000000), duration: CMTime(value: duration, timescale: 1000000))
        assetReader?.startReading()
        return true
    }
    
    public func startPlayback(timestamp: Int64) {
        
    }
    
    private func createInputAsset(filePath: String) -> AVAsset {
        let assetUrl = URL(fileURLWithPath: filePath)
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        return AVURLAsset(url: assetUrl, options: options)
    }
    
    private func createAssetReaderOutput() -> Bool {
        assetReaderOutput = AVAssetReaderTrackOutput(track: (asset?.tracks.first)!, outputSettings: [String(kCVPixelBufferPixelFormatTypeKey):kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange])
        return true
    }
    
}
