//
//  AppGlobal.swift
//  LiveWallpaper
//
//  Created by Milan Mia on 9/9/17.
//  Copyright © 2017 Milan Mia. All rights reserved.
//


import SystemConfiguration
import SwiftyStoreKit
import UIKit
import ProgressHUD


var weeklyPrice = "2.99"
var monthlyPrice = "Try 3-days for free, then $5.99/Year"
var yearlyPrice = "Try 3-days for free, then $39.99/Year"
var oneTimePrice  = ""
let color1 = UIColor(red: 9/255.0, green: 73/255.0, blue: 143/255.0, alpha: 1.0)
let color2 = UIColor(red: 15/255.0, green: 125/255.0, blue: 245/255.0, alpha: 1.0)

var arrayForFont: NSArray!
var fontArray = [String]()
var tabBarUnSelectedColor = UIColor(red: 103.0/255.0, green: 175.0/255.0, blue: 255.0/255.0, alpha: 1)
var tabBarSelectedColor = UIColor.white
var tabBarBackGroundColor =  UIColor(red: 17.0/255.0, green: 130.0/255.0, blue: 254.0/255.0, alpha: 1)
var dotViewColor =  UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1)
var qrCategoryArray: NSArray!
var barCategoryArray: NSArray!
var selectedIndexList = [String]()

var backgroundColorValue:[UIColor] = []
var unselectedColor = UIColor(red: 152.0/255.0, green: 152.0/255.0, blue: 152.0/255.0, alpha: 1)
var currentIndexFolder = -1
var currentFolderName  = ""
var termsOfUseValue = "https://sites.google.com/view/scannr-terms"
var privacyPolicyValue = "https://sites.google.com/view/scannr-privacy"
var managesub = "https://sites.google.com/view/scannr-subscription-info"
var isEnabledF = false
var purchaseAlready = ""

var plistArray6: NSArray!
var titleColor = UIColor(red: 72.0/255.0, green: 116.0/255.0, blue: 241.0/255.0, alpha: 1)
let overLayHeight = 300
let canVasHeight = 280
let canvasWidth:CGFloat = 50
let shapeVcHeight = 350
let framesVcHeight = 300
var fliterArray:NSArray!
let adjustHeight = 150
let filterHeight = 300
var plistArray1: NSArray!
var plistArray: NSArray!
var shouldShowCustom = false
var shouldGotoDesign = false

var changeToGif = false
var isFromMultiScan = false

var customizeData: [[String: String]] = []
var gifData: [[String: String]] = []
func getFilteredImage(withInfo dict: [String : Any]?, for img: UIImage?) -> UIImage? {
    let filterName = dict?["filter"] as? String
    
    let context = CIContext(options: nil)
    let currentFilter = CIFilter(name: filterName ?? "")
    currentFilter?.setDefaults()
    
    var sourceCIImage: CIImage? = nil
    if let img {
        sourceCIImage = CIImage(image: img)
    }
    
    currentFilter?.setValue(
        sourceCIImage,
        forKey: kCIInputImageKey)
    let keys = dict?.keys
    keys?.forEach { key in
        let value = dict?[key] as? String
        if (key != "name") && (key != "filter") && (key != "color") && (key != "ImageName") {
            currentFilter?.setValue(
                NSNumber(value: Double(value ?? "") ?? 0.0),
                forKey: key)
        }
        if key == "color" {
            let colorValue = value?.components(separatedBy: ",")
            var r: Float
            var g: Float
            var b: Float
            r = Float(colorValue?[0] ?? "") ?? 0.0
            g = Float(colorValue?[1] ?? "") ?? 0.0
            b = Float(colorValue?[2] ?? "") ?? 0.0
            
            let color = CIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0))
            
            currentFilter?.setValue(color, forKey: "inputColor")
        }
        
    }
    let adjustedImage = currentFilter?.value(forKey: kCIOutputImageKey) as? CIImage
    var cgimg: CGImage? = nil
    if let adjustedImage {
        cgimg = context.createCGImage(adjustedImage, from: adjustedImage.extent)
    }
    var newImg: UIImage? = nil
    if let cgimg {
        newImg = UIImage(cgImage: cgimg)
    }
    return newImg
}

