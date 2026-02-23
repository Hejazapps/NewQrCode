//
//  TemplateResultView.swift
//  testxib
//
//  Created by Rafsan Nazmul on 3/21/25.
//

import UIKit
import AVKit
import Vision
import CoreImage


protocol showAlertBv {
    func appearAlert()
    func doEmptyText()
}



class TemplateResultView: UIView {
    
    // MARK: - Outlets
    
    @IBOutlet weak var watermarkView: UIView!
    
    public var delegate: showAlertBv?
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var label1: UILabel!
    @IBOutlet private weak var closeButton1: UIButton!
    
    @IBOutlet private weak var imageViewBottomToContainerConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewBottomToLabel1Constraint: NSLayoutConstraint!
    @IBOutlet private weak var labelWidthConstraint: NSLayoutConstraint!
    
    private var isUpdatingLabel = false
    private var addTextButton: UIButton!
    private var templateImage: UIImage?
    private var qrCodeImage: UIImage?
    private var processedImage: UIImage?
    private var actualImageFrame: CGRect = .zero
    
    @IBOutlet weak var crossBtn: UIImageView!
    // MARK: - Public properties
    var onClose1Tapped: (() -> Void)?
    var onAddTextTapped: (() -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        configureUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("purchaseNoti"), object: nil)
        
