//
//  TemplateVc.swift
//  QrCodeNew
//
//  Created by SADIQUL AMIN IBNE AZAD on 6/3/25.
//

import UIKit
import FirebaseDatabase
import SDWebImage
import Reachability
import Siren
import MessageUI

var ref: DatabaseReference!
class TemplateVc: UIViewController, sendimageValue, MFMailComposeViewControllerDelegate {
    func sendUrl(name: String, fileName: String,catName:String) {
        
    }
    
    
    
    func sendimage(image: UIImage,fileName:String) {
        
        let pressedCount = UserDefaults.standard.integer(forKey: "rate_press_count")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if pressedCount <= 2 {
            
        }

        let createVC = storyboard.instantiateViewController(
            withIdentifier: "CreateQrVc"
        ) as! CreateQrVc

        createVC.modalPresentationStyle = .fullScreen
        createVC.isfromQr = true
        createVC.templateImage = image
        createVC.fileName = fileName

        UIApplication.topMostViewController?
            .transitionVc(vc: createVC, duration: 0.4, type: .fromRight)
       
        
    }
    
    var allView:CustomGifView?
     
    @IBOutlet weak var customGifView: UIView!
    @IBOutlet weak var customTemplateview: UIView!
    @IBOutlet weak var segmentView: HBSegmentedControl!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var nointernetSubTitle: UILabel!
    @IBOutlet weak var noInterlentlabel: UILabel!
    let reachability = try! Reachability()
    @IBOutlet weak var internetView: UIView!
    @IBOutlet weak var templateLabel: UILabel!
    @IBOutlet weak var collectionviewForTemplate: UICollectionView!
    @IBOutlet weak var collectionviewForText: UICollectionView!
    var totalCategory = [String]()
    var parsedTemplate: [String: [Dictionary<String,String>]] = [:]
    var currentItem = 0
    var shouldCalled = false
    
    var currewntGifindex = 0
    
    var customtemp:AllCustom?
    var shouldReset = false
    
    
    
    func addXibFile() {
        
      
        customtemp?.frame = CGRect(x: 0, y: 0, width: customTemplateview.frame.size.width, height: customTemplateview.frame.size.height)
        if let view  = customtemp {
            customTemplateview.addSubview(view)
        }
        
    }
    
    
    
    @IBAction func segmentIndexChanges(_ sender: UISegmentedControl) {
        currewntGifindex = sender.selectedSegmentIndex
        allView?.currentSelectedGif = currewntGifindex
        allView?.collectionView.reloadData()
        
        
        
        
    }
    