func getColor(colorString: String) -> UIColor {
    var array = colorString.components(separatedBy: ",")
    if let firstNumber = array[0] as? String,
       let secondNumber = array[1] as? String,
       let thirdNumber = array[2] as? String {
        
        if let f1  = Double(firstNumber.trimmingCharacters(in: .whitespacesAndNewlines)),
           let f2 = Double (secondNumber.trimmingCharacters(in: .whitespacesAndNewlines)),
           let f3 = Double(thirdNumber.trimmingCharacters(in: .whitespacesAndNewlines)) {
            
            return UIColor(red: f1/255.0 , green: f2/255.0 , blue: f3/255.0 , alpha: 1.0)
        }
    }
    
    return UIColor.black
}

func verifyRecieptR () {
    
    
    
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "94835c2bce2b460f880232ea40ab5568")
    
  
       
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
                
            case .success(let receipt):
                let productIds = Set([
                                        PoohWisdomProducts.weeklySub,
                                        PoohWisdomProducts.lifeTime])
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productIds) mama purchased since \(expiryDate)\n\(items)\n")
                   
                   
                    DispatchQueue.main.async {
                        ProgressHUD.dismiss()
                        let alert = UIAlertController(title: "", message: "RestoreD".localize(), preferredStyle: UIAlertController.Style.alert)
                          
                          // add an action (button)
                          alert.addAction(UIAlertAction(title: "ok".localize(), style:
                              UIAlertAction.Style.default, handler: nil))
                        if let topVC = UIApplication.topMostViewController {
                              topVC.present(alert, animated: true, completion: nil)
                          }
                    }
                    
                    
                case .expired(let expiryDate, let items):
                    print("\(productIds) mama expired since \(expiryDate)\n\(items)\n")
                  
                    
                    DispatchQueue.main.async {
                        ProgressHUD.dismiss()
                        let alert = UIAlertController(title: "", message: "NOTHING_TO_RESTORE".localize(), preferredStyle: UIAlertController.Style.alert)
                          
                          // add an action (button)
                          alert.addAction(UIAlertAction(title: "ok".localize(), style:
                              UIAlertAction.Style.default, handler: nil))
                        if let topVC = UIApplication.topMostViewController {
                              topVC.present(alert, animated: true, completion: nil)
                          }
                    }
                    
                    
                case .notPurchased:
                    DispatchQueue.main.async {
                        ProgressHUD.dismiss()
                       let alert = UIAlertController(title: "", message: "NOTHING_TO_RESTORE".localize(), preferredStyle: UIAlertController.Style.alert)
                          
                          // add an action (button)
                          alert.addAction(UIAlertAction(title: "ok".localize(), style:
                              UIAlertAction.Style.default, handler: nil))
                        if let topVC = UIApplication.topMostViewController {
                              topVC.present(alert, animated: true, completion: nil)
                          }
                    }
                     
                }
            case .error(let error):
                print("The user has never purchased")
            }
        }
        
    }
    

var dict = ["Image": "Enter Link/Text,Select an Image",
            "Email": "Enter Email Address,CC,Subject,Email Body",
            "Url": "Enter Url",
            "Phone": "Enter Phone Number",
            "SMS": "Enter Phone Number,Enter Message",
            "Text":"Enter Text"
            ,"vCard":"First Name:,Last Name:,Phone Number:,Email:,Organization:,Job Title:,Street,City,State,Country,Postal Code,Website",
             "vCard1":"First Name,Last Name,Phone,Email,Url,NickName,Address,Organization,Note,Birthday",
            "Facebook": "Enter FaceBook Link",
            "Instagram": "Enter Instagram Id",
            "Twitter": "Enter Twitter Id",
            "Skype": "Enter Skype Id",
            "Calendar": "EventName,EvenLocation,Note,StartDate,EndDate",
            "Google Map Location": "Enter Location Link",
            "AppStore": "Enter AppStore Link",
            "BarCode":"Text",
            "WIFI": "Enter Network Name,Enter Password,Enter Encription,Enter network status",
            "MMS": "Phone number,Body,Meesege"]

