//
//  QRScannerController.swift
//  QRCodeScanner
//
//  Created by Nitin Aggarwal on 22/05/21.
//

import UIKit
import AVFoundation
import Photos
import ZXingObjC
import Vision
import FirebaseAnalytics

class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UNUserNotificationCenterDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var srttingsLabel: UILabel!
    @IBOutlet weak var settingsbTN: UIButton!
    var isCodeFound = false
    // MARK: - Properties
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var isPermissionGiven = false
    
    var scannedCode = Set<String>()
    var firstTime = true
    var startTime: TimeInterval = 0
    
    public var successBlock:((String)->())?
    
    @IBOutlet weak var grantAccessCode: UILabel!
    @IBOutlet weak var scanCode: UILabel!
    @IBOutlet weak var gotosettings: UIButton!
    @IBOutlet weak var permissionView: UIView!
    var shouldShowNow = true
    let flashButton = UIButton(type: .custom)
    let galleryButton = UIButton(type: .custom)
    let donebtn = UIButton(type: .custom)
    var count = -1
    var currentBarCode = ""
    var picker: UIImagePickerController?
    // MARK: - LifeCycle
    var alreadySelected = false
    
    let closeButton = UIButton(type: .custom)

    
    
    var codeArray = [CodeItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        permissionView.isHidden = true
        self.updateLabel()
        
    }
    
    
    @objc func handleCloseTapped() {
        captureSession?.stopRunning()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kishor"), object: nil)
        
    }
    
    
    func addCloseButton() {
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
        
        let topPadding = view.safeAreaInsets.top + 10
        closeButton.frame = CGRect(x: 20, y: topPadding, width: 40, height: 40)
        closeButton.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        
        view.addSubview(closeButton)
    }
    
    @objc private func handleDoneAction() {
        isFromMultiScan = false
        
        let uniqueCodeArray = Array(Set(codeArray))
        print("unique array i got \(uniqueCodeArray)")
        
        var value = Store.sharedInstance.isActiveSubscription()
        let defaults = UserDefaults.standard
        let visitCount = defaults.integer(forKey: "multiScanVisitCount")
        
        if value == false {
            
            
            if visitCount > 2 {
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let initialViewController = storyboard.instantiateViewController(withIdentifier: "SubscriptionVc") as! SubscriptionVc
//                initialViewController.modalPresentationStyle = .fullScreen
//                
//                if let topVC = UIApplication.topMostViewController {
//                    topVC.present(initialViewController, animated: true, completion: nil)
//                }
                return
            }
            
        }
        
        defaults.set(visitCount + 1, forKey: "multiScanVisitCount")
        if let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "MultiScanVc") as? MultiScanVc {
            vc.codeArray = uniqueCodeArray
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func updateLabel() {
        scanCode.text = scanCode.text?.localize()
        grantAccessCode.text = grantAccessCode.text?.localize()
        srttingsLabel.text  = "Go".localize()
        
    }
    
    func addFlashButton() {
        
        
        flashButton.setImage(UIImage(named: "Flash on"), for: UIControl.State.normal)
        
        flashButton.layer.cornerRadius = 25
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        let semi = UIColor.black.withAlphaComponent(0.2)
        flashButton.backgroundColor = semi
        view.addSubview(flashButton)
    }
    
    override func viewDidLayoutSubviews() {
        flashButton.frame = CGRect(x: (self.view.frame.size.width - 120) / 2.0 , y: self.view.frame.height - 100, width: 50, height: 50)
        galleryButton.frame = CGRect(x:flashButton.frame.origin.x + 10 + 60 , y: self.view.frame.height - 100, width: 50, height: 50)
        flashButton.bringSubviewToFront(self.view)
        galleryButton.bringSubviewToFront(self.view)
    }
    // Function to add gallery button
    func addGalleryButton() {
        
        
        
        
        galleryButton.setImage(UIImage(named: "gallery"), for: UIControl.State.normal)
        let semi = UIColor.black.withAlphaComponent(0.2)
        galleryButton.backgroundColor = semi
        galleryButton.layer.cornerRadius = 25
        galleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
       
        view.addSubview(galleryButton)
        
        // Add Done button manually
        
        donebtn.setTitle("Done".localize(), for: .normal)
        donebtn.setTitleColor(.white, for: .normal)
        donebtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        donebtn.addTarget(self, action: #selector(handleDoneAction), for: .touchUpInside)
        
        
        let topPadding = view.safeAreaInsets.top + 10
        donebtn.frame = CGRect(x: view.frame.width - 80, y: topPadding, width: 70, height: 40)
        donebtn.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        view.addSubview(donebtn)
        
        
    }
    
    
    @objc func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            try device.lockForConfiguration()
            if device.hasTorch {
                if device.torchMode == .on {
                    device.torchMode = .off
                    flashButton.setImage(UIImage(named: "Flash on"), for: UIControl.State.normal)
                } else {
                    try device.setTorchModeOn(level: 1.0)
                    flashButton.setImage(UIImage(named:"Flash off"), for: UIControl.State.normal)
                }
            }
            device.unlockForConfiguration()
        } catch {
            print("Flash could not be toggled.")
        }
    }
    
    // Action for opening the gallery
    @objc func openGallery() {
        
        
        self.photoLibraryAvailabilityCheck()
        
    }
    
    func photoLibraryAvailabilityCheck()
    {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                self.processSnapShotPhotos()
            case .restricted:
                self.showAlert()
            case .denied:
                self.showAlert()
            default:
                // place for .notDetermined - in this callback status is already determined so should never get here
                break
            }
        }
    }
    
    func showAlert()
    {
        alreadySelected = false
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "photos_access_required".localize(),
                message: "scan_codes_from_images_photos_access_required".localize(),
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "Cancel".localize(), style: .default, handler: { (alert) -> Void in
                
                
                
                
            }))
            alert.addAction(UIAlertAction(title: "allow_access".localize(), style: .default, handler: { (alert) -> Void in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func  processSnapShotPhotos() {
        
        
        DispatchQueue.main.async {
            
            guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
                print("Source type isn't available")
                return
            }
            
            if self.picker == nil {
                print("Picker is nil. Need to init picker")
                self.picker = UIImagePickerController()
                
                
                self.picker?.delegate = self
                self.picker?.sourceType = .savedPhotosAlbum
                self.picker?.mediaTypes = [UTType.image.identifier]
                self.picker?.modalPresentationStyle = .fullScreen
            }
            
            
            if let v =  self.picker {
                self.present(v,animated: true)
            }
            
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        count = -1
        // Check for camera permission has given or not.
        if isPermissionGiven {
            if (captureSession?.isRunning == false) {
                
                DispatchQueue.global().async {
                    self.captureSession.startRunning()
                }
            }
        } else {
            checkCameraPermission()
        }
        
        
        firstTime = true
        startTime = 0
        galleryButton.isHidden = false
        donebtn.isHidden = true
        donebtn.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        if isFromMultiScan {
            galleryButton.isHidden = true
            donebtn.isHidden = false
            
        }
        
         
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        shouldShowNow = true
        alreadySelected = false
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // stop capture session when this screen will disappear.
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    
    public func setupScanner(_ title:String? = nil, _ color:UIColor? = nil, _ style:ScanAnimationStyle? = nil, _ tips:String? = nil, _ success:@escaping ((String)->())){
        
        
        successBlock = success
        
    }
    
    
    @objc func openAppSpecificSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        let optionsKeyDictionary = [UIApplication.OpenExternalURLOptionsKey(rawValue: "universalLinksOnly"): NSNumber(value: true)]
        
        UIApplication.shared.open(url, options: optionsKeyDictionary, completionHandler: nil)
    }
    
    // MARK: - Private Methods
    private func initialSetup() {
        view.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
        
        let cancelButton = UIBarButtonItem(title: "Cancel".localize(), style: .done, target: self, action: #selector(handleCancelAction))
        cancelButton.tintColor = .white
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    @objc private func handleCancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func gotoView1(qrCodeLink:String) {
        
        let value2 = QrcOodearray.getArray(text: qrCodeLink)
        let value = QrParser.getBarCodeObj(text: qrCodeLink)
        
        let value3 = QrParser.getBarCodeObj(text: value)
        var type = ""
        if value.count > 0 {
            var outputResult = value.components(separatedBy: "^") as NSArray
            type = (outputResult[1] as? String)!
            print("bal = \(type)")
            
        }
        
        
        
        if isFromMultiScan {
            
            if captureSession?.isRunning == false {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.captureSession.startRunning()
                }
            }
            
            codeArray.append(CodeItem(codeType: type, code: value, isfromQr: true))
            
            return
        }
        
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVc") as! ShowResultVc
//        vc.stringValue = qrCodeLink
//        vc.modalPresentationStyle = .fullScreen
//        vc.showText = value
//        vc.currenttypeOfQrBAR = type
//        vc.createDataModelArray = value2
//        vc.isFromScanned = true
//        UIApplication.topMostViewController?.transitionVc(vc: vc, duration: 0.4, type: .fromRight)
        
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async { [self] in
                permissionView.isHidden = true
                self.isPermissionGiven = true
                self.setupCaptureSession()
            }
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                DispatchQueue.main.async {
                    if success {
                        self.isPermissionGiven = true
                        self.permissionView.isHidden = true
                        self.setupCaptureSession()
                    } else {
                        self.isPermissionGiven = false
                        self.accessDenied()
                    }
                }
            }
            
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isPermissionGiven = false
                self.accessDenied()
            }
            
        @unknown default:
            DispatchQueue.main.async {
                self.isPermissionGiven = false
                self.accessDenied()
            }
        }
    }
    
    @IBAction func gotoSettings(_ sender: Any) {
        
        self.openAppSpecificSettings()
        
    }
    
    func saveData() {
        
        
        
        
    }
    
    func didOutput(_ code: String ,type: String) {
        
        
        print("outpout  = \(code)")
        
        
        let b = UserDefaults.standard.integer(forKey: "vibrate")
        
        if b == 2 {
            print("Vibrating")
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        
        
        let shouldPlayCaptureSound = UserDefaults.standard.integer(forKey: "sound") == 2
        
        if shouldPlayCaptureSound {
            print("Playing capture")
            AudioServicesPlaySystemSound(SystemSoundID(1108))
        }
        
        
        let a = UserDefaults.standard.integer(forKey: "Link")
        
        if a == 2 {
            if code.containsIgnoringCase(find: "http") {
                guard let url = URL(string: code) else {
                    return //be safe
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                
                captureSession.startRunning()
                return
            }
        }
        
        
        
        
        let fullNameArr = type.components(separatedBy: ".")
        let name = fullNameArr[2] as? String
        let image = BarCodeGenerator.getBarCodeImage(type: name!, value: code)
        
        // print("image ratio size  = \(image!.size.width)")
        
        let v = QrcOodearray.getArray(text: code)
        
        
        if let value = image {
            
            
            if isFromMultiScan {
                
                if captureSession?.isRunning == false {
                    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                        self?.captureSession.startRunning()
                    }
                }
                
                codeArray.append(CodeItem(codeType: name ?? "", code: code, isfromQr: false))
                
                return
            }
            
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVc") as! ShowResultVc
//            vc.stringValue = code
//            vc.modalPresentationStyle = .fullScreen
//            vc.isFromScanned = true
//            vc.isfromQr = false
//            vc.currenttypeOfQrBAR = name!
//            transitionVc(vc: vc, duration: 0.4, type: .fromRight)
            
        }
        
        else {
            
            self.gotoView1(qrCodeLink: code)
            
        }
        
        captureSession.stopRunning()
        
        successBlock?(code)
        
    }
    
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        // Get the video capture device
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failedSession()
            return
        }
        
        // Lock the configuration safely
        do {
            try videoCaptureDevice.lockForConfiguration()
        } catch {
            print("Error locking configuration: \(error)")
            failedSession()
            return
        }
        
        // Set focus point (center of the screen)
        videoCaptureDevice.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
        videoCaptureDevice.focusMode = .autoFocus
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failedSession()
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failedSession()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Set metadata object types for QR and other barcodes
            if #available(iOS 15.4, *) {
                metadataOutput.metadataObjectTypes = [
                    .qr, .ean8, .ean13, .aztec, .pdf417,
                    .codabar, .code39, .code93, .dataMatrix, .upce, .code128
                ]
            } else {
                metadataOutput.metadataObjectTypes = [
                    .qr, .ean8, .ean13, .aztec, .pdf417,
                    .code39, .code93, .dataMatrix, .upce, .code128
                ]
            }
        } else {
            failedSession()
            return
        }
        
        // Set up the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Create a hollowed view for the focus area
        let holeWidth: CGFloat = 270
        let hollowedView = UIView(frame: view.frame)
        hollowedView.backgroundColor = .clear
        
        let hollowedLayer = CAShapeLayer()
        let focusRect = CGRect(x: (view.frame.width - holeWidth) / 2, y: (view.frame.height - holeWidth) / 2, width: holeWidth, height: holeWidth)
        let holePath = UIBezierPath(roundedRect: focusRect, cornerRadius: 12)
        let externalPath = UIBezierPath(rect: hollowedView.frame).reversing()
        holePath.append(externalPath)
        holePath.usesEvenOddFillRule = true
        
        hollowedLayer.path = holePath.cgPath
        hollowedLayer.fillColor = UIColor.clear.cgColor
        hollowedLayer.opacity = 1.0
        
        hollowedView.layer.addSublayer(hollowedLayer)
        view.addSubview(hollowedView)
        
        // Placeholder for scanner
        let scannerPlaceholderView = UIImageView(frame: focusRect)
        scannerPlaceholderView.contentMode = .scaleAspectFill
        scannerPlaceholderView.clipsToBounds = true
        view.addSubview(scannerPlaceholderView)
        view.bringSubviewToFront(scannerPlaceholderView)
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
        
        // Set the rect of interest for metadata
        metadataOutput.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: focusRect)
        
        self.addFlashButton()
        self.addGalleryButton()
        self.addCloseButton()
        
        do {
            try videoCaptureDevice.lockForConfiguration()
            defer { videoCaptureDevice.unlockForConfiguration() }
            
            if videoCaptureDevice.isFocusModeSupported(.continuousAutoFocus) {
                videoCaptureDevice.focusMode = .continuousAutoFocus
            }
            if videoCaptureDevice.isExposureModeSupported(.continuousAutoExposure) {
                videoCaptureDevice.exposureMode = .continuousAutoExposure
            }
        } catch {
            print("Error locking configuration: \(error)")
            failedSession()
            return
        }
    }
    
    private func failedSession() {
        captureSession = nil
        showAlert(message: "Your device does not support scanning a code from an item. Please use a device with a camera.")
    }
    
    private func accessDenied() {
        captureSession = nil
        permissionView.isHidden = false
        
    }
    
    
    @objc func tapped(sender : TapGesture) {
        captureSession.stopRunning()
        didOutput(sender.stringValue, type: sender.code)
    }
    
    @objc func autoTap(obj : singleTap) {
        captureSession.stopRunning()
        didOutput(obj.stringValue, type: obj.code)
    }
    
    
    func drawbox(bound: CGRect, scannedCode: String,code: String) {
        
        if shouldShowNow {
            shouldShowNow = false
            self.showToast(viewController: self, message: "Focus on Qr/Bar Code and touch the desired rectangale to detect")
        }
        let boxView = UIView()
        boxView.layer.borderColor = UIColor.green.cgColor
        boxView.layer.borderWidth = 5
        let tapGesture = TapGesture(target: self, action: #selector(tapped))
        tapGesture.stringValue = scannedCode
        tapGesture.code = code
        view.addSubview(boxView)
        boxView.frame = bound
        
        boxView.addGestureRecognizer(tapGesture)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            boxView.layer.borderColor = UIColor.clear.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            boxView.removeFromSuperview()
        }
    }
    
    
    func showToast(viewController: UIViewController?, message: String) {
        let alertDisapperTimeInSeconds = 5.0
        let toastLabel = UILabel(frame: CGRect(x: (self.view.frame.size.width - 330)/2.0, y: 100, width: 330, height: 100))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.numberOfLines = 0
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        viewController?.view.addSubview(toastLabel)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + alertDisapperTimeInSeconds) {
            toastLabel.alpha = 0.0
            toastLabel.removeFromSuperview()
        }
    }
    
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let actionButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(actionButton)
        present(alert, animated: true, completion: nil)
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("it has been called")
        
        Analytics.logEvent("Capture", parameters: nil)
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            print("wow \(stringValue)")
            
            // Stop scanning once a code is detected
            captureSession.stopRunning()
            self.didOutput(stringValue, type: readableObject.type.rawValue )
            // Process the scanned QR/Barcode value
            
        }
        
        
        
        
    }
    
    func barcodeFormatToString(format:ZXBarcodeFormat,value:String){
        switch (format) {
        case kBarcodeFormatAztec:
            currentBarCode = "Aztec"
            
        case kBarcodeFormatCodabar:
            currentBarCode = ""
            
        case kBarcodeFormatCode39:
            currentBarCode = "Code 39"
            
            
        case kBarcodeFormatCode128:
            currentBarCode = "Code 128"
            
        case kBarcodeFormatDataMatrix:
            currentBarCode = "Data Matrix"
            
        case kBarcodeFormatEan8:
            currentBarCode = "EAN-8"
            
        case kBarcodeFormatEan13:
            currentBarCode = "EAN-13"
            
        case kBarcodeFormatITF:
            currentBarCode = "ITF"
            
            
        case kBarcodeFormatUPCA:
            currentBarCode = "UPC-A"
            
        case kBarcodeFormatUPCE:
            currentBarCode = "UPC-E"
        default: break
            
        }
        
        self.setBarCode(currentBarCode: currentBarCode,value: value)
        
    }
    
    
    func setBarCode(currentBarCode:String,value:String)
    {
        print("halua1")
        alreadySelected = false
        if(currentBarCode.count < 1 && !isCodeFound)
        {
            print("halua2")
            let alert = UIAlertController(title: "Note".localize(), message: "Can not Detect Any Code!".localize(), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: {_ in
                
                
                
            }))
            
            DispatchQueue.main.sync {
                
                UIApplication.topMostViewController?.present(alert, animated: true, completion: {
                    
                })
            }
            
            
        }
        else
        
        {
            
            let image = BarCodeGenerator.getBarCodeImage(type: currentBarCode, value: value)
            
            
            if let value1 = image {
                
                if isFromMultiScan {
                    
                    if captureSession?.isRunning == false {
                          DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                              self?.captureSession.startRunning()
                          }
                      }
                    codeArray.append(CodeItem(codeType: currentBarCode, code: value, isfromQr: false))
                    
                    return
                }
                
                
//                isCodeFound = true
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVc") as! ShowResultVc
//                vc.stringValue = value
//                vc.modalPresentationStyle = .fullScreen
//                vc.image = image
//                vc.isFromScanned = true
//                vc.isfromQr = false
//                vc.currenttypeOfQrBAR = currentBarCode
//                vc.isFromGallery = true
//                
//                UIApplication.topMostViewController?.transitionVc(vc: vc, duration: 0.4, type: .fromRight)
                
                
            }
            else {
                
                print("halua")
                let alert = UIAlertController(title: "Note".localize(), message: "Can not Detect Any Code!".localize(), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: {_ in
                    
                    
                    
                    
                    
                }))
                DispatchQueue.main.sync {
                    
                    UIApplication.topMostViewController?.present(alert, animated: true, completion: {
                        
                    })
                }
                
            }
            
        }
    }
    
    
    @available(iOS 11.0, *)
    var vnBarCodeDetectionRequest : VNDetectBarcodesRequest{
        let request = VNDetectBarcodesRequest { (request,error) in
            
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                
                guard let observations = request.results as? [VNBarcodeObservation]
                else {
                    return
                }
                var type = ""
                var text = ""
                var barcodeBoundingRects = [CGRect]()
                for barcode in observations {
                    barcodeBoundingRects.append(barcode.boundingBox)
                    let barcodeType = String(barcode.symbology.rawValue)
                    if type.count == 0
                    {
                        type = String(barcode.symbology.rawValue).replacingOccurrences(of: "VNBarcodeSymbology", with: "")
                    }
                    if let payload = barcode.payloadStringValue {
                        text =  payload
                    }
                    
                    
                }
                
                
                if type.containsIgnoringCase(find: "ean13") {
                    self.currentBarCode = "EAN-13"
                    DispatchQueue.main.async {
                        self.setBarCode(currentBarCode: self.currentBarCode,value: text)
                    }
                    
                }
                
                else if type.containsIgnoringCase(find: "CODE128") {
                    self.currentBarCode = "Code 128"
                    DispatchQueue.main.async {
                        self.setBarCode(currentBarCode: self.currentBarCode,value: text)
                    }
                    
                }
                
                else if type.containsIgnoringCase(find: "CODE39") {
                    self.currentBarCode = "Code 39"
                    DispatchQueue.main.async {
                        self.setBarCode(currentBarCode: self.currentBarCode,value: text)
                    }
                    
                }
                
                else if type.containsIgnoringCase(find: "EAN8") {
                    self.currentBarCode = "EAN-8"
                    DispatchQueue.main.async {
                        self.setBarCode(currentBarCode: self.currentBarCode,value: text)
                    }
                    
                }
                
                else if type.containsIgnoringCase(find: "UPCA") {
                    self.currentBarCode = "UPC-A"
                    DispatchQueue.main.async {
                        self.setBarCode(currentBarCode: self.currentBarCode,value: text)
                    }
                    
                }
                
                else if type.containsIgnoringCase(find: "UPCE") {
                    self.currentBarCode = "UPC-E"
                    DispatchQueue.main.async {
                        self.setBarCode(currentBarCode: self.currentBarCode,value: text)
                    }
                    
                }
                else {
                    self.setBarCode(currentBarCode: "", value: "")
                }
            }
        }
        return request
    }
    
    
    
    @available(iOS 11.0, *)
    static var vnBarCodeDetectionRequest : VNDetectBarcodesRequest{
        let request = VNDetectBarcodesRequest { (request,error) in
            if let error = error as NSError? {
                
                DispatchQueue.main.async {
                    //IHProgressHUD.dismiss()
                }
                
                print("Error in detecting - \(error)")
                return
            }
            else {
                DispatchQueue.main.async {
                    // IHProgressHUD.dismiss()
                }
            }
        }
        return request
    }
    
    func selectedImage(selectedImage:UIImage) {
        
        
        print("hahahahhaha")
        let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let ciImage:CIImage=CIImage(image:selectedImage)!
        var qrCodeLink=""
        
        let features=detector.features(in: ciImage)
        for feature in features as! [CIQRCodeFeature] {
            qrCodeLink += feature.messageString!
        }
        
        if qrCodeLink=="" {
            
            let luminanceSource: ZXLuminanceSource = ZXCGImageLuminanceSource(cgImage:  selectedImage.cgImage)
            let binarizer = ZXHybridBinarizer(source: luminanceSource)
            let bitmap = ZXBinaryBitmap(binarizer: binarizer)
            let hints: ZXDecodeHints = ZXDecodeHints.hints() as! ZXDecodeHints
            let QRReader = ZXMultiFormatReader()
            currentBarCode = ""
            // throw/do/catch and all that jazz
            do {
                let result = try QRReader.decode(bitmap, hints: hints)
                self.barcodeFormatToString(format: result.barcodeFormat,value:result.text)
                
                
            } catch let err as NSError {
                
                // IHProgressHUD.show(withStatus: "Detecting ......")
                print("hahahahhaha1")
                self.createVisionRequest(image: selectedImage)
            }
        }else{
            //IHProgressHUD.dismiss()
            self.gotoView1(qrCodeLink: qrCodeLink)
        }
    }
    
    func createVisionRequest(image: UIImage)
    {
        guard let cgImage = image.cgImage else {
            return
        }
        if #available(iOS 11.0, *) {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            
            
            let vnRequests = [self.vnBarCodeDetectionRequest ]
            
            DispatchQueue.global(qos: .background).async {
                do{
                    try requestHandler.perform(vnRequests)
                    
                    
                    
                }catch let error as NSError {
                    print("Error in performing Image request: \(error)")
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        self.captureSession = nil
    }
}


class TapGesture: UITapGestureRecognizer {
    var stringValue = ""
    var code = ""
}

class singleTap: NSObject {
    var stringValue = ""
    var code = ""
}




extension ScannerVC {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let okImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            if alreadySelected {
                print("ttouched")
                return
            }
            picker.dismiss(animated: true) {
                self.selectedImage(selectedImage:okImage)
            }
        }
        alreadySelected = true
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel()")
        
        dismiss(animated: true) { [weak self] in
            
        }
    }
}


struct CodeItem: Hashable {
    var codeType: String
    var code: String
    var isfromQr: Bool
}

//  SwiftScanner
//
//  Created by Jason on 2018/11/30.
//  Copyright © 2018 Jason. All rights reserved.
//

import Foundation

public enum ScanAnimationStyle {
    /// 单线扫描样式
    case `default`
    /// 网格扫描样式
    case grid
}