    func addXibFile1() {
        
      
        allView?.frame = CGRect(x: 0, y: 50, width: customGifView.frame.size.width, height: customGifView.frame.size.height - 50)
        if let view  = allView {
            customGifView.addSubview(view)
        }
        
    }
    
    
    @objc func reloadData5(notification: NSNotification) {
        
        self.allView?.shouldAnimateGifs  = true
        self.allView?.collectionView.reloadData()
        
        customGifView.alpha = 1
        
        
      
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reigsterXib()
        
       
        NotificationCenter.default.addObserver(self, selector:#selector(reloadData5(notification:)), name:NSNotification.Name(rawValue: "kishor1"), object: nil)

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.customtemp  = AllCustom.loadFromXib()
            self.allView = CustomGifView.loadFromXib()
            self.addXibFile()
            self.addXibFile1()
        }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged), name: .networkStatusChanged, object: nil)
        
        updateUI(NetworkMonitor.shared.isConnected)
        // Configure Cache - 1 week er jonno
        let cache = SDImageCache.shared
        cache.config.shouldUseWeakMemoryCache = true
        cache.config.shouldCacheImagesInMemory = true
        cache.config.maxMemoryCost = 200 * 1024 * 1024  // 200 MB memory cache
        cache.config.maxDiskSize = 500 * 1024 * 1024    // 500 MB disk cache
        cache.config.maxDiskAge = 7 * 24 * 60 * 60      // Cache images for 1 week
        
        // Configure downloader - 15 second dilam
        SDWebImageDownloader.shared.config.downloadTimeout = 15.0
        
        self.getAllData()
        templateLabel.text = "Templates".localize()
        noInterlentlabel.text = "No Internet".localize()
        nointernetSubTitle.text = "internet_connection".localize()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("purchaseNoti"), object: nil)
    }
    
    @objc func networkChanged() {
        let isConnected = NetworkMonitor.shared.isConnected
        DispatchQueue.main.async { [weak self] in
            self?.updateUI(isConnected)
        }
    }
    
    
    @IBAction func openTheApp(_ sender: Any) {
        
        if let url = URL(string: "https://apps.apple.com/app/id6738393609") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func shimmerText(label: UILabel) {
        // Remove existing observer (if any)
        NotificationCenter.default.removeObserver(label, name: UIApplication.willEnterForegroundNotification, object: nil)

        label.layoutIfNeeded()

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = label.bounds
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.name = "shimmerGradient"

        label.layer.mask = gradientLayer

        func addShimmerAnimation() {
            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [-1, -0.5, 0]
            animation.toValue = [1, 1.5, 2]
            animation.duration = 2
            animation.repeatCount = .infinity
            gradientLayer.add(animation, forKey: "shimmer")
        }

        addShimmerAnimation()

        // Re-apply shimmer when app returns to foreground
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
            addShimmerAnimation()
        }
    }

    
    @IBAction func suggestATemplate(_ sender: Any) {
        
        self.sendEmail(subject: "Suggest a template", mailAddress: "assistance.scannr@gmail.com", cc: "", meessage: "")
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    
    func sendEmail(subject:String?,mailAddress:String?,cc:String?,meessage:String?) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.modalPresentationStyle = .fullScreen
            if let mailAddressV = mailAddress
            {
                mail.setToRecipients([mailAddressV])
            }
            if let meessageV = meessage
            {
                mail.setMessageBody(meessageV, isHTML: false)
            }
            
            if let subjectV = subject
            {
                mail.setSubject(subjectV)
            }
            if let cctV = cc
            {
                mail.setCcRecipients([cctV])
            }
            mail.setMessageBody("Hi \n\n", isHTML: false)

            present(mail, animated: true)
            
        } else {
            let alert = UIAlertController(title: "Note".localize(), message: "email_not_configured".localize(), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func checkIfAppIsAvailable(appId: String, completion: @escaping (Bool) -> Void) {
        let urlString = "https://itunes.apple.com/lookup?id=\(appId)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let resultCount = json["resultCount"] as? Int
            else {
                completion(false)
                return
            }
            
            completion(resultCount > 0)
        }
        
        task.resume()
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        collectionviewForTemplate.reloadData()
        collectionviewForText.reloadData()
        
    }
    
    func updateUI(_ connected: Bool) {
        if connected {
            internetView.alpha = 0
        } else {
            internetView.alpha = 1
        }
        collectionviewForText.reloadData()
        collectionviewForTemplate.reloadData()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customtemp?.loadSavedIDs()
        Siren.shared.wail(performCheck: .onDemand)
        isFromMultiScan = false
        
        
        collectionviewForText.reloadData()
        collectionviewForTemplate.reloadData()
        addView.alpha = 0
        
        if shouldShowCustom {
            customTemplateview.alpha = 1
        }
        shouldShowCustom = false
        
        if changeToGif {
            
            self.allView?.shouldAnimateGifs  = true
            self.allView?.currentSelectedGif = 1
            
            self.allView?.collectionView.reloadData()
            changeToGif = false
            
            customGifView.alpha = 1
        }
        
        checkIfAppIsAvailable(appId: "6738393609") { isAvailable in
            
            DispatchQueue.main.async {
                if isAvailable {
                    
                    self.addView.alpha = 1
                    if Store.sharedInstance.isActiveSubscription() {
                        self.addView.alpha = 0
                    }
                }
            }
        }
        
    }
    
    @IBAction func gotoFavTemp(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "FavouriteVc") as! FavouriteVc
        initialViewController.modalPresentationStyle = .fullScreen
        initialViewController.delegate = self
        
        self.present(initialViewController, animated: true, completion: nil)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Template collection view frame: \(collectionviewForTemplate.frame)")
        print("Text collection view frame: \(collectionviewForText.frame)")
    }
    
    
    @objc func segmentValueChanged(_ sender: AnyObject?){
         
        
        if segmentView.selectedIndex == 0 {
            customTemplateview.alpha = 0
            customGifView.alpha = 0
             
        }else if segmentView.selectedIndex == 1{
            customTemplateview.alpha = 1
            customGifView.alpha = 0
        }else{
            
           
            self.allView?.shouldAnimateGifs  = true
            self.allView?.collectionView.reloadData()
            
            customGifView.alpha = 1
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    
        collectionviewForTemplate.reloadData()
    }
    
    func reigsterXib() {
        
        segmentView.items = ["Template".localize(), "Customized".localize(),"Gif".localize()]
        segmentView.borderColor = .clear
        segmentView.selectedLabelColor = .white
        segmentView.unselectedLabelColor = .black
        segmentView.backgroundColor = .white
       
        let red: CGFloat = 72 / 255.0
        let green: CGFloat = 116 / 255.0
        let blue: CGFloat = 241 / 255.0

        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        segmentView.thumbColor = color
        segmentView.selectedIndex = 0
        segmentView.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
        
        
        let nib = UINib(nibName: "TextCell", bundle: .main)
        collectionviewForText.register(nib, forCellWithReuseIdentifier: "TextCell")
        
        let nib1 = UINib(nibName: "TutotrialCell", bundle: .main)
        collectionviewForTemplate.register(nib1, forCellWithReuseIdentifier: "TutotrialCell")
        
        collectionviewForText.delegate = self
        collectionviewForText.dataSource = self
        
        collectionviewForTemplate.delegate = self
        collectionviewForTemplate.dataSource = self
        
        collectionviewForTemplate.isPagingEnabled = true
    }
    
    func prefetchTemplateImages() {
        var urlsToPreload: [URL] = []
        
        for (categoryKey, templates) in parsedTemplate {
            for template in templates {
                // Add thumbnail URLs for prefetching
                if let thumbnailString = template["thumbnail"],
                   let thumbnailURL = URL(string: thumbnailString) {
                    urlsToPreload.append(thumbnailURL)
                }
            }
        }
        
        if !urlsToPreload.isEmpty {
            print("Prefetching \(urlsToPreload.count) template images")
            SDWebImagePrefetcher.shared.prefetchURLs(urlsToPreload) { finishedCount, skippedCount in
                print("✅ Prefetched \(finishedCount) images, skipped \(skippedCount)")
            }
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == collectionviewForTemplate {
            let pageWidth = scrollView.frame.width
            currentItem = Int(scrollView.contentOffset.x / pageWidth)
            collectionviewForText.reloadData()
            collectionviewForTemplate.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.collectionviewForText.scrollToItem(at: IndexPath(item: self.currentItem, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
        
    }
    
    func getAllData(){
        
        ref = Database.database().reference()
        self.totalCategory.removeAll()
        
        ref.child("Template").observeSingleEvent(of: .value, with: { snapshot in
            // Convert snapshot data into a [String: Any] dictionary
            guard let templateData = snapshot.value as? [String: Any] else {
                print("Failed to cast snapshot to dictionary")
                return
            }
            
           
            if let barcodeArray = templateData["BarcodeKey"] as? [[String: Any]],
               let firstItem = barcodeArray.first,
               let barcodeKey = firstItem["key"] as? String {

            
                UserDefaults.standard.set(barcodeKey, forKey: "SavedBarcodeKey")
                   
                   // Make sure it's saved
                UserDefaults.standard.synchronize()
            }
            
            // Parse the data into [String: [String]]
            
            
            for (key, value) in templateData {
                print("Key found: \(key)")

                if let urlArray = value as? [[String: String]] {
                    
                    if key == "Gif" {
                        
                        print("GIF i found value")
                        gifData = urlArray
                        
                        self.allView?.collectionView.reloadData()
                        
                    }
                    else if key == "Customize" {
                        customizeData = urlArray
                        
                        print("customize value i found \(customizeData.count)")
                    } else {
                        self.parsedTemplate[key] = urlArray
                    }
                } else {
                    print("Unexpected data format for key: \(key), value: \(value)")
                }
            }
            
            let path1 = Bundle.main.path(forResource: "Tempalate", ofType: "plist")
            self.totalCategory = NSArray(contentsOfFile: path1!) as! [String]
            
            DispatchQueue.main.async {
                self.collectionviewForText.reloadData()
                self.collectionviewForTemplate.reloadData()
                self.prefetchTemplateImages()
            }
            
            
            
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
}

struct DriveLinks: Codable {
    let original: String?
    let thumbnail: String?
}

extension TemplateVc: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == collectionviewForTemplate {
            
            return CGSize(width: self.view.frame.size.width, height: collectionviewForTemplate.frame.size.height)
            
        }
        
        return CGSize(width: 100 , height: 40)
        
        
        // Adjust height if needed
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == collectionviewForTemplate{
            
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
        }
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == collectionviewForTemplate {
            return  0
        }
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collectionviewForTemplate {
            return  0
        }
        return 20
    }
}


extension TemplateVc: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return totalCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == collectionviewForTemplate {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TutotrialCell", for: indexPath) as! TutotrialCell
            cell.currentItem = currentItem
            cell.totalCategory = totalCategory
            cell.parsedTemplate = parsedTemplate
            cell.updateList()
          
            cell.delegate = self
            
            if shouldCalled {
                cell.isDownloded = false
                shouldCalled = false
                
            }
            if shouldReset {
                
                cell.selectedIndexPath = nil
                shouldReset = false
                
                
            }
            cell.collectionView.reloadData()
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
        cell.label.text = totalCategory[indexPath.row].localize()
        
        if currentItem == indexPath.row {
            cell.label.textColor = UIColor.blue.withAlphaComponent(0.6)
        }
        else {
            cell.label.textColor = UIColor.black
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        
        if collectionView == collectionviewForText {
            currentItem = indexPath.row
            self.shouldReset = true
            let currentOffset = collectionviewForTemplate.contentOffset
            
            // Modify only the X position (keeping the Y position the same)
            let newOffset = CGPoint(x: CGFloat(currentItem) * self.view.frame.size.width, y: currentOffset.y) // Change 100 to whatever horizontal offset you want
            // Set the content offset with or without animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.collectionviewForText.scrollToItem(at: IndexPath(item: self.currentItem, section: 0), at: .centeredHorizontally, animated: true)
                self.collectionviewForText.reloadData()
                self.collectionviewForTemplate.reloadData()
               
                
            }
            
            
            
            collectionviewForTemplate.setContentOffset(newOffset, animated: true)
            
            
        }
        else {
            
        }
    }
}




import UIKit

extension UIImage {
    func dominantColorPortion() -> String? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        guard let colorSpace = cgImage.colorSpace else { return nil }
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let pixelBuffer = context.data else { return nil }
        
        let pixels = pixelBuffer.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        var whiteCount = 0
        var blackCount = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                let r = pixels[offset]
                let g = pixels[offset + 1]
                let b = pixels[offset + 2]
                
                // Convert to brightness (0 = black, 255 = white)
                let brightness = (0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b))
                
                if brightness > 127 { // threshold: adjust as needed
                    whiteCount += 1
                } else {
                    blackCount += 1
                }
            }
        }
        
        return whiteCount > blackCount ? "Mostly White" : "Mostly Black"
    }
}