func generateBarCode(_ string: String) -> UIImage {
    
    if !string.isEmpty {
        
        let data = string.data(using: String.Encoding.ascii)
        
        let filter = CIFilter(name: "CICode128BarcodeGenerator")
        // Check the KVC for the selected code generator
        filter!.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let output = filter?.outputImage?.transformed(by: transform)
        
        return UIImage(ciImage: output!)
    } else {
        return UIImage()
    }
}


func checkWhichUrl (name:String) -> String {
    
    if name.containsIgnoringCase(find: "OneDrive") {
        return "One Drive"
    }
    
    if name.containsIgnoringCase(find: "Viber") {
        return "Viber"
    }
    
    if name.containsIgnoringCase(find: "Bing") {
        return "Bing Search"
    }
    
    if name.containsIgnoringCase(find: "/search") {
        return "Google Search"
    }
    
    if name.containsIgnoringCase(find: "Yahoo") {
        return "Yahoo"
    }
    
    if name.containsIgnoringCase(find: "Facebook") {
        return "Facebook"
    }
    
    if name.containsIgnoringCase(find: "Skype") {
        return "Skype"
    }
    
    if name.containsIgnoringCase(find: "apple") {
        return "App Store"
    }
    
    if name.containsIgnoringCase(find: "Instagram") {
        return "Instagram"
    }
    
    if name.containsIgnoringCase(find: "Twitter") {
        return "Twitter"
    }
    
    if name.containsIgnoringCase(find: "Drive") {
        return "Google Drive"
    }
    if name.containsIgnoringCase(find: "Tumblr") {
        return "Tumblr"
    }
    if name.containsIgnoringCase(find: "watch") {
        return "Youtube Video"
    }
    if name.containsIgnoringCase(find: "Youtube") {
        return "Youtube"
    }
    if name.containsIgnoringCase(find: "Pinterest") {
        return "Pinterest"
    }
    if name.containsIgnoringCase(find: "icloud") {
        return "iCloud"
    }
    
    if name.containsIgnoringCase(find: "Linkedin") {
        return "Linkedin"
    }
    if name.containsIgnoringCase(find: "dropbox") {
        return "Dropbox"
    }
    if name.containsIgnoringCase(find: "whatsapp") {
        return "WhatsApp"
    }
    if name.containsIgnoringCase(find: "Flickr") {
        return "Flickr"
    }
    
    if name.containsIgnoringCase(find: "Box") {
        return "Box"
    }
    
    if name.containsIgnoringCase(find: "plus.google") {
        return "Google Plus"
    }
    
    if name.containsIgnoringCase(find: "duckduckgo") {
        return "DuckDuck Go"
    }
    
    if name.containsIgnoringCase(find: "Tiktok") {
        return "Tiktok"
    }
    
    if name.containsIgnoringCase(find: "snapchat") {
        return "Snapchat"
    }
    
    if name.containsIgnoringCase(find: "wechat") {
        return "Wechat"
    }
    
    
    
    
    
    return ""
}