        if (Store.sharedInstance.isActiveSubscription()) {
            crossBtn.isHidden = true
            watermarkView.isHidden = true
        }
    }
    
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        crossBtn.isHidden = true
        watermarkView.isHidden = true
        
        
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFromNib()
        configureUI()
    }
    
    // MARK: - Setup
    private func setupFromNib() {
        let bundle = Bundle(for: TemplateResultView.self)
        let nib = UINib(nibName: "TemplateResultView", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            print("Failed to load TemplateResultView from nib")
            return
        }
        addSubview(view)
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func configureUI() {
        containerView.layer.cornerRadius = 0
        containerView.clipsToBounds = true
        containerView.backgroundColor = .clear
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        
        label1.textColor = UIColor(red: 184/255, green: 134/255, blue: 68/255, alpha: 1.0)
        label1.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label1.textAlignment = .center
        label1.numberOfLines = 2
        
        if labelWidthConstraint != nil {
            labelWidthConstraint.constant = -24
        }
        
        closeButton1.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton1.tintColor = UIColor.gray
        closeButton1.addTarget(self, action: #selector(closeButton1Tapped), for: .touchUpInside)
        
        addTextButton = UIButton(type: .system)
        addTextButton.setImage(UIImage(systemName: "text.badge.plus"), for: .normal)
        addTextButton.tintColor = UIColor.systemBlue
        addTextButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        addTextButton.layer.cornerRadius = 20
        addTextButton.layer.shadowColor = UIColor.black.cgColor
        addTextButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        addTextButton.layer.shadowOpacity = 0.3
        addTextButton.layer.shadowRadius = 2
        addTextButton.addTarget(self, action: #selector(addTextButtonTapped), for: .touchUpInside)
        
        containerView.addSubview(addTextButton)
        
        addTextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addTextButton.widthAnchor.constraint(equalToConstant: 40),
            addTextButton.heightAnchor.constraint(equalToConstant: 40),
            addTextButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            addTextButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16)
        ])
        
        imageViewBottomToContainerConstraint.isActive = false
        
        if label1.text == nil || label1.text?.isEmpty == true {
            label1.isHidden = true
            closeButton1.isHidden = true
            updateLayout()
        }
        
        
        label1.isUserInteractionEnabled = true
        
        // Create a UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        
        // Add the gesture recognizer to the label
        label1.addGestureRecognizer(tapGesture)
        self.label1.alpha = 0
        
        
    }
    
    
    @IBAction func dismissTheView(_ sender: Any) {
        
        
        
    }
    
    @objc func labelTapped() {
        print("Label tapped!")
        delegate?.appearAlert()
        // Perform any action here
    }
    
    private func updateLabelWidthToMatchImage() {
        guard let image = imageView.image else { return }
        
        if imageView.bounds.size == .zero {
            layoutIfNeeded()
        }
        
        let imageAspectRatio = image.size.width / image.size.height
        let actualImageFrame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        
        print("Image View Bounds: \(imageView.bounds)")
        print("Actual Image Frame: \(actualImageFrame)")
        
        self.actualImageFrame = actualImageFrame
        
        var availableHeight = containerView.bounds.height
        if !label1.isHidden {
            let labelHeight = label1.intrinsicContentSize.height + 8
            availableHeight -= labelHeight
            
            if actualImageFrame.height > availableHeight {
                let newHeight = availableHeight
                let newWidth = newHeight * imageAspectRatio
                
                let xOffset = (imageView.bounds.width - newWidth) / 2
                
                self.actualImageFrame = CGRect(
                    x: xOffset,
                    y: 0,
                    width: newWidth,
                    height: newHeight
                )
            }
        }
        
        for constraint in label1.constraints {
            if constraint.firstAttribute == .width && constraint.firstItem === label1 {
                label1.removeConstraint(constraint)
            }
        }
        
        let padding: CGFloat = 16.0
        let maxWidth = self.actualImageFrame.width - padding
        
        print("Setting label width to: \(maxWidth)")
        
        let widthConstraint = NSLayoutConstraint(
            item: label1!,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: maxWidth
        )
        widthConstraint.identifier = "labelWidthConstraint"
        label1.addConstraint(widthConstraint)
        
        updateLabelCenterPosition(imageFrame: self.actualImageFrame)
        
        setNeedsLayout()
        layoutIfNeeded()
        
    }
    
    
    
    private func repositionLabelCenter(displayedWidth: CGFloat) {
        let centerX = imageView.bounds.width / 2
        
        if let existingConstraint = containerView.constraints.first(where: {
            ($0.firstItem === label1 && $0.firstAttribute == .centerX) ||
            ($0.secondItem === label1 && $0.secondAttribute == .centerX)
        }) {
            containerView.removeConstraint(existingConstraint)
        }
        
        let centerConstraint = NSLayoutConstraint(
            item: label1!,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0
        )
        containerView.addConstraint(centerConstraint)
    }
    
    func configure(withTemplate template: UIImage, qrCode: UIImage, text: String? = nil, completion: (() -> Void)? = nil) {
        self.templateImage = template
        self.qrCodeImage = qrCode
        
        processImagesWithRedZoneDetection()
        setLabelText(text)
        
        DispatchQueue.main.async {
            self.updateLabelWidthToMatchImage()
            completion?()
        }
    }

    func configure(with image: UIImage, text: String? = nil, completion: (() -> Void)? = nil) {
        imageView.image = image
        processedImage = image
        setLabelText(text)
        
        DispatchQueue.main.async {
            self.updateLabelWidthToMatchImage()
            completion?()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageView.image != nil && !label1.isHidden {
            if !isUpdatingLabel {
                isUpdatingLabel = true
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                    if let image = self.imageView.image {
                        let newFrame = AVMakeRect(aspectRatio: image.size, insideRect: self.imageView.bounds)
                        let frameDifferent = !newFrame.equalTo(self.actualImageFrame)
                        
                        if frameDifferent {
                            self.updateLabelWidthToMatchImage()
                        }
                    }
                    
                    self.isUpdatingLabel = false
                }
            }
        }
    }
    
    
    func setLabelText(_ text: String?) {
        if let text = text, !text.isEmpty {
            label1.text = text
            label1.isHidden = false
            closeButton1.isHidden = false
            label1.alpha = 1
            closeButton1.alpha = 1
        } else {
            label1.isHidden = true
            closeButton1.isHidden = true
        }
        
        updateLayout()
        
        if !label1.isHidden && imageView.image != nil {
            DispatchQueue.main.async {
                self.updateLabelWidthToMatchImage()
            }
        }
    }
    
    func makeLabelHidden(hidden:Bool)
    {
        self.label1.isHidden  = hidden
    }
    
    
    private func updateLabelCenterPosition(imageFrame: CGRect) {
        for constraint in containerView.constraints {
            if (constraint.firstItem === label1 && constraint.firstAttribute == .centerX) ||
                (constraint.secondItem === label1 && constraint.secondAttribute == .centerX) {
                containerView.removeConstraint(constraint)
            }
        }
        
        let centerConstraint = NSLayoutConstraint(
            item: label1!,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: containerView,
            attribute: .left,
            multiplier: 1.0,
            constant: imageFrame.midX
        )
        centerConstraint.identifier = "labelCenterXConstraint"
        containerView.addConstraint(centerConstraint)
    }
    
    func updateImage(_ image: UIImage) {
        imageView.image = image
        processedImage = image
        
        setNeedsLayout()
        
        DispatchQueue.main.async {
            self.updateLabelWidthToMatchImage()
        }
    }
    
    func updateQRCode(newQRCode: UIImage) {
        self.qrCodeImage = newQRCode
        
        guard let templateImage = self.templateImage else {
            print("No template image available to update QR code")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let redZoneMetrics = try self.detectRedZone(in: templateImage)
                
                let preparedQR = self.prepareQRCodeForOverlay(
                    qrImage: newQRCode,
                    redZoneRect: redZoneMetrics.bounds
                )
                
                let finalImage = self.overlayQRCode(
                    qrImage: preparedQR,
                    onto: templateImage,
                    at: redZoneMetrics.bounds
                )
                
                DispatchQueue.main.async {
                    self.imageView.image = finalImage
                    self.processedImage = finalImage
                    
                    if !self.label1.isHidden {
                        self.updateLabelWidthToMatchImage()
                    }
                }
            } catch {
                print("Error updating QR code: \(error)")
            }
        }
    }
    
    
    var labelText: String? {
        get {
            return label1.text
        }
    }
    
    var isLabelVisible: Bool {
        get {
            return !label1.isHidden
        }
    }
    
    // MARK: - Red Zone Detection and Image Processing
    private func processImagesWithRedZoneDetection() {
        guard let templateImage = templateImage, let qrCodeImage = qrCodeImage else {
            print("Missing template or QR code images")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let redZoneMetrics = try self.detectRedZone(in: templateImage)
                
                let preparedQR = self.prepareQRCodeForOverlay(
                    qrImage: qrCodeImage,
                    redZoneRect: redZoneMetrics.bounds
                )
                
                let finalImage = self.overlayQRCode(
                    qrImage: preparedQR,
                    onto: templateImage,
                    at: redZoneMetrics.bounds
                )
                
                DispatchQueue.main.async {
                    self.imageView.image = finalImage
                    self.processedImage = finalImage
                }
            } catch {
                print("Error processing images: \(error)")
                DispatchQueue.main.async {
                    self.imageView.image = templateImage
                }
            }
        }
    }
    
    
    struct RedZoneMetrics {
        let bounds: CGRect
        let center: CGPoint
        let imageSize: CGSize
    }
    
    enum DetectionError: Error {
        case imageConversionFailed
        case noRedAreaFound
        case processingFailed
    }
    
    private func detectRedZone(in image: UIImage) throws -> RedZoneMetrics {
        guard let cgImage = image.cgImage else {
            throw DetectionError.imageConversionFailed
        }
        
        let imageWidth = cgImage.width
        let imageHeight = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * imageWidth
        let bitsPerComponent = 8
        let bufferSize = bytesPerRow * imageHeight
        
        var redPixels = [(x: Int, y: Int)]()
        
        guard let context = CGContext(
            data: nil,
            width: imageWidth,
            height: imageHeight,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw DetectionError.processingFailed
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        
        guard let data = context.data else {
            throw DetectionError.processingFailed
        }
        
        let buffer = data.bindMemory(to: UInt8.self, capacity: bufferSize)
        
        for y in 0..<imageHeight {
            for x in 0..<imageWidth {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                
                if offset + 2 < bufferSize {
                    let red = buffer[offset]
                    let green = buffer[offset + 1]
                    let blue = buffer[offset + 2]
                    
                    if red >= 253 && green <= 2 && blue <= 2 {
                        redPixels.append((x: x, y: y))
                    }
                }
            }
        }
        
        if redPixels.isEmpty {
            print("No near-exact #FF0000 pixels found, trying exact match")
            for y in 0..<imageHeight {
                for x in 0..<imageWidth {
                    let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                    
                    if offset + 2 < bufferSize {
                        let red = buffer[offset]
                        let green = buffer[offset + 1]
                        let blue = buffer[offset + 2]
                        
                        if red == 255 && green == 0 && blue == 0 {
                            redPixels.append((x: x, y: y))
                        }
                    }
                }
            }
        }
        
        if redPixels.isEmpty {
            print("No #FF0000 pixels found, using center of image")
            let centerX = imageWidth / 2
            let centerY = imageHeight / 2
            let width = imageWidth / 5
            let height = imageHeight / 5
            
            for y in (centerY - height/2)...(centerY + height/2) {
                for x in (centerX - width/2)...(centerX + width/2) {
                    if x >= 0 && x < imageWidth && y >= 0 && y < imageHeight {
                        redPixels.append((x: Int(x), y: Int(y)))
                    }
                }
            }
        }
        
        let minX = redPixels.min { $0.x < $1.x }?.x ?? 0
        let minY = redPixels.min { $0.y < $1.y }?.y ?? 0
        let maxX = redPixels.max { $0.x < $1.x }?.x ?? 0
        let maxY = redPixels.max { $0.y < $1.y }?.y ?? 0
        
        let bounds = CGRect(
            x: CGFloat(minX) - 5,
            y: CGFloat(minY) - 5,
            width: CGFloat(maxX - minX) + 10,
            height: CGFloat(maxY - minY) + 10
        )
        
        let centerX = bounds.midX
        let centerY = bounds.midY
        let center = CGPoint(x: centerX, y: centerY)
        
        return RedZoneMetrics(
            bounds: bounds,
            center: center,
            imageSize: CGSize(width: imageWidth, height: imageHeight)
        )
    }
    
    private func overlayQRCode(qrImage: UIImage, onto templateImage: UIImage, at rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(templateImage.size, false, templateImage.scale)
        
        templateImage.draw(in: CGRect(origin: .zero, size: templateImage.size))
        
        let qrSize = qrImage.size
        let redZoneSize = rect.size
        
        var targetRect = rect
        if redZoneSize.width != redZoneSize.height {
            let minDimension = min(redZoneSize.width, redZoneSize.height)
            
            let xOffset = (redZoneSize.width - minDimension) / 2
            let yOffset = (redZoneSize.height - minDimension) / 2
            
            targetRect = CGRect(
                x: rect.origin.x + xOffset,
                y: rect.origin.y + yOffset,
                width: minDimension,
                height: minDimension
            )
        }
        
        qrImage.draw(in: targetRect)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage ?? templateImage
    }
    
    private func prepareQRCodeForOverlay(qrImage: UIImage, redZoneRect: CGRect) -> UIImage {
        let redZoneSize = redZoneRect.size
        
        UIGraphicsBeginImageContextWithOptions(redZoneSize, false, 0)
        
        let qrAspect = qrImage.size.width / qrImage.size.height
        let redZoneAspect = redZoneSize.width / redZoneSize.height
        
        var drawRect = CGRect(origin: .zero, size: redZoneSize)
        
        if qrAspect != redZoneAspect {
            if qrAspect > redZoneAspect {
                let newHeight = redZoneSize.width / qrAspect
                let yOffset = (redZoneSize.height - newHeight) / 2
                drawRect = CGRect(x: 0, y: yOffset, width: redZoneSize.width, height: newHeight)
            } else {
                let newWidth = redZoneSize.height * qrAspect
                let xOffset = (redZoneSize.width - newWidth) / 2
                drawRect = CGRect(x: xOffset, y: 0, width: newWidth, height: redZoneSize.height)
            }
        }
        
        qrImage.draw(in: drawRect)
        
        let resizedQR = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedQR ?? qrImage
    }
    
    private func updateLayout() {
        let labelHidden = label1.isHidden
        
        if labelHidden {
            self.imageViewBottomToLabel1Constraint.isActive = false
            self.imageViewBottomToContainerConstraint.isActive = true
            
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            })
        } else {
            layoutIfNeeded()
            
            self.imageViewBottomToContainerConstraint.isActive = false
            self.imageViewBottomToLabel1Constraint.isActive = true
            
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    if !self.label1.isHidden && self.imageView.image != nil {
                        self.updateLabelWidthToMatchImage()
                    }
                }
            })
        }
    }
    
    
    // MARK: - Actions
    @objc private func closeButton1Tapped() {
        delegate?.doEmptyText()
        label1.text = ""
        UIView.animate(withDuration: 0.3, animations: {
            self.label1.alpha = 0
            self.closeButton1.alpha = 0
        }) { _ in
            self.label1.isHidden = true
            self.closeButton1.isHidden = true
            
            self.updateLayout()
        }
        
        
        onClose1Tapped?()
    }
    
    @objc private func addTextButtonTapped() {
        onAddTextTapped?()
    }
    
    func getLabelDimensions() -> CGSize {
        guard let label = label1, !label.isHidden else {
            return CGSize.zero
        }
        return CGSize(width: label.frame.width, height: label.frame.height)
    }
    
    func setLabelDimensions(width: CGFloat) {
        // Remove any existing width constraints
        for constraint in label1?.constraints ?? [] {
            if constraint.firstAttribute == .width && constraint.firstItem === label1 {
                label1?.removeConstraint(constraint)
            }
        }
        
        guard let label = label1 else { return }
        
        let widthConstraint = NSLayoutConstraint(
            item: label,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: width
        )
        widthConstraint.identifier = "labelWidthConstraint"
        label.addConstraint(widthConstraint)
        
        setNeedsLayout()
        layoutIfNeeded()
        
        if let image = imageView.image {
            let actualImageFrame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
            updateLabelCenterPosition(imageFrame: actualImageFrame)
        }
    }
    
    
    func restoreLabelDimensions(width: CGFloat, height: CGFloat) {
        for constraint in label1.constraints {
            if constraint.firstAttribute == .width && constraint.firstItem === label1 {
                label1.removeConstraint(constraint)
            }
        }
        
        let widthConstraint = NSLayoutConstraint(
            item: label1!,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: width
        )
        widthConstraint.identifier = "labelWidthConstraint"
        label1.addConstraint(widthConstraint)
        
        setNeedsLayout()
        layoutIfNeeded()
        
        if let image = imageView.image {
            let actualImageFrame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
            updateLabelCenterPosition(imageFrame: actualImageFrame)
        }
    }
    
    // MARK: - Image Export
    func exportImage(size: CGSize = CGSize(width: 3000, height: 3000)) -> UIImage {
        let closeButtonWasVisible = !closeButton1.isHidden
        let addTextButtonWasVisible = !addTextButton.isHidden
        
        closeButton1.isHidden = true
        addTextButton.isHidden = true
        
        crossBtn.isHidden = true
        
     
        
        self.layoutIfNeeded()
        
        guard let sourceImage = processedImage ?? imageView.image else {
            closeButton1.isHidden = !closeButtonWasVisible
            addTextButton.isHidden = !addTextButtonWasVisible
            return UIImage()
        }
        
        let displayRect = AVMakeRect(aspectRatio: sourceImage.size, insideRect: imageView.bounds)
        
        let labelVisible = !label1.isHidden && label1.text?.isEmpty == false
        
        let containerRenderer = UIGraphicsImageRenderer(bounds: containerView.bounds)
        let viewCapture = containerRenderer.image { ctx in
            containerView.layer.render(in: ctx.cgContext)
        }
        
        
        let croppedViewCapture = cropHorizontally(viewCapture)
        
        if !labelVisible {
            closeButton1.isHidden = !closeButtonWasVisible
            addTextButton.isHidden = !addTextButtonWasVisible
            
            return createHighResolutionVersionOfImage(croppedViewCapture, targetSize: size, preserveAspectRatio: true)
        }
        
        closeButton1.isHidden = !closeButtonWasVisible
        addTextButton.isHidden = !addTextButtonWasVisible
        
        
        return createHighResolutionVersionOfImage(croppedViewCapture, targetSize: size, preserveAspectRatio: true)
    }
    
    
    private func cropHorizontally(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let width = cgImage.width
        let height = cgImage.height
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return image }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return image }
        
        let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * 4)
        
        var minX = width
        var maxX = 0
        
        for x in 0..<width {
            var hasContent = false
            
            for y in 0..<height {
                let offset = (y * width + x) * 4
                let alpha = buffer[offset + 3]
                let red = buffer[offset]
                let green = buffer[offset + 1]
                let blue = buffer[offset + 2]
                
                if alpha > 100 && !(red > 235 && green > 235 && blue > 235) {
                    hasContent = true
                    break
                }
            }
            
            if hasContent {
                minX = min(minX, x)
                maxX = max(maxX, x)
            }
        }
        
        /*// Add padding (5% of content width)
        // keeping trace to work later if needed // Rafsan
        let contentWidth = maxX - minX
        let padding = contentWidth / 20
        minX = max(0, minX - padding)
        maxX = min(width - 1, maxX + padding)*/
        
        // Make sure to found valid bounds
        if minX < maxX {
            let cropRect = CGRect(
                x: minX,
                y: 0,
                width: maxX - minX + 1,
                height: height
            )
            
            if let croppedCGImage = cgImage.cropping(to: cropRect) {
                return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
            }
        }
        
        return image
    }
    
    private func cropImageToContent(_ image: UIImage, targetSize: CGSize) -> UIImage {
        if !imageHasAlpha(image) {
            return createHighResolutionVersionOfImage(image, targetSize: targetSize, preserveAspectRatio: true)
        }
        
        guard let cgImage = image.cgImage else {
            return image
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return image
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else {
            return image
        }
        
        let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * 4)
        
        var minX = width, maxX = 0, minY = height, maxY = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let alpha = buffer[offset + 3]
                
                if alpha > 0 {
                    minX = min(minX, x)
                    maxX = max(maxX, x)
                    minY = min(minY, y)
                    maxY = max(maxY, y)
                }
            }
        }
        
        if minX < maxX && minY < maxY {
            let topPadding = 5
            let adjustedMinY = max(0, minY - topPadding)
            
            let cropRect = CGRect(
                x: minX,
                y: adjustedMinY,
                width: maxX - minX + 1,
                height: (maxY - adjustedMinY) + 1
            )
            
            if let croppedCGImage = cgImage.cropping(to: cropRect) {
                let croppedImage = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
                return createHighResolutionVersionOfImage(croppedImage, targetSize: targetSize, preserveAspectRatio: true)
            }
        }
        
        return createHighResolutionVersionOfImage(image, targetSize: targetSize, preserveAspectRatio: true)
    }
    
    private func imageHasAlpha(_ image: UIImage) -> Bool {
        guard let alphaInfo = image.cgImage?.alphaInfo else { return false }
        
        switch alphaInfo {
        case .first, .last, .premultipliedFirst, .premultipliedLast:
            return true
        default:
            return false
        }
    }
    
    private func createHighResolutionVersionOfImage(_ image: UIImage, targetSize: CGSize, preserveAspectRatio: Bool = true) -> UIImage {
        if !preserveAspectRatio {
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
            image.draw(in: CGRect(origin: .zero, size: targetSize))
            let highResImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return highResImage ?? image
        }
        
        let imageAspect = image.size.width / image.size.height
        let targetAspect = targetSize.width / targetSize.height
        
        var drawSize = targetSize
        
        if imageAspect > targetAspect {
            drawSize.height = targetSize.width / imageAspect
        } else if imageAspect < targetAspect {
            drawSize.width = targetSize.height * imageAspect
        }
        
        UIGraphicsBeginImageContextWithOptions(drawSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: drawSize))
        let highResImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return highResImage ?? image
    }
    
    private func renderCurrentViewAsImage(size: CGSize) -> UIImage {
        guard let displayedImage = imageView.image else {
            return UIImage()
        }
        
        let imageAspectRatio = displayedImage.size.width / displayedImage.size.height
        let displayedImageFrame = AVMakeRect(aspectRatio: displayedImage.size, insideRect: imageView.bounds)
        
        let labelVisible = !label1.isHidden && label1.text?.isEmpty == false
        
        let verticalPadding: CGFloat = 8.0
        let totalHeight = displayedImageFrame.height + (labelVisible ? label1.bounds.height + verticalPadding : 0)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: displayedImageFrame.width, height: totalHeight), false, 0)
        
        containerView.backgroundColor?.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: displayedImageFrame.width, height: totalHeight))
        
        displayedImage.draw(in: CGRect(
            x: 0,
            y: 0,
            width: displayedImageFrame.width,
            height: displayedImageFrame.height
        ))
        
        if labelVisible, let labelText = label1.text {
            let exportLabel = UILabel()
            exportLabel.text = labelText
            exportLabel.font = label1.font
            exportLabel.textColor = label1.textColor
            exportLabel.textAlignment = label1.textAlignment
            exportLabel.numberOfLines = label1.numberOfLines
            
            exportLabel.frame = CGRect(
                x: 0,
                y: displayedImageFrame.height + (verticalPadding / 2),
                width: displayedImageFrame.width,
                height: label1.bounds.height
            )
            
            exportLabel.drawText(in: exportLabel.frame)
        }
        
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let finalImage = compositeImage else {
            return UIImage()
        }
        
        let aspectRatio = finalImage.size.width / finalImage.size.height
        var targetSize = size
        
        if (size.width / size.height) > aspectRatio {
            targetSize.width = size.height * aspectRatio
        } else {
            targetSize.height = size.width / aspectRatio
        }
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        finalImage.draw(in: CGRect(origin: .zero, size: targetSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage ?? finalImage
    }
    
    func setLabelVisible(_ visible: Bool) {
        label1.isHidden = !visible
        closeButton1.isHidden = !visible
        
        if visible {
            label1.alpha = 1
            closeButton1.alpha = 1
        }
        
        updateLayout()
    }
    

    func updateLabelStyle(text: String? = nil, font: UIFont? = nil, size: CGFloat? = nil, fontName: String? = nil, color: UIColor? = nil) {

        // Text
        if let newText = text {
            setLabelText(newText)
        }
        
        // Get Current Font
        var currentFont = label1.font
        var shouldUpdateFont = false
        
        // New Font
        if let newFont = font {
            currentFont = newFont
            shouldUpdateFont = true
        }
        // Font Family
        else if let newFontName = fontName {
            let currentSize = currentFont?.pointSize ?? 16.0
            if let fontWithNewFamily = UIFont(name: newFontName, size: currentSize) {
                currentFont = fontWithNewFamily
                shouldUpdateFont = true
            }
        }
        // Font Size
        else if let newSize = size {
            if let fontName = currentFont?.fontName as String?,
               let fontWithNewSize = UIFont(name: fontName, size: newSize) {
                currentFont = fontWithNewSize
                shouldUpdateFont = true
            } else {
                // Fallback if we can't get the current font name
                currentFont = UIFont.systemFont(ofSize: newSize, weight: .medium)
                shouldUpdateFont = true
            }
        }
        
        // Apply font changes (optional)
        if shouldUpdateFont {
            label1.font = currentFont
        }
        
        // Apply color change (optional)
        if let newColor = color {
            label1.textColor = newColor
        }
        
        setNeedsLayout()
        layoutIfNeeded()
        
        if !label1.isHidden && imageView.image != nil {
            DispatchQueue.main.async {
                self.updateLabelWidthToMatchImage()
            }
        }
    }
    
    func updateTemplate(with newTemplate: UIImage, completion: (() -> Void)? = nil) {
        self.templateImage = newTemplate
        
        guard let qrCodeImage = self.qrCodeImage else {
            print("No QR code image available to overlay on the new template")
            imageView.image = newTemplate
            processedImage = newTemplate
            completion?()
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                //Detect the Red zone in the new templates - 1
                let redZoneMetrics = try self.detectRedZone(in: newTemplate)
                
                //QR code for overlay - 1
                let preparedQR = self.prepareQRCodeForOverlay(
                    qrImage: qrCodeImage,
                    redZoneRect: redZoneMetrics.bounds
                )
                
                //Overlay the QR code into the new template
                let finalImage = self.overlayQRCode(
                    qrImage: preparedQR,
                    onto: newTemplate,
                    at: redZoneMetrics.bounds
                )
                
                DispatchQueue.main.async {
                    self.imageView.image = finalImage
                    self.processedImage = finalImage
                    
                    //  Update the label positioning if it's visible
                    if !self.label1.isHidden {
                        self.updateLabelWidthToMatchImage()
                    }
                    
                    completion?()
                }
            } catch {
                print("Error updating template: \(error)")
                
                DispatchQueue.main.async {
                    //If we can't detect a red zone, just use the template as is
                    self.imageView.image = newTemplate
                    self.processedImage = newTemplate
                    completion?()
                }
            }
        }
    }
    
}
