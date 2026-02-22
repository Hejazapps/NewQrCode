//
//  CustomizeDesignViewController.swift
//  QrCodeMaker
//
//  Created by Sadiqul Amin on 6/7/23.
//

import UIKit
import QRCode
import AVFoundation


protocol sendImage {
    func sendScreenSort(image: UIImage, position: String, shape: String, logo: UIImage?, color1: UIColor, color2: UIColor,pupil:String,pupilc:UIColor?,eyec:UIColor?,shapec:UIColor?,eyeGradeint:Int,pupilGradent:Int,shapeGradeint:Int,background:UIImage?)
    
  
}

class CustomizeDesignViewController: UIViewController, UIColorPickerViewControllerDelegate, dismissTheView, sendcolor {
   
    func sendColorValue(color: UIColor, color1: UIColor) {
        // Convert UIColor to RGB tuple
        func rgb(from color: UIColor) -> (r: Int, g: Int, b: Int) {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: nil)
            return (
                r: Int(red * 255),
                g: Int(green * 255),
                b: Int(blue * 255)
            )
        }

        let startRGB = rgb(from: color)
        let endRGB = rgb(from: color1)

        // Prepare new gradient
        let newGradient = [[startRGB.r, startRGB.g, startRGB.b],
                           [endRGB.r, endRGB.g, endRGB.b]]

        // Fetch existing gradients or start fresh
        var existing = UserDefaults.standard.array(forKey: "userGradients") as? [[[Int]]] ?? []

        // Append the new gradient
        existing.append(newGradient)

        // Save updated list
        UserDefaults.standard.set(existing, forKey: "userGradients")
        
        
        var list = self.getUserGradients()
        
        mainGradientColor = gradientColors + list
        