func showLifetimeAccessAlert() {
    
    let objViewcontroller = UIApplication.topMostViewController
    // Create the alert controller
    let alert = UIAlertController(
        title: "We_Honored_You_Now_Its_Your_Turn".localize(),
        message: "Exclusive_Lifetime_Access_Message".localize(),
        preferredStyle: .alert
    )
    
    // Add "Review" action
    let reviewAction = UIAlertAction(title: "Review".localize(), style: .default) { _ in
        // Handle review action (e.g., open the App Store review page)
        if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    alert.addAction(reviewAction)
    
    // Add "Maybe Later" action
    let maybeLaterAction = UIAlertAction(title: "May_be_Later".localize(), style: .cancel)
    alert.addAction(maybeLaterAction)
    if let topVC = UIApplication.topMostViewController {
        topVC.present(alert, animated: true, completion: nil)
    }
    
}

func saveImage(name:String,image:UIImage) {
    
    let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    // create a name for your image
    let fileURL = documentsDirectoryURL.appendingPathComponent(name)
    
    
    if FileManager.default.fileExists(atPath: fileURL.path) {
        // delete file
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
        } catch {
            print("Could not delete file, probably read-only filesystem")
        }
    }
    
    
    
    if !FileManager.default.fileExists(atPath: fileURL.path) {
        do {
            try image.pngData()!.write(to: fileURL)
            print("Image Added Successfully")
        } catch {
            print(error)
        }
    } else {
        print("Image Not Added")
    }
}

func saveImageInDocumentDirectory(image: UIImage, fileName: String) -> URL? {
    
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
    let fileURL = documentsUrl.appendingPathComponent(fileName)
    if let imageData = image.pngData() {
        try? imageData.write(to: fileURL, options: .atomic)
        return fileURL
    }
    return nil
}

func deleteImage(fileName: String) -> URL? {
    
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
    let fileURL = documentsUrl.appendingPathComponent(fileName)
    if FileManager.default.fileExists(atPath: fileURL.path) {
        // delete file
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
        } catch {
            print("Could not delete file, probably read-only filesystem")
        }
    }
    return nil
}

func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {
    
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
    let fileURL = documentsUrl.appendingPathComponent(fileName)
    do {
        let imageData = try Data(contentsOf: fileURL)
        return UIImage(data: imageData)
    } catch {}
    return nil
}

func isdigit(value:String)->Bool
{
    if value == "+"{
        return true
    }
    if value >= "0" && value <= "9" {
        return true
    }
    return false
}


func generateBarCodeAztech(_ string: String) -> UIImage {
    
    if !string.isEmpty {
        
        let data = string.data(using: String.Encoding.ascii)
        
        let filter = CIFilter(name: "CIAztecCodeGenerator")
        // Check the KVC for the selected code generator
        filter!.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let output = filter?.outputImage?.transformed(by: transform)
        
        return UIImage(ciImage: output!)
    } else {
        return UIImage()
    }
}

func generateBar417Barcode(_ string: String) -> UIImage {
    
    if !string.isEmpty {
        
        let data = string.data(using: String.Encoding.ascii)
        
        let filter = CIFilter(name: "CIPDF417BarcodeGenerator")
        // Check the KVC for the selected code generator
        filter!.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let output = filter?.outputImage?.transformed(by: transform)
        
        return UIImage(ciImage: output!)
    } else {
        return UIImage()
    }
}

func getScreenshot(view:UIView) -> UIImage? {
    //creates new image context with same size as view
    // UIGraphicsBeginImageContextWithOptions (scale=0.0) for high res capture
    UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0.0)
    
    // renders the view's layer into the current graphics context
    if let context = UIGraphicsGetCurrentContext() { view.layer.render(in: context) }
    
    // creates UIImage from what was drawn into graphics context
    let screenshot: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
    
    // clean up newly created context and return screenshot
    UIGraphicsEndImageContext()
    return screenshot
}

func getImage(image:UIImage) -> UIImage?
{
    let image = image
    
    UIGraphicsBeginImageContext(image.size)
    
    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
    
    let convertibleImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return convertibleImage
}

