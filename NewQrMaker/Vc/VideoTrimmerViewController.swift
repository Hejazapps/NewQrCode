//
//  VideoTrimmerViewController.swift
//  TestVideoEdit
//
//  Created by Rafsan Nazmul on 10/11/2025.
//

import UIKit
import AVFoundation
import MobileCoreServices
import PryntTrimmerView
import SVProgressHUD
import Photos

class VideoTrimmerViewController: UIViewController {

    var videoURL: URL?
    
    private var player: AVPlayer?
    private var playbackTimeCheckerTimer: Timer?
    private var cropSquareView: SmoothCropView?
    private var dimmingView: DimmingOverlayView?
    private var videoNaturalSize: CGSize = .zero
    
    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Nav_btn"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(
            red: 245/255,
            green: 245/255,
            blue: 245/255,
            alpha: 1
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let playerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(
            red: 245/255,
            green: 245/255,
            blue: 245/255,
            alpha: 1
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let trimmerView: TrimmerView = {
        let trimmer = TrimmerView()
        trimmer.translatesAutoresizingMaskIntoConstraints = false
        return trimmer
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 30
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Video"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let exportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Export GIF", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var playerViewWidthConstraint: NSLayoutConstraint?
    private var playerViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupUI()
        setupTrimmerView()
        
        if let url = videoURL {
            loadAsset(from: url)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if cropSquareView != nil {
            updateCropOverlayFrames()
        }
    }
    
    deinit {
        cleanup()
    }
    
    private func setupUI() {
        view.addSubview(playerContainerView)
        playerContainerView.addSubview(playerView)
        view.addSubview(trimmerView)
        view.addSubview(playButton)
        view.addSubview(exportButton)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.backgroundColor =  UIColor(
            red: 245/255,
            green: 245/255,
            blue: 245/255,
            alpha: 1
        )
        
        setupConstraints()
        
        backButton.addTarget(self, action: #selector(backBtnPressed), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(exportBtnPressed), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
          
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor, multiplier: 216.0/368.0),
            
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            playerContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            playerContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playerContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            playerContainerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            
            playerView.centerXAnchor.constraint(equalTo: playerContainerView.centerXAnchor),
            playerView.centerYAnchor.constraint(equalTo: playerContainerView.centerYAnchor),
            playerView.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor),
            playerView.topAnchor.constraint(equalTo: playerContainerView.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor),
            
            playButton.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 60),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            
            trimmerView.topAnchor.constraint(equalTo: playerContainerView.bottomAnchor, constant: 24),
            trimmerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trimmerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trimmerView.heightAnchor.constraint(equalToConstant: 60),
            
            exportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            exportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            exportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            exportButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setupTrimmerView() {
        trimmerView.handleColor = UIColor.white
        trimmerView.mainColor = UIColor.darkGray
    }
    
    func loadAsset(from url: URL) {
        let asset = AVURLAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                    return
                }
                
                self.videoNaturalSize = videoTrack.naturalSize
                
                let transform = videoTrack.preferredTransform
                let angle = atan2(transform.b, transform.a)
                
                if abs(angle) == .pi / 2 || abs(angle) == 3 * .pi / 2 {
                    self.videoNaturalSize = CGSize(
                        width: videoTrack.naturalSize.height,
                        height: videoTrack.naturalSize.width
                    )
                }
                
                self.updatePlayerViewSize()
                
                self.loadAsset(asset)
            }
        }
    }
    
    private func updatePlayerViewSize() {
        if let widthConstraint = playerViewWidthConstraint {
            widthConstraint.isActive = false
        }
        if let heightConstraint = playerViewHeightConstraint {
            heightConstraint.isActive = false
        }
        
        let screenWidth = view.bounds.width - 32
        let maxHeight = view.bounds.height * 0.5
        
        let aspectRatio = videoNaturalSize.width / videoNaturalSize.height
        
        var finalWidth: CGFloat
        var finalHeight: CGFloat
        
        if videoNaturalSize.width > videoNaturalSize.height {
            finalWidth = min(screenWidth, videoNaturalSize.width)
            finalHeight = finalWidth / aspectRatio
            
            if finalHeight > maxHeight {
                finalHeight = maxHeight
                finalWidth = finalHeight * aspectRatio
            }
        } else {
            finalHeight = min(maxHeight, videoNaturalSize.height)
            finalWidth = finalHeight * aspectRatio
            
            if finalWidth > screenWidth {
                finalWidth = screenWidth
                finalHeight = finalWidth / aspectRatio
            }
        }
        
        playerViewWidthConstraint = playerView.widthAnchor.constraint(equalToConstant: finalWidth)
        playerViewHeightConstraint = playerView.heightAnchor.constraint(equalToConstant: finalHeight)
        
        playerViewWidthConstraint?.isActive = true
        playerViewHeightConstraint?.isActive = true
        
        view.layoutIfNeeded()
    }

    func loadAsset(_ asset: AVAsset) {
        trimmerView.delegate = self
        trimmerView.asset = asset
        trimmerView.maxDuration = 5.0
        trimmerView.minDuration = 1.0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.addVideoPlayer(with: asset, playerView: self?.playerView ?? UIView())
            self?.setupCropOverlay()
        }
    }

    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(itemDidFinishPlaying(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        let layer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.clear.cgColor
        layer.frame = playerView.bounds
        layer.videoGravity = .resizeAspect
        playerView.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        playerView.layer.addSublayer(layer)
    }

    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player?.seek(to: startTime)
            if player?.timeControlStatus != .playing {
                player?.play()
            }
        }
    }
    
    func setupCropOverlay() {
        playerView.layoutIfNeeded()
        
        dimmingView?.removeFromSuperview()
        dimmingView = DimmingOverlayView(frame: playerView.bounds)
        playerView.addSubview(dimmingView!)
        
        cropSquareView?.removeFromSuperview()
        
        let size = min(playerView.bounds.width, playerView.bounds.height) * 0.7
        let x = (playerView.bounds.width - size) / 2
        let y = (playerView.bounds.height - size) / 2
        
        cropSquareView = SmoothCropView(frame: CGRect(x: x, y: y, width: size, height: size))
        cropSquareView?.delegate = self
        cropSquareView?.containerBounds = playerView.bounds
        playerView.addSubview(cropSquareView!)
        
        dimmingView?.setCropFrame(cropSquareView!.frame)
    }
    
    func updateCropOverlayFrames() {
        dimmingView?.frame = playerView.bounds
        cropSquareView?.containerBounds = playerView.bounds
        updateDimmingOverlay()
    }
    
    func updateDimmingOverlay() {
        guard let cropFrame = cropSquareView?.frame else { return }
        dimmingView?.setCropFrame(cropFrame)
    }

    @objc func backBtnPressed() {
        cleanup()
        self.dismiss(animated: true)
    }

    @objc func play() {
        guard let player = player else { return }

        if player.timeControlStatus != .playing {
            player.play()
            playButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            startPlaybackTimeChecker()
        } else {
            player.pause()
            playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            stopPlaybackTimeChecker()
        }
    }
    
    @objc func exportBtnPressed() {
        exportTrimmedAndCroppedVideo()
    }

    func exportTrimmedAndCroppedVideo() {
        guard let cropView = cropSquareView else {
            SVProgressHUD.showError(withStatus: "Crop area not set")
            return
        }
        
        stopVideoPlayback()
        
        SVProgressHUD.show(withStatus: "Processing video...")
        
        exportTrimmedVideo { [weak self] trimmedURL in
            guard let self = self, let url = trimmedURL else {
                SVProgressHUD.showError(withStatus: "Trimming failed")
                return
            }
            
            let cropFrame = cropView.frame
            let playerFrame = self.playerView.bounds
            
            self.cropAndExportAsGIF(videoURL: url, cropFrame: cropFrame, playerFrame: playerFrame) { gifURL in
                if let gifURL = gifURL {
                    SVProgressHUD.showSuccess(withStatus: "GIF exported!")
                    self.cleanup()
                    self.dismiss(animated: true) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kishor"), object: nil)
                    }
                } else {
                    SVProgressHUD.showError(withStatus: "Export failed")
                }
            }
        }
    }
    
    private func stopVideoPlayback() {
        player?.pause()
        stopPlaybackTimeChecker()
        playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
    }
    
    private func cleanup() {
        stopVideoPlayback()
        player?.replaceCurrentItem(with: nil)
        player = nil
        
        NotificationCenter.default.removeObserver(self)
    }

    func exportTrimmedVideo(completion: @escaping (URL?) -> Void) {
        guard let asset = trimmerView.asset,
              let startTime = trimmerView.startTime,
              let endTime = trimmerView.endTime else {
            completion(nil)
            return
        }

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }

        let trimmedURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("trimmed_\(Int(Date().timeIntervalSince1970)).mp4")

        exportSession.outputURL = trimmedURL
        exportSession.outputFileType = .mp4
        exportSession.timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)

        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    completion(trimmedURL)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func cropAndExportAsGIF(videoURL: URL, cropFrame: CGRect, playerFrame: CGRect, completion: @escaping (URL?) -> Void) {
        let asset = AVURLAsset(url: videoURL)

        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(nil)
            return
        }
        
        debugPrintVideoTrackInfo(videoTrack)
        
        let videoSize = videoTrack.naturalSize
        let transform = videoTrack.preferredTransform
        
        var transformedSize = videoSize
        let originalAngle = atan2(transform.b, transform.a)
        if abs(originalAngle) == .pi / 2 || abs(originalAngle) == 3 * .pi / 2 {
            transformedSize = CGSize(width: videoSize.height, height: videoSize.width)
        }
        
        let scaleX = transformedSize.width / playerFrame.width
        let scaleY = transformedSize.height / playerFrame.height
        
        let videoCropRect = CGRect(
            x: cropFrame.origin.x * scaleX,
            y: cropFrame.origin.y * scaleY,
            width: cropFrame.width * scaleX,
            height: cropFrame.height * scaleY
        )
        
        let composition = AVMutableComposition()
        let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )
        
        do {
            try compositionVideoTrack?.insertTimeRange(
                CMTimeRangeMake(start: .zero, duration: asset.duration),
                of: videoTrack,
                at: .zero
            )
        } catch {
            completion(nil)
            return
        }
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: videoCropRect.width, height: videoCropRect.height)
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
        
        let t = videoTrack.preferredTransform
        let w = videoTrack.naturalSize.width
        let h = videoTrack.naturalSize.height
        let angle = atan2(t.b, t.a)
        
        var finalTransform = CGAffineTransform.identity
        
        if abs(angle - .pi / 2) < 0.01 {
            finalTransform = finalTransform.rotated(by: .pi / 2)
            finalTransform = finalTransform.translatedBy(x: 0, y: -h)
            finalTransform = finalTransform.translatedBy(
                x: -videoCropRect.origin.y,
                y: videoCropRect.origin.x
            )
            
        } else if abs(angle + .pi / 2) < 0.01 {
            finalTransform = finalTransform.rotated(by: -.pi / 2)
            finalTransform = finalTransform.translatedBy(x: -w, y: 0)
            finalTransform = finalTransform.translatedBy(
                x: videoCropRect.origin.y,
                y: -videoCropRect.origin.x
            )
            
        } else if abs(angle - .pi) < 0.01 || abs(angle + .pi) < 0.01 {
            finalTransform = finalTransform.rotated(by: .pi)
            finalTransform = finalTransform.translatedBy(x: -w, y: -h)
            finalTransform = finalTransform.translatedBy(
                x: -videoCropRect.origin.x,
                y: -videoCropRect.origin.y
            )
            
        } else {
            finalTransform = t
            finalTransform = finalTransform.translatedBy(
                x: -videoCropRect.origin.x,
                y: -videoCropRect.origin.y
            )
        }
        
        layerInstruction.setTransform(finalTransform, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            completion(nil)
            return
        }
        
        let croppedVideoURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("cropped_\(Int(Date().timeIntervalSince1970)).mp4")
        
        exportSession.outputURL = croppedVideoURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    self.convertVideoToGIF(videoURL: croppedVideoURL, completion: completion)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func convertVideoToGIF(videoURL: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVURLAsset(url: videoURL)
        let duration = asset.duration
        let durationSeconds = CMTimeGetSeconds(duration)
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(nil)
            return
        }
        
        let fps: Int32 = 15
        let frameCount = Int(durationSeconds * Double(fps))
        let timeInterval = durationSeconds / Double(frameCount)
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        
        let size = videoTrack.naturalSize
        generator.maximumSize = CGSize(width: min(size.width, 600), height: min(size.height, 600))
        
        var images: [UIImage] = []
        
        for i in 0..<frameCount {
            let time = CMTime(seconds: Double(i) * timeInterval, preferredTimescale: 600)
            
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                images.append(UIImage(cgImage: cgImage))
            } catch {
            }
        }
        
        if images.isEmpty {
            completion(nil)
            return
        }
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let defaults = UserDefaults.standard

        var fileIndex: Int
        if defaults.object(forKey: "customGIFIndex") == nil {
            fileIndex = 0
            defaults.set(1, forKey: "customGIFIndex")
        } else {
            fileIndex = defaults.integer(forKey: "customGIFIndex")
            defaults.set(fileIndex + 1, forKey: "customGIFIndex")
        }

        let gifURL = documents.appendingPathComponent("custom\(fileIndex).gif")
        
        guard let destination = CGImageDestinationCreateWithURL(
            gifURL as CFURL,
            kUTTypeGIF,
            images.count,
            nil
        ) else {
            completion(nil)
            return
        }
        
        let frameDelay = timeInterval
        let fileProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: 0
            ]
        ]
        
        let frameProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: frameDelay
            ]
        ]
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        for image in images {
            if let cgImage = image.cgImage {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
        }
        
        if CGImageDestinationFinalize(destination) {
            completion(gifURL)
        } else {
            completion(nil)
        }
    }
    
    func debugPrintVideoTrackInfo(_ videoTrack: AVAssetTrack) {
        let t = videoTrack.preferredTransform
        let angle = atan2(t.b, t.a)
    }

}

