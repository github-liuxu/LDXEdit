//
//  ViewController.swift
//  AVEdit
//
//  Created by 刘东旭 on 2020/11/3.
//  Copyright © 2020 刘东旭. All rights reserved.
//

import UIKit
import AVFoundation
import Dispatch

class ViewController: UIViewController {

    let avplayerView = AVSampleBufferDisplayLayer()
    let readerVideo = DispatchQueue(label: "videoReader")
    let writerVideo = DispatchQueue(label: "videoWriter")
    var assetReader: AVAssetReader!
    var readerOutput: AVAssetReaderTrackOutput!
    var assetWriter: AVAssetWriter!
    var writerInput: AVAssetWriterInput!
    let group = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.layer.addSublayer(avplayerView)
        avplayerView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        let assetPath = Bundle.main.bundlePath + "/123.mp4"
        let desPath = NSHomeDirectory() + "/Documents/123.mp4"
        print(desPath)
        let fm = FileManager.default
        if fm.fileExists(atPath: desPath) {
            try? fm.removeItem(atPath: desPath)
        }
        
        let asset = AVAsset(url: URL(fileURLWithPath: assetPath))
        assetReader = try! AVAssetReader(asset: asset)
        readerOutput = AVAssetReaderTrackOutput(track: asset.tracks(withMediaType: .video).first!, outputSettings: [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_422YpCbCr8])
        if assetReader.canAdd(readerOutput) {
            assetReader.add(readerOutput)
        }
        assetReader.startReading()
        
        assetWriter = try! AVAssetWriter(outputURL: URL(fileURLWithPath: desPath), fileType: AVFileType.mp4)
        writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: [AVVideoCodecKey:AVVideoCodecType.h264 ,AVVideoWidthKey:960, AVVideoHeightKey:480])
        if assetWriter.canAdd(writerInput) {
            assetWriter.add(writerInput)
        }
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: .zero)
        group.enter()
        writerInput.requestMediaDataWhenReady(on: readerVideo) { [self] in
            var finish: Bool = false
            while (writerInput.isReadyForMoreMediaData && !finish) {
                if let smbuffer = readerOutput.copyNextSampleBuffer() {
                    self.avplayerView.enqueue(smbuffer)
                    if !writerInput.append(smbuffer) {
                        print("error:\(assetWriter.error)")
                        writerInput.markAsFinished()
                        assetWriter.endSession(atSourceTime: asset.duration)
                        print("hello")
                        finish = true
                        group.leave()
                    } else {
                        print("--------")
                    }
                } else {
                    print("error:\(assetWriter.error)")
                    writerInput.markAsFinished()
                    assetWriter.endSession(atSourceTime: asset.duration)
                    finish = true
                    group.leave()
                }
            }
            
        }
        group.notify(queue: writerVideo, work: DispatchWorkItem.init(block: {
            self.assetWriter.finishWriting {
                print("ok")
            }
        }))
        
        
    }


}