func customAttributedString(first: String, second: String, firstColor: UIColor = .black, secondColor: UIColor = .red, firstSize: CGFloat = 20,secondSize: CGFloat = 15) -> NSAttributedString {
    
    let styleAttributes = NSMutableParagraphStyle()
    let stringAttributes:[NSAttributedString.Key: Any] = [.font : (UIFont.boldSystemFont(ofSize: firstSize)),
                                                          .foregroundColor: firstColor,
                                                          .paragraphStyle: styleAttributes]
    
    let stringSecondAttributes:[NSAttributedString.Key: Any] = [.font : (UIFont.systemFont(ofSize: secondSize)),
                                                                .foregroundColor: secondColor,
                                                                .paragraphStyle: styleAttributes]
    
    let string = "  \(first)  ".uppercased()
    let secondString = "\n  \(second)  ".uppercased()
    let mutable = NSMutableAttributedString(string: string, attributes: stringAttributes)
    let secondMutable = NSMutableAttributedString(string: secondString, attributes: stringSecondAttributes)
    mutable.append(secondMutable)
    var startIndex = mutable.string.startIndex
    while let range = mutable.string.range(of: "\\n", options: .regularExpression, range: startIndex..<mutable.string.endIndex) {
        mutable.addAttribute(.backgroundColor, value: UIColor.yellow, range: NSRange(Range(uncheckedBounds: (lower: startIndex, upper: range.lowerBound)), in:  mutable.string))
        startIndex = range.upperBound
    }
    mutable.addAttribute(.backgroundColor, value: UIColor.red, range: NSRange(Range(uncheckedBounds: (lower: startIndex, upper:  mutable.string.endIndex)), in:  mutable.string))
    return mutable
}


let allShapes = [
  "circle",
  "corneredPixels",
  "edges",
  "roundedRect",
  "roundedPointingIn",
  "squircle",
  "roundedOuter",
  "square",
  "leaf",
  "barsVertical",
  "barsHorizontal",
  "roundedPointingOut",
  "shield",
  "crossCurved",
  "blade",
  "blobby",
  "explode",
  "forest",
  "pikyCircle",
  "ufoRounded",
  "crt",
  "cloud",
  "hexagonLeaf",
  "orbits"
]