extension VideoTrimmerViewController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: .zero, toleranceAfter: .zero)
        updatePlaybackTime()
    }

    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.seek(to: playerTime, toleranceBefore: .zero, toleranceAfter: .zero)
        
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        updatePlaybackTime()
    }

    private func updatePlaybackTime() {
        guard let player = player, let startTime = trimmerView.startTime else { return }
        let playbackTime = player.currentTime() - startTime
    }

    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(onPlaybackTimeChecker),
            userInfo: nil,
            repeats: true
        )
    }

    func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }

    @objc func onPlaybackTimeChecker() {
        guard let startTime = trimmerView.startTime,
              let endTime = trimmerView.endTime,
              let player = player else {
            return
        }

        let playbackTime = player.currentTime()
        trimmerView.seek(to: playbackTime)

        if playbackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: .zero, toleranceAfter: .zero)
            trimmerView.seek(to: startTime)
        }

        updatePlaybackTime()
    }
}

extension VideoTrimmerViewController: CropViewDelegate {
    func cropViewDidChange(_ cropView: SmoothCropView) {
        updateDimmingOverlay()
    }
}

protocol CropViewDelegate: AnyObject {
    func cropViewDidChange(_ cropView: SmoothCropView)
}

class SmoothCropView: UIView {
    
    weak var delegate: CropViewDelegate?
    var containerBounds: CGRect = .zero
    
