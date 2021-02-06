
//  ViewController.swift
//  AVEditMac
//
//  Created by 刘东旭 on 2020/12/2.
//  Copyright © 2020 刘东旭. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit
import Dispatch

class ViewController: NSViewController {
    
    let avplayerView = AVSampleBufferDisplayLayer()
    let readerVideo = DispatchQueue(label: "videoReader")
    let writerVideo = DispatchQueue(label: "videoWriter")
    var assetReader: AVAssetReader!
    var readerOutput: AVAssetReaderTrackOutput!
    var assetWriter: AVAssetWriter!
    var writerInput: AVAssetWriterInput!
    let group = DispatchGroup()
    
    var composition = AVMutableComposition()

    @IBOutlet weak var contentView: NSView!
    override func viewDidLoad() {
        super.viewDidLoad()
        avplayerView.frame = CGRect(x: 0, y: 0, width: 360, height: 270)
        contentView.layer?.addSublayer(avplayerView)
//        ///添加视频轨道
//        guard let compositionVideoTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
//            return
//        }
//
//        ///添加音频轨道
//        guard let compositionAudioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
//            return
//        }
        
        let assetPath = Bundle.main.bundlePath + "/Contents/Resources" + "/123.mp4"
        let desPath = NSHomeDirectory() + "/Documents/123.mp4"
        print(desPath)
        let fm = FileManager.default
        if fm.fileExists(atPath: desPath) {
            try? fm.removeItem(atPath: desPath)
        }
        
//        do {
//            let assetPath = Bundle.main.bundlePath + "/Contents/Resources" + "/123.mp4"
//            let asset = AVAsset(url: URL(fileURLWithPath: assetPath))
//            try composition.insertTimeRange(CMTimeRange( start: .zero, duration: asset.duration), of: asset, at: .zero)
//        } catch {
//            print(error)
//        }
        
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private lazy var openPanel: NSOpenPanel = {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = true
        openPanel.message = "Choose the path"
        openPanel.allowedFileTypes = ["mp4","mov"]
        return openPanel
    }()

    @IBAction func openClick(_ sender: NSButton) {
        openPanel.beginSheetModal(for: NSApplication.shared.keyWindow!) { [self] (response) in
            if response == .OK {
                let urls = openPanel.urls
                urls.forEach { (url) in
                    do {
                        let asset = AVAsset(url: url)
                        try composition.insertTimeRange(CMTimeRange( start: composition.duration, duration: asset.duration), of: asset, at: .zero)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    @IBAction func export(_ sender: Any) {
        let desPath = NSHomeDirectory() + "/Documents/123.mp4"
//        AVExport.exportAsset(outputPath: desPath, timeline: <#T##AVEditTimeline#>) { (finish) in
//            print("hello")
//        }
//        return
        assetReader = try? AVAssetReader(asset: composition)
        readerOutput = AVAssetReaderTrackOutput(track: composition.tracks(withMediaType: .video)[0], outputSettings: [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_422YpCbCr8])
        if assetReader.canAdd(readerOutput) {
            assetReader.add(readerOutput)
        }
        assetReader.startReading()
        
        assetWriter = try! AVAssetWriter(outputURL: URL(fileURLWithPath: desPath), fileType: AVFileType.mp4)
        writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: [AVVideoCodecKey:AVVideoCodecType.h264 ,AVVideoWidthKey:composition.naturalSize.width, AVVideoHeightKey:composition.naturalSize.height])
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
    @IBOutlet weak var playerView: AVPlayerView!
    let llo = ResouceLoader()
    var player: AVPlayer!
    let asset = AVURLAsset(url: URL.init(string: "ldx://yuledy.helanzuida.com/20200505/3583_ef9af1c9/index.m3u8")!)
    @IBAction func playClick(_ sender: Any) {
        
        let loader = asset.resourceLoader
        loader.setDelegate(llo, queue: DispatchQueue(label: "hello"))

        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        playerView.player = player
        player.play()
    }
}

class ResouceLoader:NSObject, AVAssetResourceLoaderDelegate {
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if loadingRequest.request.url!.scheme == "ldx" {
            DispatchQueue.main.async {
                let u = NSHomeDirectory() + "/Documents/123456.mp4"
                let url = URL(fileURLWithPath: u)
                if FileManager.default.fileExists(atPath: url.absoluteString.replacingOccurrences(of: "file://", with: "")) {
                    let response = HTTPURLResponse.init(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
                    loadingRequest.response = response
                    let  d = try! Data(contentsOf: URL(fileURLWithPath: u))
                    loadingRequest.dataRequest?.respond(with: d)
                    loadingRequest.finishLoading()
                } else {
//                    let session = AVAssetDownloadURLSession()
//                    session.assetDownloadTaskWithURLAs
                    loadingRequest.finishLoading(with: nil)
                }
            }
            return true
        } else {
            return true
        }
        return false
    }
}