let gradientColors: [[(Int, Int, Int)]] = [
    [(234, 132, 221), (151, 227, 239)],
    [(235, 83, 114), (243, 179, 157)],
    [(169, 160, 255), (205, 129, 231)],
    [(255, 227, 251), (196, 247, 255)],
    [(240, 138, 231), (255, 85, 124)],
    [(97, 144, 232), (167, 191, 232)],
    [(74, 250, 239), (224, 247, 147)],
    [(220, 234, 122), (187, 155, 247)],
    [(246, 205, 104), (255, 155, 106)],
    [(242, 216, 80), (246, 87, 170)],
    [(255, 176, 130), (255, 103, 226)],
    [(133, 117, 250), (215, 124, 237)],
    [(4, 190, 253), (134, 251, 183)],
    [(234, 138, 151), (174, 187, 243)],
    [(55, 240, 203), (238, 237, 64)],
    [(246, 198, 249), (172, 147, 255)],
    [(255, 138, 173), (159, 255, 173)],
    [(85, 187, 249), (169, 252, 185)],
    [(239, 98, 159), (238, 205, 163)],
    [(156, 233, 164), (214, 113, 142)],
    [(239, 133, 252), (134, 134, 255)],
    [(250, 204, 193), (253, 167, 167)],
    [(127, 141, 195), (237, 153, 174)],
    [(253, 214, 72), (250, 124, 144)],
    [(186, 148, 249), (133, 114, 240)],
    [(118, 122, 229), (243, 220, 228)],
    [(255, 217, 0), (255, 107, 144)],
    [(255, 127, 102), (224, 56, 131)],
    [(0, 177, 192), (149, 229, 135)],
    [(249, 197, 141), (244, 146, 240)],
    [(159, 237, 249), (247, 199, 195)],
    [(240, 253, 137), (164, 224, 24)],
    [(255, 0, 151), (252, 115, 115)],
    [(108, 148, 238), (17, 205, 247)],
    [(255, 67, 112), (255, 175, 152)],
    [(39, 183, 233), (224, 120, 241)],
    [(19, 225, 249), (138, 231, 173)],
    [(247, 133, 126), (204, 250, 210)],
    [(252, 188, 156), (110, 231, 168)],
    [(239, 162, 172), (254, 216, 220)],
    [(250, 69, 69), (245, 112, 115)],
    [(250, 112, 153), (255, 112, 64)],
    [(240, 148, 250), (245, 87, 110)],
    [(255, 20, 78), (241, 117, 80)],
    [(255, 8, 69), (151, 227, 239)],
    [(255, 82, 8), (242, 147, 147)],
    [(250, 69, 69), (250, 199, 77)],
    [(255, 140, 33), (255, 224, 64)],
    [(255, 140, 33), (245, 87, 110)],
    [(255, 140, 33), (255, 97, 33)],
    [(255, 140, 33), (255, 176, 153)],
    [(255, 140, 33), (229, 242, 148)],
    [(204, 201, 56), (242, 199, 84)],
    [(163, 222, 97), (240, 207, 41)],
    [(235, 196, 61), (255, 209, 143)],
    [(245, 237, 71), (128, 245, 232)],
    [(245, 255, 166), (245, 176, 128)],
    [(245, 255, 166), (245, 227, 128)],
    [(212, 252, 121), (150, 230, 161)],
    [(132, 250, 176), (143, 211, 244)],
    [(42, 245, 152), (0, 158, 253)],
    [(55, 236, 186), (114, 175, 211)],
    [(55, 236, 186), (117, 212, 115)],
    [(58, 101, 211), (117, 212, 115)],
    [(5, 56, 255), (112, 227, 245)],
    [(5, 56, 255), (64, 255, 199)],
    [(5, 56, 255), (107, 87, 245)],
    [(31, 76, 255), (97, 151, 228)],
    [(5, 56, 255), (87, 153, 247)],
    [(5, 150, 255), (87, 153, 247)],
    [(48, 216, 238), (62, 137, 245)],
    [(61, 140, 250), (64, 255, 199)],
    [(148, 237, 250), (107, 87, 245)],
    [(8, 240, 255), (60, 137, 246)],
    [(8, 227, 255), (87, 153, 247)],
    [(8, 255, 184), (87, 153, 247)],
    [(194, 56, 204), (181, 84, 242)],
    [(166, 232, 255), (178, 128, 245)],
    [(178, 61, 235), (222, 143, 255)],
    [(61, 115, 235), (222, 143, 255)],
    [(204, 255, 166), (178, 128, 245)],
    [(243, 166, 255), (178, 128, 245)]
]


func decodeData(codeString:String) {
    
    var aStr = codeString.replacingOccurrences(of: "BEGIN:VEVENT", with: "")
    aStr = aStr.replacingOccurrences(of: "\n", with: "")
    aStr = aStr.replacingOccurrences(of: "SUMMARY:", with: "")
    aStr = aStr.replacingOccurrences(of: "LOCATION:", with: "_")
    aStr = aStr.replacingOccurrences(of: "DTSTART:", with: "_")
    aStr = aStr.replacingOccurrences(of: "DTEND:", with: "_")
    aStr = aStr.replacingOccurrences(of: "END:VEVENT", with: "")
}

func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.utf8)
    
    if let filter = CIFilter(name: "CIQRCodeGenerator") {
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 7, y: 7)
        
        if let output = filter.outputImage?.transformed(by: transform) {
            return UIImage(ciImage: output)
        }
    }
    
    return nil
}



extension UIApplication {
    /// The top most view controller
    static var topMostViewController: UIViewController? {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.visibleViewController
    }
}

extension UIViewController {
    /// The visible view controller from a given view controller
    var visibleViewController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visibleViewController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.visibleViewController
        } else {
            return self
        }
    }
}


extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}
extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...]
            .range(of: string, options: options) {
            indices.append(range.lowerBound)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
            index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...]
            .range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
            index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}

struct EmailParameters {
    /// Guaranteed to be non-empty
    let toEmails: [String]
    let ccEmails: [String]
    let bccEmails: [String]
    let subject: String?
    let body: String?
    
    
    /// Defaults validation is just verifying that the email is not empty.
    static func defaultValidateEmail(_ email: String) -> Bool {
        return !email.isEmpty
    }
    