    private let borderWidth: CGFloat = 3
    private let minSize: CGFloat = 100
    private let hitAreaSize: CGFloat = 44
    private let buttonSize: CGFloat = 32
    private var initialFrame: CGRect = .zero
    
    enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    private var cornerHandles: [CornerHandle] = []
    private var resizeButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        backgroundColor = .clear
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = borderWidth
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        
        setupCornerHandles()
        setupResizeButton()
    }
    
    func setupCornerHandles() {
        let handleSize: CGFloat = 20
        let handle = CornerHandle(frame: CGRect(x: 0, y: 0, width: handleSize, height: handleSize))
        handle.backgroundColor = .white
        handle.layer.cornerRadius = handleSize / 2
        handle.corner = .bottomRight
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCornerPan(_:)))
        panGesture.delegate = self
        handle.addGestureRecognizer(panGesture)
        
        cornerHandles.append(handle)
        
        updateCornerHandlePositions()
    }
    
    func setupResizeButton() {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = buttonSize / 2
        button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleResizeTap(_:)))
        button.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleResizePan(_:)))
        button.addGestureRecognizer(panGesture)
        
        resizeButton = button
        addSubview(resizeButton!)
        
        updateResizeButtonPosition()
    }
    
    func updateResizeButtonPosition() {
        let offset: CGFloat = buttonSize / 2
        let x = bounds.width + offset
        let y = bounds.height + offset
        resizeButton?.center = CGPoint(x: x, y: y)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let resizeButton = resizeButton {
            let buttonPoint = convert(point, to: resizeButton)
            let expandedBounds = CGRect(
                x: -((hitAreaSize - buttonSize) / 2),
                y: -((hitAreaSize - buttonSize) / 2),
                width: hitAreaSize,
                height: hitAreaSize
            )
            
            if expandedBounds.contains(buttonPoint) {
                return resizeButton
            }
        }
        
        return super.hitTest(point, with: event)
    }
    
    @objc func handleResizeTap(_ gesture: UITapGestureRecognizer) {
        animateButtonTap()
        
        let scale: CGFloat = 1.2
        let newWidth = min(bounds.width * scale, containerBounds.width - frame.origin.x)
        let newHeight = min(bounds.height * scale, containerBounds.height - frame.origin.y)
        
        let newSize = min(newWidth, newHeight)
        let finalSize = max(newSize, minSize)
        
        frame = CGRect(x: frame.origin.x,
                      y: frame.origin.y,
                      width: finalSize,
                      height: finalSize)
        
        updateResizeButtonPosition()
        delegate?.cropViewDidChange(self)
    }
    
    @objc func handleResizePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        
        if gesture.state == .began {
            initialFrame = frame
            gesture.setTranslation(.zero, in: superview)
            animateButtonInteraction(started: true)
        }
        
        if gesture.state == .changed {
            let diagonalMovement = (translation.x + translation.y) / 2
            let proposedSize = initialFrame.width + diagonalMovement
            
            let maxSize = min(containerBounds.width - initialFrame.origin.x,
                            containerBounds.height - initialFrame.origin.y)
            let finalSize = max(minSize, min(proposedSize, maxSize))
            
            frame = CGRect(x: initialFrame.origin.x,
                          y: initialFrame.origin.y,
                          width: finalSize,
                          height: finalSize)
            
            updateResizeButtonPosition()
            setNeedsDisplay()
            delegate?.cropViewDidChange(self)
        }
        
        if gesture.state == .ended || gesture.state == .cancelled {
            initialFrame = .zero
            animateButtonInteraction(started: false)
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        
        if gesture.state == .changed {
            var newFrame = frame
            newFrame.origin.x += translation.x
            newFrame.origin.y += translation.y
            
            newFrame.origin.x = max(0, min(containerBounds.width - newFrame.width, newFrame.origin.x))
            newFrame.origin.y = max(0, min(containerBounds.height - newFrame.height, newFrame.origin.y))
            
            frame = newFrame
            gesture.setTranslation(.zero, in: superview)
            
            updateResizeButtonPosition()
            delegate?.cropViewDidChange(self)
        }
    }
    
    @objc func handleCornerPan(_ gesture: UIPanGestureRecognizer) {
        guard let handle = gesture.view as? CornerHandle,
              handle.corner == .bottomRight else { return }
        
        let translation = gesture.translation(in: superview)
        
        if gesture.state == .began {
            initialFrame = frame
            gesture.setTranslation(.zero, in: superview)
        }
        
        if gesture.state == .changed {
            let diagonalMovement = (translation.x + translation.y) / 2
            let proposedSize = initialFrame.width + diagonalMovement
            
            let maxSize = min(containerBounds.width - initialFrame.origin.x,
                            containerBounds.height - initialFrame.origin.y)
            let finalSize = max(minSize, min(proposedSize, maxSize))
            
            frame = CGRect(x: initialFrame.origin.x,
                          y: initialFrame.origin.y,
                          width: finalSize,
                          height: finalSize)
            
            updateResizeButtonPosition()
            setNeedsDisplay()
            delegate?.cropViewDidChange(self)
        }
        
        if gesture.state == .ended || gesture.state == .cancelled {
            initialFrame = .zero
        }
    }
    
    func updateCornerHandlePositions() {
        if let handle = cornerHandles.first {
            handle.frame.origin = CGPoint(x: bounds.width - 20/2,
                                         y: bounds.height - 20/2)
        }
        updateResizeButtonPosition()
    }
    
    private func animateButtonTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.resizeButton?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.resizeButton?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.resizeButton?.transform = .identity
                self.resizeButton?.backgroundColor = UIColor.systemBlue
            }
        }
    }
    
    private func animateButtonInteraction(started: Bool) {
        UIView.animate(withDuration: 0.2) {
            if started {
                self.resizeButton?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
                self.resizeButton?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } else {
                self.resizeButton?.backgroundColor = UIColor.systemBlue
                self.resizeButton?.transform = .identity
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.white.withAlphaComponent(0.5).cgColor)
        context?.setLineWidth(1)
        
        context?.move(to: CGPoint(x: bounds.width / 3, y: 0))
        context?.addLine(to: CGPoint(x: bounds.width / 3, y: bounds.height))
        context?.move(to: CGPoint(x: bounds.width * 2 / 3, y: 0))
        context?.addLine(to: CGPoint(x: bounds.width * 2 / 3, y: bounds.height))
        
        context?.move(to: CGPoint(x: 0, y: bounds.height / 3))
        context?.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 3))
        context?.move(to: CGPoint(x: 0, y: bounds.height * 2 / 3))
        context?.addLine(to: CGPoint(x: bounds.width, y: bounds.height * 2 / 3))
        
        context?.strokePath()
    }
}

extension SmoothCropView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

class CornerHandle: UIView {
    var corner: SmoothCropView.Corner?
}

class DimmingOverlayView: UIView {
    
    private var cropFrame: CGRect = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    func setCropFrame(_ frame: CGRect) {
        cropFrame = frame
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.black.withAlphaComponent(0.6).cgColor)
        context.fill(rect)
        
        context.setBlendMode(.clear)
        context.fill(cropFrame)
    }
}
