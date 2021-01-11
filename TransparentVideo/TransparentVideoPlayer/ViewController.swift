//
//  ViewController.swift
//  TransparentVideoPlayer
//
//  Created by jia xiaodong on 7/23/20.
//  Copyright © 2020 homemade. All rights reserved.
//

import AVFoundation
import AVKit
import Cocoa

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let windows = NSApplication.shared.windows
        for i in windows {
            i.isOpaque = false
            i.backgroundColor = NSColor.clear
        }
        view.layer?.addSublayer(playerLayer)
        guard let videoPath = Bundle.main.path(forResource: "playdoh-bat", ofType: "mp4") else { return }
        let itemUrl = NSURL(fileURLWithPath: videoPath, isDirectory: false)
        let playerItem = createTransparentItem(url: itemUrl)
        playerLayer.player? = AVPlayer(playerItem: playerItem)
        playerLayer.player?.volume = 0.7
        playerLayer.player?.pause()
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: playerLayer.player?.currentItem)
        showMp4Effect()
        
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    // MARK: - Player Item Configuration
    
    func showMp4Effect() {
        playerLayer.player?.play()
    }
    
    @objc func didPlayToEndTime(noti: Notification) {
//        let item = noti.object as? AVPlayerItem
//        item?.seek(to: CMTime.zero)
//        playerLayer.player?.play()
        playerLayer.player?.seek(to: CMTime.zero)
        playerLayer.player?.play()
    }
    
    func createTransparentItem(url: NSURL) -> AVPlayerItem {
        let asset = AVAsset(url: url as URL)
        let playerItem = AVPlayerItem(asset: asset)
        // Set the video so that seeking also renders with transparency
        playerItem.seekingWaitsForVideoCompositionRendering = true
        // Apply a video composition (which applies our custom filter)
        playerItem.videoComposition = createVideoComposition(for: asset)
        return playerItem
    }

    func createVideoComposition(for asset: AVAsset) -> AVVideoComposition {
        let filter = AlphaFrameFilter(renderingMode: .colorKernel)
        let composition = AVMutableVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
            do {
                let (inputImage, maskImage) = request.sourceImage.verticalSplit()
                let outputImage = try filter.process(inputImage: inputImage, mask: maskImage)
                return request.finish(with: outputImage, context: nil)
            } catch {
                debugPrint("Video composition error")
                return request.finish(with: NSError(domain: "placeholder", code: 0, userInfo: nil))
            }
        })

        composition.renderSize = asset.videoSize.applying(CGAffineTransform(scaleX: 1.0, y: 0.5))
        return composition
    }
    
    lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: AVPlayer())
        let viewCenter = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        let anchorCenter = CGPoint(x: 0.5, y: 0.5)
        playerLayer.bounds = view.bounds
        playerLayer.position = viewCenter
        playerLayer.anchorPoint = anchorCenter
        playerLayer.fillMode = .both
        playerLayer.videoGravity = .resizeAspectFill // 视频填充模式
        playerLayer.pixelBufferAttributes = [
            (kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
        return playerLayer
    }()
    
}