    /// Returns `nil` if `toEmails` contains at least one email address validated by `validateEmail`
    /// A "blank" email address is defined as an address that doesn't only contain whitespace and new lines characters, as defined by CharacterSet.whitespacesAndNewlines
    /// `validateEmail`'s default implementation is `defaultValidateEmail`.
    init?(
        toEmails: [String],
        ccEmails: [String],
        bccEmails: [String],
        subject: String?,
        body: String?,
        validateEmail: (String) -> Bool = defaultValidateEmail
    ) {
        func parseEmails(_ emails: [String]) -> [String] {
            return emails.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter(validateEmail)
        }
        let toEmails = parseEmails(toEmails)
        let ccEmails = parseEmails(ccEmails)
        let bccEmails = parseEmails(bccEmails)
        if toEmails.isEmpty {
            return nil
        }
        self.toEmails = toEmails
        self.ccEmails = ccEmails
        self.bccEmails = bccEmails
        self.subject = subject
        self.body = body
    }
    
    /// Returns `nil` if `scheme` is not `mailto`, or if it couldn't find any `to` email addresses
    /// `validateEmail`'s default implementation is `defaultValidateEmail`.
    /// Reference: https://tools.ietf.org/html/rfc2368
    init?(url: URL, validateEmail: (String) -> Bool = defaultValidateEmail) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        let queryItems = urlComponents.queryItems ?? []
        func splitEmail(_ email: String) -> [String] {
            return email.split(separator: ",").map(String.init)
        }
        let initialParameters = (toEmails: urlComponents.path.isEmpty ? [] : splitEmail(urlComponents.path), subject: String?(nil), body: String?(nil), ccEmails: [String](), bccEmails: [String]())
        let emailParameters = queryItems.reduce(into: initialParameters) { emailParameters, queryItem in
            guard let value = queryItem.value else {
                return
            }
            switch queryItem.name {
            case "to":
                emailParameters.toEmails += splitEmail(value)
            case "cc":
                emailParameters.ccEmails += splitEmail(value)
            case "bcc":
                emailParameters.bccEmails += splitEmail(value)
            case "subject" where emailParameters.subject == nil:
                emailParameters.subject = value
            case "body" where emailParameters.body == nil:
                emailParameters.body = value
            default:
                break
            }
        }
        self.init(
            toEmails: emailParameters.toEmails,
            ccEmails: emailParameters.ccEmails,
            bccEmails: emailParameters.bccEmails,
            subject: emailParameters.subject,
            body: emailParameters.body,
            validateEmail: validateEmail
        )
    }
}


extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}


extension UILabel{
    
    public var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
}




protocol Utilities {}
extension NSObject: Utilities {
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
}





extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: (self.view.frame.size.width - 250)/2.0, y: (self.view.frame.size.height-100)/2.0, width: 250, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }


public extension UIView
{
    static func loadFromXib<T>(withOwner: Any? = nil, options: [UINib.OptionsKey : Any]? = nil) -> T where T: UIView
    {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "\(self)", bundle: bundle)

        guard let view = nib.instantiate(withOwner: withOwner, options: options).first as? T else {
            fatalError("Could not load view from nib file.")
        }
        return view
    }
}

class GradientLabel: UILabel {
    var gradientColors: [CGColor] = []

    override func drawText(in rect: CGRect) {
        if let gradientColor = drawGradientColor(in: rect, colors: gradientColors) {
            self.textColor = gradientColor
        }
        super.drawText(in: rect)
    }

    private func drawGradientColor(in rect: CGRect, colors: [CGColor]) -> UIColor? {
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }

        let size = rect.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: nil) else { return nil }

        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient,
                                    start: CGPoint.zero,
                                    end: CGPoint(x: size.width, y: 0),
                                    options: [])
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = gradientImage else { return nil }
        return UIColor(patternImage: image)
    }
}

extension Date {
    func asString(style: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
}