        allView?.maingradientColors = mainGradientColor
        allView?.collectionView.reloadData()
       
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath = IndexPath(item: self.mainGradientColor.count - 1, section: 0)
            self.allView?.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
        
    }

    
    
    func getUserGradients() -> [[(r: Int, g: Int, b: Int)]] {
        guard let saved = UserDefaults.standard.array(forKey: "userGradients") as? [[[Int]]] else {
            return []
        }

        return saved.compactMap { pair in
            guard pair.count == 2,
                  pair[0].count == 3,
                  pair[1].count == 3 else { return nil }

            let start = (r: pair[0][0], g: pair[0][1], b: pair[0][2])
            let end = (r: pair[1][0], g: pair[1][1], b: pair[1][2])
            return [start, end]
        }
    }

    
    func addGradient() {
        print("add gradinet fixed")
        let  vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomGradientView") as! CustomGradientView
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        
        self.present(vc, animated: true) {
             
        }
    }
    
    func snedColoeDataf(color: Int, gradientpixelIndex: Int) {
        
       
        if color == 0 {
            eyeColor = nil
            eyeGradeint = gradientpixelIndex
        }
        if color == 1 {
            pupilColor = nil
            pupilGradent = gradientpixelIndex
        }
        if color == 2 {
            shapeColor = nil
            shapeGradeint = gradientpixelIndex
        }
        self.updateAll()
    }
    
    func setPupil(name: String) {
        print("pupil name \(name)")
        pupil = name
        self.updateAll()
    }
    
    func snedColoeData(color: UIColor, pixedlIndex: Int) {
       
        if pixedlIndex == 0 {
            eyeColor = color
            eyeGradeint = -1
        }
       
        if pixedlIndex == 1 {
            pupilColor = color
            pupilGradent = -1
        }
        if pixedlIndex == 2 {
            shapeColor = color
            shapeGradeint = -1
            
        }
        
        
        self.updateAll()
    }
    
    func snedColoeData(color: UIColor, index: Int) {
        if index == 0 {
            backgroundColor = color
            selectedIamge = nil
            self.updateAll()
        }
        else {
            foreGroundColor = color
            pupilColor = nil
            eyeColor = nil
            shapeColor = nil
            eyeGradeint = -1
            pupilGradent = -1
            shapeGradeint = -1
        }
        self.updateAll()
    }
    
    func sendBodyShape(name: String) {
        shape  = name
        self.updateAll()
    }
    
    func sendPositionMaker(name: String) {
         position = name
        
        self.updateAll()
    }
    
    func sendLgo(image: UIImage?) {
        logoImage = image
        self.updateAll()
    }
    
    func sendEmoji(image: UIImage) {
        logoImage = image
        self.updateAll()
    }
    
    func dismissAll() {
        
        
        UIView.animate(withDuration: 0.3) {
            self.collectionViewHolderView.alpha = 0
            
        }
         
    }
    
    var isforBackGroundImage = false
    
    var isFromGif = false
    
    @IBOutlet weak var imageHolderView: UIView!
    @IBOutlet weak var el: UILabel!
    @IBOutlet weak var cameraBtn: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var imv: UIImageView!
    var delegate: sendImage?
    @IBOutlet weak var logoImv: UIImageView!
 
    let path1 = Bundle.main.path(forResource: "Category", ofType: "plist")
    var categoryPlist:NSArray! = nil
    var stringValue:String = ""
    
    var storedOffsets = [Int: CGFloat]()
    let positionMaker = ""
    
    let doc = QRCode.Document()
    
    @IBOutlet weak var pupill: UILabel!
    @IBOutlet weak var screenSortView: UIView!
    
    @IBOutlet weak var pickerl: UILabel!
    @IBOutlet weak var gradientlabel: UILabel!
    @IBOutlet weak var pixelColor: UILabel!
    @IBOutlet weak var heightforSpect: NSLayoutConstraint!
    @IBOutlet weak var widthForImv: NSLayoutConstraint!
    var position = "square"
    var shape = "square"
    var pupil = "square"
    var logoImage:UIImage? = nil
    var foreGroundColor = UIColor.black
    var backgroundColor = UIColor.clear
    var isFromForGround  = true
    var currenttag = -1
    var currentIndex = -1
    var allView:AllView?
    var eyeColor:UIColor?
    var pupilColor:UIColor?
    var shapeColor:UIColor?
    var eyeGradeint  = -1
    var pupilGradent = -1
    var shapeGradeint = -1
    var selectedIamge:UIImage?
    @IBOutlet weak var photosHolderView: UIView!
    @IBOutlet weak var positionMakervalue: UILabel!
    @IBOutlet weak var bodyShape: UILabel!
    @IBOutlet weak var logolabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var collectionViewHolderView: UIView!
    @IBOutlet weak var galleryBtn: UILabel!
    var mainGradientColor = [[(r: Int, g: Int, b: Int)]]()
    @IBAction func gotoSave(_ sender: Any) {
        
        
//        if !Store.sharedInstance.isActiveSubscription() {
//            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let initialViewController = storyboard.instantiateViewController(withIdentifier: "SubscriptionVc") as! SubscriptionVc
//            initialViewController.modalPresentationStyle = .fullScreen
//            self.present(initialViewController, animated: true, completion: nil)
//            return
//            
//        }
        
        
        delegate?.sendScreenSort(image: imv.image!,position: position,shape:shape,logo: logoImage,color1: foreGroundColor,color2: backgroundColor, pupil: pupil,pupilc:pupilColor,eyec:eyeColor,shapec:shapeColor,eyeGradeint: eyeGradeint,pupilGradent: pupilGradent,shapeGradeint: shapeGradeint, background: selectedIamge)
       
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        view.window?.layer.add(transition, forKey: "leftToRightTransition")
        dismiss(animated: false, completion: nil)
        
      
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateImageViewLayout()
    }
   
    func updateImageViewLayout() {
        guard let image = imv.image else { return }
        imv.image = image

        let fittedRect = AVMakeRect(
            aspectRatio: image.size,
            insideRect: CGRect(
                x: 0,
                y: 0,
                width: screenSortView.bounds.width,
                height:screenSortView.bounds.height
            )
        )

        widthForImv.constant = fittedRect.width
        heightforSpect.constant = fittedRect.height
        self.view.layoutIfNeeded()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        print("nosto")
        return .darkContent
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
       
        
        backBtn.setTitle("Back".localize(), for: .normal)
        saveBtn.setTitle("Save".localize(), for: .normal)
        
        var list = self.getUserGradients()
        
        mainGradientColor = gradientColors + list
        
        allView?.maingradientColors = mainGradientColor
       
    }
    
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
       // tableView.reloadData()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerl.text = "Image Picker".localize()
        el.text = "Emoji".localize()
        pupill.text = "Pupil".localize()
        pixelColor.text = "Pixel Color".localize()
        gradientlabel.text = "Gradient".localize()
       // tableView.separatorColor = UIColor.clear
        categoryPlist = NSArray(contentsOfFile: path1!)
        colorLabel.text = "Color".localize()
        logolabel.text = "Logo".localize()
        bodyShape.text = "Body Shape".localize()
        positionMakervalue.text = "Position maker".localize()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("purchaseNoti"), object: nil)
        
        
      //  tableView.register(UINib(nibName: "HeaderViewTableViewCell", bundle: nil), forCellReuseIdentifier: "HeaderViewTableViewCell")
        
        
        allView  = AllView.loadFromXib()
        
        
        doc.utf8String =  stringValue
        doc.errorCorrection = .high
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
           
            self.addXibFile()
        }
        
        doc.design.backgroundColor(UIColor.clear.cgColor)
        
        
        for item in categoryPlist {
            print(item)
        }
        
        // Set the foreground color to blue
        self.updateAll()
        
        do {
            let image = try doc.uiImage(CGSize(width: 1000, height: 1000), dpi: 216)
            imv.image = image
        } catch {
            print("Error generating QR code image: \(error)")
            imv.image = nil
        }
        allView?.isFromGif = isFromGif
    
        // Do any additional setup after loading the view.
    }
    
    func addXibFile() {
        
      
        allView?.frame = CGRect(x: 0, y: 0, width: collectionViewHolderView.frame.size.width, height: collectionViewHolderView.frame.size.height)
        if let view  = allView {
            collectionViewHolderView.addSubview(view)
        }
       
        allView?.delegate = self
        
    }
    
    
   
    
    
    func updateShape(name:String) {
        
        shape  = name
        
        print("shape name \(shape)")
        if name.containsIgnoringCase(find: "hexagon") {
            doc.design.shape.onPixels = QRCode.PixelShape.Hexagon()
        }
        
        if name.containsIgnoringCase(find: "heart") {
            doc.design.shape.onPixels = QRCode.PixelShape.Heart()
        }
        
        if name.containsIgnoringCase(find: "arrow") {
            doc.design.shape.onPixels = QRCode.PixelShape.Arrow()
        }
        
        if name.containsIgnoringCase(find: "stich") {
            doc.design.shape.onPixels = QRCode.PixelShape.Stitch()
        }
        if name.containsIgnoringCase(find: "diamond") {
            doc.design.shape.onPixels = QRCode.PixelShape.Diamond()
        }
        if name.containsIgnoringCase(find: "shiny") {
            doc.design.shape.onPixels = QRCode.PixelShape.Shiny()
        }
        if name.containsIgnoringCase(find: "koala") {
            doc.design.shape.onPixels = QRCode.PixelShape.Koala()
        }
        if name.containsIgnoringCase(find: "wave") {
            doc.design.shape.onPixels = QRCode.PixelShape.Wave()
        }
        if name.containsIgnoringCase(find: "data_diagonal") {
            doc.design.shape.onPixels = QRCode.PixelShape.Diagonal()
        }
        
        if name.containsIgnoringCase(find: "vortex") {
            doc.design.shape.onPixels = QRCode.PixelShape.Vortex()
        }
        if name.containsIgnoringCase(find: "grid3x3") {
            doc.design.shape.onPixels = QRCode.PixelShape.Grid3x3()
        }
        if name.containsIgnoringCase(find: "grid4x4") {
            doc.design.shape.onPixels = QRCode.PixelShape.Grid4x4()
        }
        
        if name.containsIgnoringCase(find: "wex") {
            doc.design.shape.onPixels = QRCode.PixelShape.Wex()
        }
        
        if name.containsIgnoringCase(find: "data_donut") {
            doc.design.shape.onPixels = QRCode.PixelShape.Donut()
        }
        
        if name.containsIgnoringCase(find: "spikyCircle") {
            doc.design.shape.onPixels = QRCode.PixelShape.SpikyCircle()
        }
        if name.containsIgnoringCase(find: "horizontal") {
            doc.design.shape.onPixels = QRCode.PixelShape.Horizontal()
        }
        if name.containsIgnoringCase(find: "blob") {
            doc.design.shape.onPixels = QRCode.PixelShape.Blob()
        }
        if name.containsIgnoringCase(find: "pointy") {
            doc.design.shape.onPixels = QRCode.PixelShape.Pointy()
        }
        if name.containsIgnoringCase(find: "circle") {
            doc.design.shape.onPixels = QRCode.PixelShape.Circle()
        }
        if name.containsIgnoringCase(find: "curvepixel") {
            doc.design.shape.onPixels = QRCode.PixelShape.CurvePixel()
        }
        if name.containsIgnoringCase(find: "flower") {
            doc.design.shape.onPixels = QRCode.PixelShape.Flower()
        }
        if name.containsIgnoringCase(find: "roundedEndIndent") {
            doc.design.shape.onPixels = QRCode.PixelShape.RoundedEndIndent()
        }
        if name.containsIgnoringCase(find: "roundedPath") {
            doc.design.shape.onPixels = QRCode.PixelShape.RoundedPath()
        }
        if name.containsIgnoringCase(find: "roundedRect") {
            doc.design.shape.onPixels = QRCode.PixelShape.RoundedRect()
        }
        if name.containsIgnoringCase(find: "sharp") {
            doc.design.shape.onPixels = QRCode.PixelShape.Sharp()
        }
        if name.containsIgnoringCase(find: "shiny") {
            doc.design.shape.onPixels = QRCode.PixelShape.Shiny()
        }
        if name.containsIgnoringCase(find: "square") {
            doc.design.shape.onPixels = QRCode.PixelShape.Square()
        }
        if name.containsIgnoringCase(find: "squircle") {
            doc.design.shape.onPixels = QRCode.PixelShape.Squircle()
        }
        if name.containsIgnoringCase(find: "star") {
            doc.design.shape.onPixels = QRCode.PixelShape.Star()
        }
        if name.containsIgnoringCase(find: "vertical") {
            doc.design.shape.onPixels = QRCode.PixelShape.Vertical()
        }
        
    }
    
    
    func imageWithColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    
   
    
    func getImage(path:String)->UIImage? {
        
        if path.count < 1 {
            return nil
        }
        
        
        let index = Int(path)
        let value = "Logo"
        
        var tempArray: [String] = []
        var imGW:UIImage! = UIImage(named: "")
        if  let path2 =  Bundle.main.path(forResource: value, ofType: nil) {
            
            do {
                try  tempArray =  FileManager.default.contentsOfDirectory(atPath: path2) as [String]
            } catch {
            }
            
            tempArray = tempArray.sorted()
            
            
            
            if let filename  = tempArray[index ?? 0] as? String {
                let imagePath = "\(path2)/\(filename)"
                imGW = UIImage(named: imagePath)
                return imGW
            }
        }
        return nil
        
    }
    
    func updateImage(imGW:UIImage) {
        
        logoImv.image = imGW
//        let widthRatio = 0.2
//        let heightRatio = 0.2
//        let centerX = 0.5
//        let centerY = 0.5
//        doc.logoTemplate = QRCode.LogoTemplate(
//            image:  (imGW.cgImage!),
//            path: CGPath(
//                rect: CGRect(x: centerX - widthRatio / 2, y: centerY - heightRatio / 2, width: widthRatio, height: heightRatio),
//                transform: nil
//            )
//        )
        
    }
    
    
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            self.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func photoLibrary()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func gotoPreviousView(_ sender: Any) {
        
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        view.window?.layer.add(transition, forKey: "leftToRightTransition")
        dismiss(animated: false, completion: nil)
        
        
    }
    
    
    @IBAction func addAnImage(_ sender: Any) {
        isforBackGroundImage = true
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo".localize(), style: .default, handler: { _ in
            
            self.camera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo".localize(), style: .default, handler: { _ in
            
            self.photoLibrary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel".localize(), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func optionPressed(_ sender: Any) {
        
        var tag = (sender as AnyObject).tag - 200
        
        
        print("tag i found \(tag)")
        if tag  == 3 {
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Take Photo".localize(), style: .default, handler: { _ in
                
                self.camera()
            }))
            
            alert.addAction(UIAlertAction(title: "Choose Photo".localize(), style: .default, handler: { _ in
                
                self.photoLibrary()
            }))
            
            alert.addAction(UIAlertAction.init(title: "Cancel".localize(), style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        var isFromEmoji = false
        var isfromLogo = false
        var isFromPosition = false
        var isShape = false
        var isFromBBackrgound = false
        var isFromPupil = false
        var isFromPixel = false
        var isfromgradient = false
        switch tag {
        case 0:
            isFromEmoji = true
        case 1:
            isFromBBackrgound = true
        case 2:
            isfromLogo = true
        case 4:
            isFromPosition = true
        case 5:
            isShape = true
        case 6:
            isFromPupil = true
        case 7:
            isFromPixel = true
        case 8:
            isfromgradient = true
        default:
            break
        }

        allView?.setUp(
            isFromEmoji: isFromEmoji,
            isfromLogo: isfromLogo,
            isFromPosition: isFromPosition,
            isShape: isShape,
            isFromBBackrgound: isFromBBackrgound,
            isFromPupil: isFromPupil, isFromPiexl: isFromPixel, isfromGradient: isfromgradient
        )

        allView?.collectionView.reloadData()

        UIView.animate(withDuration: 0.3) {
            self.collectionViewHolderView.alpha = 1
        }

    }
    
    func cgColorFromRGB(_ rgb: (r: Int, g: Int, b: Int)) -> CGColor {
        return CGColor(
            red: CGFloat(rgb.r) / 255.0,
            green: CGFloat(rgb.g) / 255.0,
            blue: CGFloat(rgb.b) / 255.0,
            alpha: 1.0
        )
    }
    
  

    func applyGradient(index: Int, target: GradientTarget) {
        var list = self.getUserGradients()
        
        mainGradientColor = gradientColors + list
        
        
        print("i am getting index wow \(index) \(target)")
        guard index >= 0, index < mainGradientColor.count else { return }
        do {


            let gradientPair = mainGradientColor[index]
            let gradient = try DSFGradient(pins: [
                DSFGradient.Pin(cgColorFromRGB(gradientPair[0]), 0),
                DSFGradient.Pin(cgColorFromRGB(gradientPair[1]), 1)
            ])
            let radial = QRCode.FillStyle.RadialGradient(
                gradient,
                centerPoint: CGPoint(x: 0.5, y: 0.5)
            )
            switch target {
            case .eye:
                doc.design.style.eye = radial
            case .pupil:
                doc.design.style.pupil = radial
            case .onPixels:
                doc.design.style.onPixels = radial
            }
        } catch {
            print("Failed to create gradient: \(error)")
        }
    }
    
    func updatePosition(name: String) {
        
        position = name
        
        print("posiion name \(position)")
        
        if name.containsIgnoringCase(find: "eye_surroundingBars") {
            doc.design.shape.eye = QRCode.EyeShape.SurroundingBars()
        }
        if name.containsIgnoringCase(find: "eye_teardrop") {
            doc.design.shape.eye = QRCode.EyeShape.Teardrop()
        }
        
        
        if name.containsIgnoringCase(find: "eye_peacock") {
            doc.design.shape.eye = QRCode.EyeShape.Peacock()
        }
        
        if name.containsIgnoringCase(find: "eye_shield") {
            doc.design.shape.eye = QRCode.EyeShape.Shield()
        }
        if name.containsIgnoringCase(find: "eye_squarePeg") {
            doc.design.shape.eye = QRCode.EyeShape.Square()
        }
        if name.containsIgnoringCase(find: "eye_shield") {
            doc.design.shape.eye = QRCode.EyeShape.Shield()
        }
        if name.containsIgnoringCase(find: "eye_edges") {
            doc.design.shape.eye = QRCode.EyeShape.Edges()
        }
        if name.containsIgnoringCase(find: "eye_spikyCircle") {
            doc.design.shape.eye = QRCode.EyeShape.SpikyCircle()
        }
        if name.containsIgnoringCase(find: "eye_eye") {
            doc.design.shape.eye = QRCode.EyeShape.Eye()
        }
        if name.containsIgnoringCase(find: "eye_fireball") {
            doc.design.shape.eye = QRCode.EyeShape.Fireball()
        }
        if name.containsIgnoringCase(find: "eye_explode") {
            doc.design.shape.eye = QRCode.EyeShape.Explode()
        }
        if name.containsIgnoringCase(find: "eye_dotDragHorizontal") {
            doc.design.shape.eye = QRCode.EyeShape.DotDragHorizontal()
        }
        if name.containsIgnoringCase(find: "eye_dotDragVertical") {
            doc.design.shape.eye = QRCode.EyeShape.DotDragVertical()
        }
        if name.containsIgnoringCase(find: "eye_crt") {
            doc.design.shape.eye = QRCode.EyeShape.CRT()
        }
        if name.containsIgnoringCase(find: "eye_cloud") {
            doc.design.shape.eye = QRCode.EyeShape.Cloud()
        }
        if name.containsIgnoringCase(find: "eye_ufoRounded") {
            doc.design.shape.eye = QRCode.EyeShape.UFORounded()
        }
        if name.containsIgnoringCase(find: "eye_usePixelShape") {
            doc.design.shape.eye = QRCode.EyeShape.UsePixelShape()
        }
        if name.containsIgnoringCase(find: "headlight") {
            doc.design.shape.eye = QRCode.EyeShape.Headlight()
        }
        
        if name.containsIgnoringCase(find: "BarsHorizontal") {
            doc.design.shape.eye = QRCode.EyeShape.BarsHorizontal()
        }
        if name.containsIgnoringCase(find: "BarsVertical") {
            doc.design.shape.eye = QRCode.EyeShape.BarsVertical()
        }
        if name.containsIgnoringCase(find: "Circle") {
            doc.design.shape.eye = QRCode.EyeShape.Circle()
        }
        if name.containsIgnoringCase(find: "CorneredPixels") {
            doc.design.shape.eye = QRCode.EyeShape.CorneredPixels()
        }
        if name.containsIgnoringCase(find: "Leaf") {
            doc.design.shape.eye = QRCode.EyeShape.Leaf()
        }
        if name.containsIgnoringCase(find: "Pixels") {
            doc.design.shape.eye = QRCode.EyeShape.Pixels()
        }
        if name.containsIgnoringCase(find: "eye_roundedPointingOut") {
            doc.design.shape.eye = QRCode.EyeShape.RoundedPointingOut()
        }
        if name.containsIgnoringCase(find: "RoundedOuter") {
            doc.design.shape.eye = QRCode.EyeShape.RoundedOuter()
        }
        if name.containsIgnoringCase(find: "RoundedPointingIn") {
            doc.design.shape.eye = QRCode.EyeShape.RoundedPointingIn()
        }
        if name.containsIgnoringCase(find: "RoundedRect") {
            doc.design.shape.eye = QRCode.EyeShape.RoundedRect()
        }
        if name.containsIgnoringCase(find: "Square") {
            doc.design.shape.eye = QRCode.EyeShape.Square()
        }
        if name.containsIgnoringCase(find: "Squircle") {
            doc.design.shape.eye = QRCode.EyeShape.Squircle()
        }
        if name.containsIgnoringCase(find: "Shield") {
            doc.design.shape.eye = QRCode.EyeShape.Shield()
        }
        
    }

    
    func updateAll() {
        
        self.updatePosition(name: position)
        self.updateShape(name: shape)
        self.setPupilShape(for: pupil)
        doc.design.additionalQuietZonePixels = 0
        if let v = logoImage {
            self.updateImage(imGW: v)
        }
        else {
            doc.logoTemplate = nil
            logoImv.image  = nil
        }
        
        
        if isFromGif {
            
            backgroundColor =  UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            print("for gif color has changed")
        }
        doc.design.backgroundColor(backgroundColor.cgColor)
        doc.design.foregroundColor(foreGroundColor.cgColor)
       
      
        
        if let image = selectedIamge {
            doc.design.style.background = QRCode.FillStyle.Image(image: image)
            doc.design.additionalQuietZonePixels = 5
        }
        
        if let value = eyeColor {
            doc.design.style.eye = QRCode.FillStyle.Solid(value.cgColor)
        }  
        
        if let value = pupilColor {
            doc.design.style.pupil = QRCode.FillStyle.Solid(value.cgColor)
        }
        
        if let value = shapeColor {
            doc.design.style.onPixels = QRCode.FillStyle.Solid(value.cgColor)
        }
        
        applyGradient(index: eyeGradeint, target: .eye)
        applyGradient(index: pupilGradent, target: .pupil)
        applyGradient(index: shapeGradeint, target: .onPixels)

        
        do {
            let path = doc.path(CGSize(width: 1000, height: 1000))
            let image = try doc.uiImage(CGSize(width: 1000, height: 1000), dpi: 216)
            imv.image = image
            imv.backgroundColor = UIColor.clear
        } catch {
            print("Error generating QR code image: \(error)")
            imv.image = nil
        }
    }
    
    
    
    

    func setPupilShape(for imageName: String) {
        if imageName.contains("circle") {
            doc.design.shape.pupil = QRCode.PupilShape.Circle()
        } else if imageName.contains("corneredPixels") {
            doc.design.shape.pupil = QRCode.PupilShape.CorneredPixels(cornerRadiusFraction: 0.4)
        } else if imageName.contains("edges") {
            doc.design.shape.pupil = QRCode.PupilShape.Edges(cornerRadiusFraction: 0.3)
        } else if imageName.contains("roundedRect") {
            doc.design.shape.pupil = QRCode.PupilShape.RoundedRect()
        } else if imageName.contains("roundedPointingIn") {
            doc.design.shape.pupil = QRCode.PupilShape.RoundedPointingIn()
        } else if imageName.contains("squircle") {
            doc.design.shape.pupil = QRCode.PupilShape.Squircle()
        } else if imageName.contains("roundedOuter") {
            doc.design.shape.pupil = QRCode.PupilShape.RoundedOuter()
        } else if imageName.contains("square") {
            doc.design.shape.pupil = QRCode.PupilShape.Square()
        } else if imageName.contains("pixels") {
            doc.design.shape.pupil = QRCode.PupilShape.Pixels()
        } else if imageName.contains("leaf") {
            doc.design.shape.pupil = QRCode.PupilShape.Leaf()
        } else if imageName.contains("barsVertical") {
            doc.design.shape.pupil = QRCode.PupilShape.BarsVertical()
        } else if imageName.contains("barsHorizontal") {
            doc.design.shape.pupil = QRCode.PupilShape.BarsHorizontal()
        } else if imageName.contains("roundedPointingOut") {
            doc.design.shape.pupil = QRCode.PupilShape.RoundedPointingOut()
        } else if imageName.contains("shield") {
            doc.design.shape.pupil = QRCode.PupilShape.Shield(topLeft: true, topRight: true, bottomLeft: true, bottomRight: true)
        }
        else if imageName.contains("crossCurved") {
            doc.design.shape.pupil = QRCode.PupilShape.CrossCurved()
       }
        else if imageName.contains("blade") {
            doc.design.shape.pupil = QRCode.PupilShape.Blade()
       }
        else if imageName.contains("blobby") {
            doc.design.shape.pupil = QRCode.PupilShape.Blobby()
       }
        else if imageName.contains("explode") {
            doc.design.shape.pupil = QRCode.PupilShape.Explode()
       }
        else if imageName.contains("forest") {
            doc.design.shape.pupil = QRCode.PupilShape.Forest()
       }
        else if imageName.contains("pikyCircle") {
            doc.design.shape.pupil = QRCode.PupilShape.SpikyCircle()
       }
        else if imageName.contains("barsHorizontalSquare") {
            doc.design.shape.pupil = QRCode.PupilShape.BarsHorizontal()
       }
        else if imageName.contains("barsVerticalSquare") {
            doc.design.shape.pupil = QRCode.PupilShape.SquareBarsVertical()
       }
        else if imageName.contains("usePixelShape") {
            
            doc.design.shape.pupil = QRCode.PupilShape.UsePixelShape()
       }
        else if imageName.contains("ufoRounded") {
            
            doc.design.shape.pupil = QRCode.PupilShape.UFORounded()
       }
        
        else if imageName.contains("crt") {
            doc.design.shape.pupil = QRCode.PupilShape.CRT()
       }
        else if imageName.contains("cloud") {
            doc.design.shape.pupil = QRCode.PupilShape.Cloud()
       }
        else if imageName.contains("hexagonLeaf") {
            doc.design.shape.pupil = QRCode.PupilShape.HexagonLeaf()
       }
        else if imageName.contains("orbits") {
            doc.design.shape.pupil = QRCode.PupilShape.Orbits()
       }
        
        // no fallback, so if no match, pupil shape remains unchanged
    }


     

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let aspectRatio = image.size.width / image.size.height
        var newSize = targetSize
        
        // Maintain the aspect ratio
        if targetSize.width / aspectRatio > targetSize.height {
            newSize.width = targetSize.height * aspectRatio
        } else {
            newSize.height = targetSize.width / aspectRatio
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    
    @objc func cameraBtnTapped() {
        
        self.camera()
            
    }
    
    @objc func galleryBtnTapped() {
        
        self.photoLibrary()
            
    }
    
}

extension UIView{
    func dropShadowWithCornerRaduis(shouldShow:Bool = false) {
        layer.masksToBounds = true
        layer.cornerRadius = 10.0
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        if shouldShow {
            layer.borderWidth = 3.0
            layer.borderColor = tabBarBackGroundColor.withAlphaComponent(0.5).cgColor
        }
        else {
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
        }
    }
}



extension UIView {
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}



extension UserDefaults {
    
    func color(forKey key: String) -> UIColor? {
        
        guard let colorData = data(forKey: key) else { return nil }
        
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } catch let error {
            print("color error \(error.localizedDescription)")
            return nil
        }
        
    }
    
   
    
    func set(_ value: UIColor?, forKey key: String) {
        
        guard let color = value else { return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            set(data, forKey: key)
        } catch let error {
            print("error color key data not saved \(error.localizedDescription)")
        }
        
    }
    
}


extension CustomizeDesignViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            
            print("image called")
            
            self.dismiss(animated: true) { [self] in
                
                
                if  self.isforBackGroundImage {
                    var image = self.resizeImage(image: pickedImage, targetSize: CGSize(width: 1000, height: 1000))
                    backgroundColor = UIColor.clear
                    selectedIamge = image
                    self.updateAll()
                    self.isforBackGroundImage = false
                    return
                    
                }
                
                var image = self.resizeImage(image: pickedImage, targetSize: CGSize(width: 250, height: 250))
                self.logoImage = image
                
                self.updateAll()
                
            }
            
        }
        
        
    }
    
    
}


enum GradientTarget {
    case eye
    case pupil
    case onPixels
}
