
//  ShowResultVc.swift
//  QrCode&BarCodeMizan
//
//  Created by Macbook pro 2020 M1 on 18/3/23.
//

import UIKit
import AVFoundation
import MessageUI
import QRCode
import EventKit
import EventKitUI
import Contacts
import NetworkExtension
import StoreKit
import IHProgressHUD
import ProgressHUD
import Reachability
import WidgetKit
import FirebaseAnalytics
import EFQRCode
import ImageIO
import MobileCoreServices
import SVProgressHUD
import Photos
import SwiftyGif


let reachability = try! Reachability()
protocol dismissImagePicker {
    func  dimissAllClass()
}

class ShowResultVc: UIViewController, MFMessageComposeViewControllerDelegate, sendImage, sendUpdatedArray, EKEventEditViewDelegate, MFMailComposeViewControllerDelegate, showAlertBv, UIColorPickerViewControllerDelegate, sendimageValue1, sendStyle {
    
    
  
    func createQRGif(from gifData: NSData,
                     content: String,
                     isFromSave: Bool,
                     completion: @escaping (NSData?) -> Void) {
        
        if !isFromSave {
            // Just display QR overlay without generating GIF
            do {
                let image = try self.doc.uiImage(CGSize(width: 500, height: 500), dpi: 72)
                gifOverLayQr.image = image
                
                let gif = try UIImage(gifData: gifData as Data)
                self.gifimv.setGifImage(gif, loopCount: -1)
            } catch {
                print("Error generating QR code image: \(error)")
            }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // 1️⃣ Extract GIF frames
            guard let source = CGImageSourceCreateWithData(gifData, nil) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let totalFrameCount = CGImageSourceGetCount(source)
            let frameCount = min(totalFrameCount, 50) // Up to 50 frames
            
            // 2️⃣ Generate QR image once
            let qrImage: UIImage
            do {
                qrImage = try self.doc.uiImage(CGSize(width: 1000, height: 1000), dpi: 72)
            } catch {
                print("Error generating QR code image: \(error)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 3️⃣ Prepare temporary file for GIF
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tempGif.gif")
            guard let destination = CGImageDestinationCreateWithURL(
                tempURL as CFURL,
                UTType.gif.identifier as CFString, // ✅ modern UTType
                frameCount,
                nil
            ) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let gifProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]]
            CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
            
            // 4️⃣ Process each frame
            for i in 0..<frameCount {
                autoreleasepool {
                    guard let cgFrame = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                        return // skip frame if failure
                    }
                    
                    var frameImage = UIImage(cgImage: cgFrame)
                    
                    // ✅ Maintain aspect ratio inside 500x500
                    let targetSize = CGSize(width: 500, height: 500)
                    UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
                    
                    let originalSize = frameImage.size
                    let scale = min(targetSize.width / originalSize.width,
                                    targetSize.height / originalSize.height)
                    let newWidth = originalSize.width * scale
                    let newHeight = originalSize.height * scale
                    let x = (targetSize.width - newWidth) / 2.0
                    let y = (targetSize.height - newHeight) / 2.0
                    
                    frameImage.draw(in: CGRect(x: x, y: y, width: newWidth, height: newHeight))
                    
                    // Overlay QR full-size
                    qrImage.draw(in: CGRect(origin: .zero, size: targetSize),
                                 blendMode: .normal,
                                 alpha: 1.0)
                    
                    let combined = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    if let combinedCG = combined?.cgImage {
                        // Frame delay
                        let delay: Double = {
                            guard let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [CFString: Any],
                                  let gifInfo = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else { return 0.1 }
                            if let unclamped = gifInfo[kCGImagePropertyGIFUnclampedDelayTime] as? Double, unclamped > 0 {
                                return unclamped
                            } else if let clamped = gifInfo[kCGImagePropertyGIFDelayTime] as? Double, clamped > 0 {
                                return clamped
                            }
                            return 0.1
                        }()
                        
                        let frameProps = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: delay]]
                        CGImageDestinationAddImage(destination, combinedCG, frameProps as CFDictionary)
                    }
                }
            }
            
            // 5️⃣ Finalize GIF
            CGImageDestinationFinalize(destination)
            
            // Read GIF from temp file
            if let finalData = try? NSData(contentsOf: tempURL) {
                let finalSizeKB = Double(finalData.length) / 1024.0
                let finalSizeMB = finalSizeKB / 1024.0
                print("👉 Total frames: \(frameCount)")
                print("👉 Final GIF size: \(String(format: "%.2f", finalSizeKB)) KB (\(String(format: "%.2f", finalSizeMB)) MB)")
                
                DispatchQueue.main.async {
                    completion(finalData)
                }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }


    
    func saveGifToDocuments(gifData: Data, templateFileName: String) {
        // 1️⃣ Get Documents directory path
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            // 2️⃣ Create file URL
            let fileURL = documentsDirectory.appendingPathComponent(templateFileName)
            
            do {
                // 3️⃣ Write data
                try gifData.write(to: fileURL)
                print("✅ GIF saved at: \(fileURL.path)")
            } catch {
                print("❌ Error saving GIF: \(error)")
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldGotoDesign {
            
            self.gotocustomizeDeisgn()
            shouldGotoDesign = false
            
        }
        
    }
    
    func getGifDataFromDocuments(fileName: String) -> Data? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            return try? Data(contentsOf: fileURL)
        }
        return nil
    }
    
    func sendUrl1(name: String, fileName: String,catName:String) {
        
        captionView.isUserInteractionEnabled = true
        captionView.alpha = 1.0
        
        self.bottomSpaceText.constant = -5000
        
        let fileName = catName + fileName + ".jpg"
        print("URL I am getting: \(fileName)-\(name)")
        
        // Check if the image is already downloaded
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Check if the file already exists
        if fileManager.fileExists(atPath: fileURL.path) {
            print("Image is already downloaded: \(fileName)")
            
            // Load image from local storage
            if let image = UIImage(contentsOfFile: fileURL.path) {
                
                templateFileName = fileName
                self.templateImage = image
                
                DispatchQueue.main.async {
                    
                    self.updateTemplateimv()
                }
            }
        } else {
            
            ProgressHUD.animate()
            
            guard let imageUrl = URL(string: name) else {
                print("Invalid image URL.")
                return
            }
            self.downloadImage(from: imageUrl, to: fileURL, fileName: fileName)
            
        }
        
        
    }
    
    
    func downloadImage(from url: URL, to destinationURL: URL,fileName:String) {
        // Perform image download here
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Failed to download image: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received during image download.")
                return
            }
            
            do {
                // Write the image data to the destination URL
                try data.write(to: destinationURL)
                print("Image downloaded and saved to: \(destinationURL.path)")
                
                // Optionally, you can display the image after saving
                if let image = UIImage(data: data) {
                    self.templateFileName = fileName
                    self.templateImage = image
                    
                    DispatchQueue.main.async {
                        
                        self.updateTemplateimv()
                        ProgressHUD.dismiss()
                    }
                    
                    
                    
                }
            } catch {
                print("Error saving image: \(error)")
            }
        }
        
        task.resume()
    }
    
    
    
    @IBAction func goToText(_ sender: Any) {
        
        
        UIView.animate(withDuration: 0.3) {
            self.bottomSpaceText.constant = 0
            self.bottomSpaceTemplateView.constant = -5000
            self.view.layoutIfNeeded()
        }
        
    }
    
    func doEmptyText() {
        
        fontColor = "0.14901960784313725,0.7764705882352941,0.8549019607843137"
        fontSize = "15"
        fontFamily = "system"
        textFiled.text = ""
        
        customSlider.value = Float(self.fontSize) ?? 15.0
        
    }
    
    
    func uicolorToRGB(color: UIColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        // If the color can be converted to RGBA components, return them
        if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (red, green, blue, alpha)
        }
        
        return nil
    }
    
    func setAllValue(obj:QRStyle) {
        
        position1 = obj.position
        shape1 = obj.shape
        pupil1 = obj.pupil
       
       
       
        eyeColor = colorFrom(rgbString: obj.eyeColor)
        pupilColor  = colorFrom(rgbString: obj.pupilColor)
        shapeColor  = colorFrom(rgbString: obj.shapeColor)
 
     

        colorb = colorFrom(rgbString: obj.backgroundColor) ?? UIColor.white
         
        
        let x = obj.eyegradient
        let y = obj.pupilgradient
        let z = obj.shapegradient
        
        
    
        let x1 = Int(x) ?? -1
        let y1 = Int(y) ?? -1
        let z1 = Int(z) ?? -1
        
        
        if x1 > 0 {
            eyeGradeint = x1
            eyeColor = nil
        }
        
        if y1 > 0 {
            pupilGradent = y1
            pupilColor = nil
        }
        
        if z1 > 0 {
            shapeGradeint = z1
            shapeColor = nil
        }
        
       
        
        self.updateAll()
        
 
        
        
    }
    
    
    func colorFrom(rgbString: String) -> UIColor? {
        let components = rgbString.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        guard components.count == 3 else { return nil }
        return UIColor(
            red: CGFloat(components[0]) / 255.0,
            green: CGFloat(components[1]) / 255.0,
            blue: CGFloat(components[2]) / 255.0,
            alpha: 1.0
        )
    }
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        
        if let rgb = uicolorToRGB(color:viewController.selectedColor) {
            fontColor = "\(rgb.red),\(rgb.green),\(rgb.blue)"
        }
        self.updateAllTextValue()
        
    }
    
    
    func appearAlert() {
        
        if !isfromQr {
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.bottomSpaceText.constant = 0
            self.bottomSpaceTemplateView.constant = -5000
            self.view.layoutIfNeeded()
        }
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        
        if action.rawValue == 0 {
            
            controller.dismiss(animated: true, completion: nil)
            return
        }
        
        eventF = controller.event
        
        var event = Event()
        
        if let eventV = controller.event?.title {
            event.summary = eventV
            
            // self.createDataModelArray.append(ResultDataModel(title: "Title", description: event.summary!))
        }
        
        if let startDate = controller.event?.startDate {
            // Store.sharedInstance.setstartDate(date: startDate)
            event.dtstart = startDate
            // let a = startDate.toString()
            //self.createDataModelArray.append(ResultDataModel(title: "Start", description:a))
        }
        
        if let endDate = controller.event?.endDate {
            // Store.sharedInstance.setstartDate(date: endDate)
            event.dtend = endDate
            //let a = endDate.toString()
            // self.createDataModelArray.append(ResultDataModel(title: "End", description:a))
        }
        
        if let location = controller.event?.location {
            event.location = location
            //self.createDataModelArray.append(ResultDataModel(title: "Location", description: event.location!))
        }
        
        if let note = controller.event?.notes {
            event.descr = note
            //self.createDataModelArray.append(ResultDataModel(title: "Notes", description: event.descr!))
        }
        
        let calendar = Calendar1(withComponents: [event])
        let iCalString = calendar.toCal()
        
        let value = QrParser.getBarCodeObj(text: iCalString)
        
        
        showText = value
        outputResult = showText.components(separatedBy: "^") as NSArray
        showText = (outputResult[0] as? String)!
        tablewView.reloadData()
        stringValue = iCalString
        self.updateAll()
        tablewView.reloadData()
        
        
        
        eventF = controller.event
        controller.dismiss(animated: true)
        
        
    }
    
    func setColor() {
        backgroundColorValue.removeAll()
        
        backgroundColorValue  = [
            UIColor(red: 248/255, green: 176/255, blue: 17/255, alpha: 1),
            UIColor(red: 234/255, green: 93/255, blue: 154/255, alpha: 1),
            UIColor(red: 246/255, green: 134/255, blue: 75/255, alpha: 1),
            UIColor(red: 255/255, green: 224/255, blue: 122/255, alpha: 1),
            UIColor(red: 0/255, green: 163/255, blue: 76/255, alpha: 1),
            UIColor(red: 249/255, green: 221/255, blue: 174/255, alpha: 1),
            UIColor(red: 199/255, green: 219/255, blue: 102/255, alpha: 1),
            UIColor(red: 225/255, green: 241/255, blue: 121/255, alpha: 1),
            UIColor(red: 0/255, green: 166/255, blue: 209/255, alpha: 1),
            UIColor(red: 192/255, green: 234/255, blue: 242/255, alpha: 1),
            UIColor(red: 0/255, green: 184/255, blue: 148/255, alpha: 1),
            UIColor(red: 148/255, green: 255/255, blue: 235/255, alpha: 1),
            UIColor(red: 31/255, green: 76/255, blue: 173/255, alpha: 1),
            UIColor(red: 202/255, green: 205/255, blue: 232/255, alpha: 1),
            UIColor(red: 1/255, green: 158/255, blue: 223/255, alpha: 1),
            UIColor(red: 128/255, green: 208/255, blue: 255/255, alpha: 1),
            UIColor(red: 210/255, green: 29/255, blue: 141/255, alpha: 1),
            UIColor(red: 225/255, green: 194/255, blue: 173/255, alpha: 1),
            UIColor(red: 106/255, green: 95/255, blue: 170/255, alpha: 1),
            UIColor(red: 140/255, green: 128/255, blue: 245/255, alpha: 1),
            UIColor(red: 230/255, green: 46/255, blue: 52/255, alpha: 1),
            UIColor(red: 229/255, green: 128/255, blue: 144/255, alpha: 1),
            UIColor(red: 238/255, green: 88/255, blue: 144/255, alpha: 1),
            UIColor(red: 91/255, green: 189/255, blue: 118/255, alpha: 1),
            UIColor(red: 121/255, green: 141/255, blue: 113/255, alpha: 1),
            UIColor(red: 239/255, green: 221/255, blue: 204/255, alpha: 1),
            UIColor(red: 1/255, green: 192/255, blue: 223/255, alpha: 1),
            UIColor(red: 241/255, green: 158/255, blue: 184/255, alpha: 1),
            UIColor(red: 143/255, green: 120/255, blue: 107/255, alpha: 1),
            UIColor(red: 231/255, green: 171/255, blue: 131/255, alpha: 1),
            UIColor(red: 42/255, green: 101/255, blue: 182/255, alpha: 1),
            UIColor(red: 202/255, green: 104/255, blue: 166/255, alpha: 1),
            UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1),
            UIColor(red: 178/255, green: 112/255, blue: 255/255, alpha: 1),
            UIColor(red: 207/255, green: 255/255, blue: 189/255, alpha: 1),
            UIColor(red: 240/255, green: 94/255, blue: 87/255, alpha: 1),
            UIColor(red: 231/255, green: 96/255, blue: 44/255, alpha: 1),
            UIColor(red: 253/255, green: 94/255, blue: 123/255, alpha: 1),
            UIColor(red: 153/255, green: 239/255, blue: 255/255, alpha: 1),
            UIColor(red: 207/255, green: 179/255, blue: 149/255, alpha: 1),
            UIColor(red: 145/255, green: 191/255, blue: 64/255, alpha: 1),
            UIColor(red: 202/255, green: 177/255, blue: 210/255, alpha: 1),
            UIColor(red: 137/255, green: 141/255, blue: 129/255, alpha: 1),
            UIColor(red: 1/255, green: 172/255, blue: 132/255, alpha: 1),
            UIColor(red: 218/255, green: 233/255, blue: 195/255, alpha: 1),
            UIColor(red: 143/255, green: 99/255, blue: 86/255, alpha: 1),
            UIColor(red: 1/255, green: 116/255, blue: 193/255, alpha: 1),
            UIColor(red: 223/255, green: 156/255, blue: 124/255, alpha: 1),
            UIColor(red: 254/255, green: 248/255, blue: 195/255, alpha: 1),
            UIColor(red: 127/255, green: 59/255, blue: 155/255, alpha: 1),
            UIColor(red: 247/255, green: 226/255, blue: 137/255, alpha: 1),
            UIColor(red: 185/255, green: 224/255, blue: 249/255, alpha: 1),
            UIColor(red: 238/255, green: 53/255, blue: 132/255, alpha: 1),
            UIColor(red: 138/255, green: 195/255, blue: 212/255, alpha: 1),
            UIColor(red: 255/255, green: 107/255, blue: 107/255, alpha: 1),   // #FF6B6B from hex list
            UIColor(red: 78/255, green: 205/255, blue: 196/255, alpha: 1),   // #4ECDC4 from hex list
            UIColor(red: 255/255, green: 230/255, blue: 109/255, alpha: 1),  // #FFE66D from hex list
            UIColor(red: 167/255, green: 139/255, blue: 250/255, alpha: 1),  // #A78BFA from hex list
            UIColor(red: 85/255, green: 239/255, blue: 196/255, alpha: 1),   // #55EFC4 from hex list
            UIColor(red: 255/255, green: 158/255, blue: 125/255, alpha: 1),  // #FF9E7D from hex list
            UIColor(red: 107/255, green: 214/255, blue: 255/255, alpha: 1),  // #6BD6FF from hex list
            UIColor(red: 255/255, green: 209/255, blue: 102/255, alpha: 1),  // #FFD166 from hex list
            UIColor(red: 123/255, green: 239/255, blue: 178/255, alpha: 1),  // #7BEFB2 from hex list
            UIColor(red: 212/255, green: 165/255, blue: 165/255, alpha: 1),  // #D4A5A5 from hex list
            UIColor(red: 255/255, green: 221/255, blue: 89/255, alpha: 1),   // #FFDD59 from hex list
            UIColor(red: 162/255, green: 210/255, blue: 255/255, alpha: 1),  // #A2D2FF from hex list
            UIColor(red: 205/255, green: 180/255, blue: 219/255, alpha: 1),  // #CDB4DB from hex list
            UIColor(red: 255/255, green: 175/255, blue: 204/255, alpha: 1),  // #FFAFCC from hex list
            UIColor(red: 189/255, green: 224/255, blue: 254/255, alpha: 1),  // #BDE0FE from hex list
            UIColor(red: 255/255, green: 200/255, blue: 221/255, alpha: 1),  // #FFC8DD from hex list
            UIColor(red: 160/255, green: 231/255, blue: 229/255, alpha: 1),  // #A0E7E5 from hex list
            UIColor(red: 255/255, green: 133/255, blue: 161/255, alpha: 1),  // #FF85A1 from hex list
            UIColor(red: 254/255, green: 228/255, blue: 64/255, alpha: 1),   // #FEE440 from hex list
            UIColor(red: 0/255, green: 187/255, blue: 249/255, alpha: 1),    // #00BBF9 from hex list
            UIColor(red: 255/255, green: 94/255, blue: 91/255, alpha: 1),    // #FF5E5B from hex list
            UIColor(red: 155/255, green: 246/255, blue: 255/255, alpha: 1),  // #9BF6FF from hex list
            UIColor(red: 202/255, green: 255/255, blue: 191/255, alpha: 1),  // #CAFFBF from hex list
            UIColor(red: 253/255, green: 255/255, blue: 182/255, alpha: 1),  // #FDFFB6 from hex list
            UIColor(red: 189/255, green: 178/255, blue: 255/255, alpha: 1),  // #BDB2FF from hex list
            UIColor(red: 255/255, green: 198/255, blue: 255/255, alpha: 1),  // #FFC6FF from hex list
            UIColor(red: 160/255, green: 196/255, blue: 255/255, alpha: 1),  // #A0C4FF from hex list
            UIColor(red: 253/255, green: 255/255, blue: 171/255, alpha: 1),  // #FDFFAB from hex list
            UIColor(red: 217/255, green: 237/255, blue: 146/255, alpha: 1),  // #D9ED92 from hex list
            UIColor(red: 181/255, green: 228/255, blue: 140/255, alpha: 1),  // #B5E48C from hex list
            UIColor(red: 153/255, green: 217/255, blue: 140/255, alpha: 1),  // #99D98C from hex list
            UIColor(red: 118/255, green: 200/255, blue: 147/255, alpha: 1),  // #76C893 from hex list
            UIColor(red: 82/255, green: 182/255, blue: 154/255, alpha: 1),   // #52B69A from hex list
            UIColor(red: 52/255, green: 160/255, blue: 164/255, alpha: 1),   // #34A0A4 from hex list
            UIColor(red: 22/255, green: 138/255, blue: 173/255, alpha: 1),   // #168AAD from hex list
            UIColor(red: 26/255, green: 117/255, blue: 159/255, alpha: 1)    // #1A759F from hex list
        ]
        

        
    }
    
    func processYelpData(ar: [ResultDataModel], sh: String, st: String) {
        templateImv.alpha = 0
        
        if !isfromQr {
            stringValue = st
            var output = "BarCode Detail"
            output = output + "\n\n"
            output = output + stringValue
            
            barLabelText.text = stringValue
            if let img = BarCodeGenerator.getBarCodeImage(type: currenttypeOfQrBAR, value: stringValue) {
                image = img
                labelText.text = output
                imv.image = image
                qrCodeShowView.isHidden = true
            }
            return
        }
        
        createDataModelArray = ar
        showText = sh
        outputResult = showText.components(separatedBy: "^") as NSArray
        showText = (outputResult[0] as? String)!
        tablewView.reloadData()
        stringValue = st
        self.updateAll()
        
        tablewView.reloadData()
        
        if templateImage != nil && templateResultView != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let labelSize = self.templateResultView?.getLabelDimensions() {
                    self.savedLabelWidth = labelSize.width
                    print("Saved label width: \(self.savedLabelWidth)")
                }
                
                UIView.animate(withDuration: 0.3) {
                    self.templateImv.alpha = 1
                }
            }
        }
        
        
    }
    
    
    
    func sendScreenSort(image: UIImage, position: String, shape: String, logo: UIImage?, color1: UIColor, color2: UIColor,pupil:String,pupilc:UIColor?,eyec:UIColor?,shapec:UIColor?,eyeGradeint:Int,pupilGradent:Int,shapeGradeint:Int,background:UIImage?) {
        let currentLabelText = templateResultView?.labelText
        
        templateImv.alpha = 0
        
        position1 = position
        shape1 = shape
        logo1 = logo
        colora = color1
        colorb = color2
        pupil1 = pupil
        pupilColor = pupilc
        eyeColor = eyec
        shapeColor = shapec
        self.eyeGradeint = eyeGradeint
        self.pupilGradent = pupilGradent
        self.shapeGradeint = shapeGradeint
        self.selectedIamge = background
        
        widthForMainView.constant = 200
        heightForMainView.constant = 200
        
        self.updateAll()
        
        let size = AVMakeRect(aspectRatio: imv.image!.size, insideRect: imv.frame)
        widthForMainView.constant = size.width
        heightForMainView.constant = size.height
        
        if templateImage != nil {
            templateImv.isHidden = false
            imv.isHidden = true
            
            guard let templateImage = templateImage,
                  let qrCodeImage = imv.image else { return }
            
            showDynamicContentView(
                withTemplate: templateImage,
                qrCode: qrCodeImage,
                withText: currentLabelText,
                animated: true
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if self.savedLabelWidth > 0 {
                    self.templateResultView?.setLabelDimensions(width: self.savedLabelWidth)
                    print("Restoring label width in sendScreenSort: \(self.savedLabelWidth)")
                }
            }
        }
        else {
            templateImv.isHidden = true
        }
        
        if let data = gifData {
            gifView.isHidden = false
            templateOption.isUserInteractionEnabled = false
           
            
            templateOption.alpha = 0.3
             
        
            
            createQRGif(from: data as NSData, content: stringValue, isFromSave: false) { resultGifData in
                if let data = resultGifData {
                    do {
                        let gif = try UIImage(gifData: data as Data)
                        self.globalGifData = data
                        self.gifimv.setGifImage(gif, loopCount: -1) // -1 = infinite loop
                    } catch {
                        print("Failed to create GIF image: \(error)")
                    }
                } else {
                    print("Failed to create QR GIF")
                }
            }
            
            
            holderTemplateView.alpha = 0
            textChangeholderView.alpha = 0
            
           
            
        }
        
        
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    var globalGifData: NSData?
    var shouldShowWhite = false
    
    @IBOutlet weak var widghetLabel: UILabel!
    
    @IBOutlet weak var backBtnp: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var roundedHolderView: UIView!
    @IBOutlet weak var eyesLabel: UILabel!
    @IBOutlet weak var gifOverLayQr: UIImageView!
    @IBOutlet weak var gifimv: UIImageView!
    @IBOutlet weak var gifView: UIView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempIcon: UIImageView!
    @IBOutlet weak var previewl: UIView!
    @IBOutlet weak var preview: UILabel!
    @IBOutlet weak var wid: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var fontsizeLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var deisgnLabel: UILabel!
    @IBOutlet weak var templateLabel: UILabel!
    @IBOutlet weak var bottomSpaceTemplateView: NSLayoutConstraint!
    @IBOutlet weak var textFiled: UITextField!
    private var customSlider: Slider!
    @IBOutlet weak var sliderView: UIView!
    var templateFileName:String?
    @IBOutlet weak var btn: UIImageView!
    @IBOutlet weak var topView: UIView!
    var tempText1 = ""
    var gifData:Data?
    var backgroundColorValue:[UIColor] = []
    var gap:CGFloat = 10
    
    var selectedPreset:QRStyle?
    
    @IBOutlet weak var watermarkView: UIView!
    
    @IBOutlet weak var deisgnOptionAlpha: UIView!
    @IBOutlet weak var fontlabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var rect: UIImageView!
    @IBOutlet weak var heightForTopView: NSLayoutConstraint!
    @IBOutlet weak var editContentView: UIView!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var customizeView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var barTextValue: UILabel!
    
    @IBOutlet weak var TemplateView: UIView!
    @IBOutlet weak var collectionViewForFont: UICollectionView!
    @IBOutlet weak var imv: UIImageView!
    
    @IBOutlet weak var collectionViewForColor: UICollectionView!
    @IBOutlet weak var bottomSpaceText: NSLayoutConstraint!
    @IBOutlet weak var textChangeholderView: UIView!
    @IBOutlet weak var templateImv: UIView!
    @IBOutlet weak var imageviewHolder: UIView!
    @IBOutlet weak var qrCodeStackValue: UIStackView!
    
    @IBOutlet weak var tablewView: UITableView!
    
    @IBOutlet weak var wowBtn: UIImageView!
    @IBOutlet weak var captionView: CustomView!
    @IBOutlet weak var templateOption: UIView!
    private var lastUpdateTime: TimeInterval = 0
    private let updateDelay: TimeInterval = 0.1
    
    @IBOutlet weak var copyTetx: UILabel!
    @IBOutlet weak var widthForMainView: NSLayoutConstraint!
    @IBOutlet weak var heightForMainView: NSLayoutConstraint!
    @IBOutlet weak var heightForScrollView: NSLayoutConstraint!
    @IBOutlet weak var heightForView: NSLayoutConstraint!
    var store: CNContactStore!
    
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var holderTemplateView: UIView!
    @IBOutlet weak var lifeTime: UILabel!
    @IBOutlet weak var yearlyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var idF = ""
    var showText  = ""
    var stringValue  = ""
    var isfromQr = true
    var isFromGif = false
    
    
    var  isFromScanned = false
    var image:UIImage! = nil
    var outputResult:NSArray!
    var currentData: DetectedInfo?
    var currenttypeOfQrBAR = ""
    
    var  isfromUpdate = false
    var  isfromHistory = false
    
    var createDataModelArray = [ResultDataModel]()
    var eventF:EKEvent?
    var contactCard:CNMutableContact!
    var delegateDis: dismissImagePicker?
    
    private var savedLabelWidth: CGFloat = 0
    private var savedLabelHeight: CGFloat = 0
    
    @IBOutlet weak var heightForView1: NSLayoutConstraint!
    
    @IBOutlet weak var barLabelText: UILabel!
    
    @IBOutlet weak var bnTextContent: UIButton!
    @IBOutlet weak var qrCodeShowView: UIView!
    var deductionValue = 0
    var position1 = "square"
    var shape1 = "square"
    var pupil1 = "square"
    var logo1:UIImage? = nil
    var colora = UIColor.black
    var colorb  = UIColor.white
    var templateImage:UIImage?
    let doc = QRCode.Document()
    var fontColor = "0.14901960784313725,0.7764705882352941,0.8549019607843137"
    var fontSize = "15"
    var fontFamily = "system"
    var selectedIamge:UIImage?
    @IBOutlet weak var fontholderView: UIView!
    var contacts:[CNContact] = []
    var isFromGallery = false
    var eyeColor:UIColor?
    var pupilColor:UIColor?
    var shapeColor:UIColor?
    
    var eyeGradeint  = -1
    var pupilGradent = -1
    var shapeGradeint = -1
    
    var mainGradientColor = [[(r: Int, g: Int, b: Int)]]()
    var bottomTemplateView:BottomTemplateView?
    
    //var type = "" growing just need to see you put to sit if you need to we need
    
    
    
    //    @IBAction func gotMakeWidghet(_ sender: Any) {
    //        if let templateView = templateResultView {
    //
    //            let highResImage = templateView.exportImage(size: CGSize(width: 1500, height: 1500))
    //        }
    //
    //    }
    
    //    @IBAction func gotMakeWidghet(_ sender: Any) {
    //        if let templateView = templateResultView {
    //            let highResImage = templateView.exportImage(size: CGSize(width: 1500, height: 1500))
    //
    //            if let data = highResImage.pngData() {
    //                let fileManager = FileManager.default
    //                if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.scannr.qrwidget") {
    //                    let imageURL = containerURL.appendingPathComponent("widgetImage.png")
    //                    try? data.write(to: imageURL)
    //                    WidgetCenter.shared.reloadAllTimelines() // Notify widget to reload
    //                }
    //            }
    //        }
    //    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    @IBAction func gotMakeWidghet(_ sender: Any) {
        
        var highResImage: UIImage?
        print("it has been added widget")
        
        if let templateView = templateResultView {
            highResImage = templateView.exportImage(size: CGSize(width: 200, height: 200))
        } else {
            highResImage = self.resizeImage(image: imv.image ?? UIImage(), targetSize: CGSize(width: 200, height: 200))
        }
        
        // ✅ Show progress HUD
        ProgressHUD.animate()
        
        let start = Date()
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = highResImage?.pngData() else {
                print("❌ Failed to convert image to PNG data")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    ProgressHUD.dismiss()
                }
                return
            }
            
            let fileManager = FileManager.default
            guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.scannr.qrwidget") else {
                print("❌ Could not get container URL for App Group")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    ProgressHUD.dismiss()
                }
                return
            }
            
            let imageURL = containerURL.appendingPathComponent("widgetImage.png")
            
            do {
                if fileManager.fileExists(atPath: imageURL.path) {
                    try fileManager.removeItem(at: imageURL)
                }
                
                try data.write(to: imageURL, options: .atomic)
                print("✅ Image saved to \(imageURL.path)")
                
                let elapsed = Date().timeIntervalSince(start)
                let delay = max(0.3 - elapsed, 0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    ProgressHUD.dismiss()
                    WidgetCenter.shared.reloadAllTimelines()
                    self.showSuccessAlert()
                }
                
            } catch {
                print("❌ Error saving image: \(error.localizedDescription)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    ProgressHUD.dismiss()
                }
            }
        }
        
    }
    
    
    func showSuccessAlert() {
        let alert = UIAlertController(title: "Success",
                                      message: "The widget has been successfully set.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func gotoCustomizeDesign(_ sender: Any) {
        
        self.gotocustomizeDeisgn()
    }
    
    func gotocustomizeDeisgn() {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomizeDesignViewController") as! CustomizeDesignViewController
        vc.modalPresentationStyle = .fullScreen
        vc.stringValue = stringValue
        vc.delegate = self
        vc.position = position1
        vc.shape = shape1
        vc.logoImage = logo1
        vc.foreGroundColor = colora
        vc.backgroundColor = colorb
        vc.pupil = pupil1
        vc.pupilColor = pupilColor
        vc.eyeColor = eyeColor
        vc.shapeColor = shapeColor
        vc.eyeGradeint = eyeGradeint
        vc.pupilGradent = pupilGradent
        vc.shapeGradeint = shapeGradeint
        vc.selectedIamge = selectedIamge
        
        if let data = gifData {
            vc.isFromGif = true
            
        }
        
        transitionVc(vc: vc, duration: 0.4, type: .fromRight)
        
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let currentTime = Date().timeIntervalSince1970
        
        // Only update if 0.1 seconds have passed since the last update
        if currentTime - lastUpdateTime >= updateDelay {
            lastUpdateTime = currentTime
            fontSize = String(format: "%.2f", sender.value)
            self.updateAllTextValue()
            
        }
    }
    
    @IBAction func gotoTemplateView(_ sender: Any) {
        
        wowBtn.alpha = 1
        backBtnp.alpha = 0
        
        if reachability.connection == .unavailable {
            
            self.showNoConnectionAlert()
            return
        }
        
        if !isfromQr {
            
         
            if (!Store.sharedInstance.isActiveSubscription()) {
                // Check if user already used their free pass
                let hasUsedFreePass = UserDefaults.standard.bool(forKey: "HasUsedFreePass")
                
                if hasUsedFreePass {
                    // 🚫 Already used, force subscription
                
                    return
                } else {
                    // ✅ First time free access, mark as used
                    UserDefaults.standard.set(true, forKey: "HasUsedFreePass")
                }
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "ProductVc") as! ProductVc
            initialViewController.modalPresentationStyle = .fullScreen
            initialViewController.barCode = stringValue

            if let topVC = UIApplication.topMostViewController {
                topVC.present(initialViewController, animated: true, completion: nil)
            }

            
            
           
        }
        
        UIView.animate(withDuration: 0.1, // Duration of animation
                       animations: {
            // Change the position and size of the view
            self.bottomSpaceTemplateView.constant = 0
            self.bottomSpaceText.constant = -5000
            self.view.layoutIfNeeded()
        })
    }
    
    
    
    func updateImage(imGW:UIImage) {
        
        
        let widthRatio = 0.2
        let heightRatio = 0.2
        let centerX = 0.5
        let centerY = 0.5
        doc.logoTemplate = QRCode.LogoTemplate(
            image:  (imGW.cgImage!),
            path: CGPath(
                rect: CGRect(x: centerX - widthRatio / 2, y: centerY - heightRatio / 2, width: widthRatio, height: heightRatio),
                transform: nil
            )
        )
        
    }
    
    
    
    func updatePosition(name: String) {
        
        position1 = name
        
        print("posiion name \(position1)")
        
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
    
    
    func updateShape(name:String) {
        
        shape1  = name
        
        print("shape name \(shape1)")
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
    
    
    private func setupCustomSlider() {
        // Initialize the custom slider
        customSlider = Slider(frame: CGRect(x: 0, y: 0, width: sliderView.frame.size.width, height: sliderView.frame.size.height))
        
        // Optional: Set slider properties like min, max values, and initial value
        customSlider.minimumValue = 10
        customSlider.maximumValue = 25
        customSlider.value = 13 // Set initial value
        
        // Optional: Add target for value changes
        customSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        // Add it to the view
        sliderView.addSubview(customSlider)
        
        if isfromQr {
            if isfromUpdate {
                customSlider.value = Float(self.fontSize) ?? 15.0
            }
        }
    }
    
    // Action when slider value changes
    
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
    
    
    func cgColorFromRGB(_ rgb: (r: Int, g: Int, b: Int)) -> CGColor {
        return CGColor(
            red: CGFloat(rgb.r) / 255.0,
            green: CGFloat(rgb.g) / 255.0,
            blue: CGFloat(rgb.b) / 255.0,
            alpha: 1.0
        )
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
    
    
    func shimmerImage(view: UIView) {
        // Remove existing observer (if any)
        NotificationCenter.default.removeObserver(view, name: UIApplication.willEnterForegroundNotification, object: nil)

        // Remove existing shimmer layer if any
        view.layer.sublayers?.removeAll(where: { $0.name == "shimmerGradient" })

        view.layoutIfNeeded()

        // Avoid applying shimmer if view has no size
        guard view.bounds.width > 0 else { return }

        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.6).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.name = "shimmerGradient"

        // Mask the view's layer with gradient
        view.layer.mask = gradientLayer

        // Animation logic
        func addShimmerAnimation() {
            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [-1, -0.5, 0]
            animation.toValue = [1, 1.5, 2]
            animation.duration = 4
            animation.repeatCount = .infinity
            gradientLayer.add(animation, forKey: "shimmer")
        }

        addShimmerAnimation()

        // Re-apply shimmer on foreground
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
            addShimmerAnimation()
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

    
    
    func updateAll() {
        print("image i found \("sadiq1")")
        if templateImage != nil {
            print("image i found \("sadiq")")
            templateImv.alpha = 1
        }
        
        doc.utf8String = stringValue
        doc.errorCorrection = .high
        
        self.updatePosition(name: position1)
        self.updateShape(name: shape1)
        self.setPupilShape(for: pupil1)
        
        if let v = logo1 {
            self.updateImage(imGW: v)
        }
        else {
            doc.logoTemplate = nil
             
        }
        
        if let data = gifData {
            doc.design.backgroundColor(UIColor.clear.cgColor)
        }
        else {
            doc.design.backgroundColor(colorb.cgColor)
        }
        doc.design.foregroundColor(colora.cgColor)
        print("Preview position color i get: \(position1)")
        print("Preview shape color i get: \(shape1)")
        print("Preview pupil color i get: \(shape1)")

        
        
        if let rgb = colorb.toRGB() {
            print("Preview background color i get: \(rgb.red), Green: \(rgb.green), Blue: \(rgb.blue)")
        } else {
            print("Could not convert color to RGB")
        }
        
        
        if let rgb = colora.toRGB() {
            print("Preview foreground color i get: \(rgb.red), Green: \(rgb.green), Blue: \(rgb.blue)")
        } else {
            print("Could not convert color to RGB")
        }
        
        
        if let image = selectedIamge {
            doc.design.style.background = QRCode.FillStyle.Image(image: image)
            doc.design.additionalQuietZonePixels = 5
        }
        
        if let value = eyeColor {
            doc.design.style.eye = QRCode.FillStyle.Solid(value.cgColor)
            
            
            
            if let rgb = value.toRGB() {
                print("Preview eyeColor color i get: \(rgb.red),\(rgb.green),\(rgb.blue)")
            } else {
                print("Could not convert color to RGB")
            }
            
        }
       
        
        if let value = shapeColor {
            doc.design.style.onPixels = QRCode.FillStyle.Solid(value.cgColor)
            
            if let rgb = value.toRGB() {
                print("Preview shapeColor color i get: \(rgb.red).\(rgb.green),\(rgb.blue)")
            } else {
                print("Could not convert color to RGB")
            }
        }
        
        
        if let value = pupilColor {
            doc.design.style.pupil = QRCode.FillStyle.Solid(value.cgColor)
            
            if let rgb = value.toRGB() {
                print("Preview pupilColor color i get: \(rgb.red),\(rgb.green),\(rgb.blue)")
            } else {
                print("Could not convert color to RGB")
            }
        }
        
        
        print("Preview eyeGradeint color i get: \(eyeGradeint)")
        print("Preview pupilGradent color i get: \(pupilGradent)")
        print("Preview shapeGradeint color i get: \(shapeGradeint)")

        
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
        
        if templateImage != nil {

            templateImv.isHidden = false
            imv.isHidden = true

            guard let templateImage = templateImage,
                  let qrCodeImage = imv.image else { return }

            if isfromHistory{
                showDynamicContentView(
                    withTemplate: templateImage,
                    qrCode: qrCodeImage,
                    withText:  templateResultView?.labelText
                )
            }
            else{
                templateResultView?.updateQRCode(newQRCode: qrCodeImage)
            }


        } else {
            templateImv.isHidden = true
        }
        
    }
    
    
   
    
     
    @IBAction func gotoPreview(_ sender: Any) {
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "PresetViewController") as! PresetViewController
        initialViewController.modalPresentationStyle = .fullScreen
        initialViewController.delegate = self
        
        self.present(initialViewController, animated: true, completion: nil)
    }
    private func requestContactsAccess() {
        
        store.requestAccess(for: .contacts) {granted, error in
            if granted {
                
                DispatchQueue.main.async {
                    self.accessGrantedForContacts()
                }
                
            }
        }
    }
    
    private func checkContactsAccess() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
            // Update our UI if the user has granted access to their Contacts
        case .authorized:
            self.accessGrantedForContacts()
            
            // Prompt the user for access to Contacts if there is no definitive answer
        case .notDetermined :
            self.requestContactsAccess()
            
            // Display a message if the user has denied or restricted access to Contacts
        case .denied,
                .restricted:
            let alert = UIAlertController(title: "Privacy Warning!",
                                          message: "Permission was not granted for Contacts.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localize(), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        @unknown default:
            print("sadiqul amin")
        }
    }
    private func accessGrantedForContacts() {
        
        let mutableContact:CNMutableContact!
        
        if stringValue.containsIgnoringCase(find: "MECARD") {
            mutableContact = contactCard
        }
        else{
            mutableContact = contacts.first!.mutableCopy() as! CNMutableContact
        }
        
        
        IHProgressHUD.show(withStatus: "Saving ........")
        let request = CNSaveRequest()
        request.add(mutableContact, toContainerWithIdentifier: nil)
        do{
            try store.execute(request)
            DispatchQueue.main.async {
                IHProgressHUD.dismiss()
            }
            
            self.showToast(message: "Contact has been added", font: .systemFont(ofSize: 12.0))
            
        } catch let err{
            DispatchQueue.main.async {
                IHProgressHUD.dismiss()
            }
            print("Failed to save the contact. \(err)")
        }
    }
    
    
    @IBAction func gotoText(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3) {
            self.bottomSpaceText.constant = -5000
            self.view.layoutIfNeeded()
        }
        self.applyLabelStyle()
        
    }
    @IBAction func dismissTheText(_ sender: Any) {
        
        
        UIView.animate(withDuration: 0.3) {
            self.bottomSpaceText.constant = -5000
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        bottomSpaceTemplateView.constant = -5000
        
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            // Adjust the view or scroll view's content inset here
            let keyboardHeight = keyboardFrame.height
            
            UIView.animate(withDuration: 0.3) {
                self.bottomSpaceText.constant = keyboardHeight
                self.view.layoutIfNeeded()
            }
            
        }
        
        
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        print("text i got \(textFiled.text ?? "")")
        tempText1 = textFiled.text ?? ""
        self.updateAllTextValue()
        UIView.animate(withDuration: 0.3) {
            self.bottomSpaceText.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        
        
        bottomTemplateView?.collectionviewForText.reloadData()
        bottomTemplateView?.collectionviewForTemplate.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isfromUpdate {
            
            if let data = gifData {
                
                shape1 = "data_star"
            }
            self.updateAll()
        }
        wowBtn.alpha = 0
        
        
        if isfromUpdate {
            
            if isFromGif {
                gifData  = self.getGifDataFromDocuments(fileName: templateFileName ?? "")
            }
        }
        
        
        captionView.isUserInteractionEnabled = false
        captionView.alpha = 0.4
       
        
        wid.text = "MakeW".localize()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("purchaseNoti"), object: nil)
        
        preview.text = "Preset"
        
        templateLabel.text = "Template".localize()
        deisgnLabel.text = "Color".localize()
        contentLabel.text = "Logo".localize()
        shareLabel.text = "Pixel".localize()
        fontsizeLabel.text = "Font Size".localize()
        colorLabel.text = "Color".localize()
        captionLabel.text = "Captions".localize()
        fontlabel.text = "Font".localize()
        eyesLabel.text = "Eyes".localize()
        widghetLabel.text = "Widgets".localize()
        textFiled.placeholder = "Enter Text".localize()
        
        bottomTemplateView  = BottomTemplateView.loadFromXib()
        
        
        
        
        bottomTemplateView?.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        textFiled.addDoneButtonOnKeyboard()
        self.setColor()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            self.addXibFile()
        }
        
        collectionViewForFont.register(UINib(nibName: "FontCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FontCollectionViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            self.setupCustomSlider()
            collectionViewForFont.reloadData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2){ [self] in
            updateAllTextValue()
            self.textChangeholderView.roundCorners([.topRight,.topLeft], radius: 40)
            self.templateResultView?.makeLabelHidden(hidden: false)
        }
        
        btn.layer.cornerRadius = btn.frame.size.height / 2.0
        btn.clipsToBounds = true
        
        store = CNContactStore()
        if isfromQr {
            Store.sharedInstance.shouldShowLabel = false
        }
        if showText.count > 0 {
            outputResult = showText.components(separatedBy: "^") as NSArray
            showText = (outputResult[0] as? String)!
            // type = (outputResult[1] as? String)!
            //print(type)
            
            
            
        }
        tablewView.separatorColor = UIColor.clear
        
        print("mamammamamamamamammaa: \(stringValue)")
        
        
        
        if stringValue.containsIgnoringCase(find: "vcard") {
            
            if let data = stringValue.data(using: .utf8) {
                do{
                    contacts = try CNContactVCardSerialization.contacts(with: data)
                    let contact = contacts.first
                    
                    
                    
                }
                catch{
                    // Error Handling
                    print(error.localizedDescription)
                }
            }
            
        }
        
        if  isfromQr {
            self.updateAll()
        }
        else {
            
            Analytics.logEvent("Bar code has been called", parameters: [
                "categoryName": currenttypeOfQrBAR,
                "imageid": stringValue
            ])
            
            
            
            var output = "BarCode Detail"
            output =  output + "\n\n"
            output = output + stringValue
            
            
            if let img = BarCodeGenerator.getBarCodeImage(type: currenttypeOfQrBAR, value: stringValue) {
                
                
                image = img
                
                labelText.text = output
                
                let height = image.size.height
                let width = image.size.width
                
                print(width)
                print(height)
                
                imv.image = image
                //barTextValue.text = stringValue
                qrCodeShowView.isHidden = true
                
            }
            
            
        }
        
        if Store.sharedInstance.shouldShowLabel {
            deductionValue = 70
            barLabelText.isHidden = false
            barLabelText.text = stringValue
        }
        else {
            deductionValue = 0
            barLabelText.isHidden = true
            barLabelText.text = ""
        }
        Store.sharedInstance.shouldShowLabel = false
        
        
        
        if isfromQr {
            if isfromUpdate {
                // ✅ Safe unwrap with nil coalescing (empty array if nothing found)
                let savedArray = UserDefaults.standard.object(forKey: "array\(idF)") as? [[String: String]] ?? []
                createDataModelArray = savedArray.map { ResultDataModel(dictionary: $0) }
                
                let stringValue1 = "colora\(idF)"
                let stringValue2 = "colorb\(idF)"
                let stringValue3 = "colorc\(idF)"
                let stringValue4 = "colord\(idF)"
                let stringValue5 = "colore\(idF)"
                let stringValue6 = "colorf\(idF)"
                let stringValue7 = "colorg\(idF)"
                let stringValue8 = "colorh\(idF)"
                
                // ✅ Provide fallback colors (black if missing)
                colora = UserDefaults.standard.color(forKey: stringValue1) ?? .black
                colorb = UserDefaults.standard.color(forKey: stringValue2) ?? .black
                
                // ✅ Safe decoding with try?
                if let data = UserDefaults.standard.data(forKey: "backgroundIm\(idF)"),
                   let decoded = try? PropertyListDecoder().decode(Data.self, from: data),
                   let image = UIImage(data: decoded) {
                    selectedIamge = image
                    colorb = .clear
                }
                
                // ✅ Optional unwrapping for colors
                if let v1 = UserDefaults.standard.color(forKey: stringValue3) {
                    eyeColor = v1
                }
                if let v1 = UserDefaults.standard.color(forKey: stringValue4) {
                    pupilColor = v1
                }
                if let v1 = UserDefaults.standard.color(forKey: stringValue5) {
                    shapeColor = v1
                }
                
                // ✅ Integers with defaults (0 if not found)
                eyeGradeint   = UserDefaults.standard.object(forKey: stringValue6) as? Int ?? 0
                pupilGradent  = UserDefaults.standard.object(forKey: stringValue7) as? Int ?? 0
                shapeGradeint = UserDefaults.standard.object(forKey: stringValue8) as? Int ?? 0
            }
            
            self.updateAll()
        }

        
        if isfromUpdate {
            if tempText1.count > 0 {
                textFiled.text = tempText1
            }
             
            
            guard let data = UserDefaults.standard.data(forKey: "logo\(idF)") else { return }
            let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
            logo1 = UIImage(data: decoded)
            self.updateAll()
        }
        
        
        
        isfromHistory = false
        self.updateTemplateimv()
        
        if let value = selectedPreset {
            self.setAllValue(obj: value)
        }
        
        print("temp name i got \(templateFileName)")
        
        
        if let value  = templateFileName {
            captionView.alpha = 1.0
            captionView.isUserInteractionEnabled = true
        }
        tablewView.register(UINib(nibName: "TextCellStyle", bundle: nil), forCellReuseIdentifier: "TextCellStyle")
        tablewView.separatorColor = UIColor.clear
       
        tablewView.showsVerticalScrollIndicator = false
        tablewView.showsHorizontalScrollIndicator = false
    }
    
    @IBAction func downTheViewForT(_ sender: Any) {
        wowBtn.alpha = 0
        backBtnp.alpha = 1
        
        UIView.animate(withDuration: 0.4,
                          delay: 0,
                          options: [.curveEaseInOut],
                          animations: {
               self.bottomSpaceTemplateView.constant = -5000
               self.view.layoutIfNeeded()
           },
                          completion: nil)
    }
    
    func updateTemplateimv() {
        if templateFileName?.count ?? 0 > 0 {
            print("temp text i got do not get me wrong \(tempText1)")
            
            templateImv.isHidden = false
            imv.isHidden = true
            
            guard let templateImage = templateImage,
                  let qrCodeImage = imv.image else { return }
            
            if let existingTemplateView = templateResultView {
                existingTemplateView.updateTemplate(with: templateImage) {
                    UIView.animate(withDuration: 0.3) {
                        self.templateImv.alpha = 1
                    }
                    
                    if (self.templateResultView?.isLabelVisible ?? true){
                        if !self.tempText1.isEmpty {
                            self.templateResultView?.setLabelText(self.tempText1)
                        } else if let currentText = self.templateResultView?.labelText {
                            self.templateResultView?.setLabelText(currentText)
                        }
                    }
                    
                    if self.savedLabelWidth > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.templateResultView?.setLabelDimensions(width: self.savedLabelWidth)
                            print("Restoring label width in updateTemplateimv: \(self.savedLabelWidth)")
                        }
                    }
                }
            } else {
                showDynamicContentView(
                    withTemplate: templateImage,
                    qrCode: qrCodeImage,
                    withText: templateResultView?.labelText
                )
            }
        } else {
            templateImv.isHidden = true
        }
    }
    
    func updateTemplateImage(with newTemplateImage: UIImage) {
        self.templateImage = newTemplateImage
        
        if templateImv.isHidden {
            templateImv.isHidden = false
            imv.isHidden = true
        }
        
        if let templateResultView = self.templateResultView {
            templateResultView.updateTemplate(with: newTemplateImage) {
                UIView.animate(withDuration: 0.3) {
                    self.templateImv.alpha = 1
                }
                
                if self.savedLabelWidth > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.templateResultView?.setLabelDimensions(width: self.savedLabelWidth)
                    }
                }
            }
        } else {
            guard let qrCodeImage = imv.image else { return }
            
            showDynamicContentView(
                withTemplate: newTemplateImage,
                qrCode: qrCodeImage,
                withText: nil,
                animated: true
            )
        }
    }
    
    @IBAction func gotoTickViewTemplate(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.bottomSpaceTemplateView.constant = -5000
            self.view.layoutIfNeeded()
        }
        
    }
    func addXibFile() {
        
        middleView.roundCorners([.topRight,.topLeft], radius: 30)
        bottomTemplateView?.frame = CGRect(x: 0, y: 20, width: holderTemplateView.frame.size.width, height: 430)
        if let view  = bottomTemplateView {
            middleView.addSubview(view)
        }
        
        if !isfromQr {
            holderTemplateView.alpha = 0
            textChangeholderView.alpha = 0
        }
        
    }
    
    
    private func showDynamicContentView(withTemplate template: UIImage, qrCode: UIImage, withText text: String?, animated: Bool = true) {
        
        if isFromGif {
            return
        }
        templateImv.alpha = 0
        templateImv.isHidden = false
        
        templateImv.subviews.forEach { subview in
            if subview is TemplateResultView {
                subview.removeFromSuperview()
            }
        }
        
        let contentView = TemplateResultView(frame: templateImv.bounds)
        contentView.delegate = self
        
        contentView.alpha = 0
        
        contentView.configure(withTemplate: template, qrCode: qrCode, text: text) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let labelSize = self.templateResultView?.getLabelDimensions() {
                    self.savedLabelWidth = labelSize.width
                    print("Saved label width: \(self.savedLabelWidth)")
                    
                    UIView.animate(withDuration: 0.3) {
                        self.templateImv.alpha = 1
                        contentView.alpha = 1
                    }
                }
            }
        }
        
        contentView.onAddTextTapped = { [weak self] in
           
        }
        
        contentView.onClose1Tapped = {
            print("Label was closed")
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        templateImv.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: templateImv.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: templateImv.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: templateImv.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: templateImv.bottomAnchor)
        ])
        
        self.templateResultView = contentView
    }
    
    
    private var templateResultView: TemplateResultView?
    
    @objc private func saveTemplateImage() {
        guard let templateView = templateResultView else { return }
        
        let highResImage = templateView.exportImage(size: CGSize(width: 1500, height: 1500))
        
        // Save to photos
        UIImageWriteToSavedPhotosAlbum(highResImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            self.showToast(message: "Image saved to photos", font: .systemFont(ofSize: 12.0))
        }
    }
    
    @IBAction func gotoShare(_ sender: Any) {
        
        if let data = gifData {
            
            self.shareGlobalGif()
            return
            
        }
        if let templateView = templateResultView {
            let highResImage = templateView.exportImage(size: CGSize(width: 1500, height: 1500))
            
            let imageShare = [highResImage]
            let activityViewController = UIActivityViewController(activityItems: imageShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            
            let imageShare = [imv.image!]
            let activityViewController = UIActivityViewController(activityItems: imageShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    func shareGlobalGif() {
        // 1️⃣ Show progress HUD
        SVProgressHUD.show(withStatus: "Generating GIF...")

        createQRGif(from: gifData as! NSData, content: stringValue, isFromSave: true) { resultGifData in
            DispatchQueue.main.async {
                // 2️⃣ Dismiss progress HUD
                SVProgressHUD.dismiss()
                
                if let data = resultGifData {
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("qrGif.gif")
                    do {
                        try data.write(to: tempURL)
                        
                        // Prepare activity items
                        let imageShare = [tempURL]
                        let activityViewController = UIActivityViewController(activityItems: imageShare, applicationActivities: nil)
                        
                        
                        self.present(activityViewController, animated: true, completion: nil)
                        
                    } catch {
                        print("Failed to write GIF to temp file: \(error)")
                    }
                } else {
                    print("Failed to create QR GIF")
                }
            }
        }
    }

    
    
    
    @IBAction func gotoEditContent(_ sender: Any) {
        
        
        if let v =  eventF {
            let eventController = EKEventEditViewController()
            eventController.event = v
            eventController.editViewDelegate = self
            eventController.modalPresentationStyle = .fullScreen
            self.present(eventController, animated: true)
            return
        }
        
        
        
        
        
        if !isfromQr {
            createDataModelArray.removeAll()
            createDataModelArray.append(ResultDataModel(title: "Enter value", description: stringValue))
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditVc") as! EditVc
        vc.modalPresentationStyle = .fullScreen
        vc.createDataModelArray = createDataModelArray
        vc.delegate = self
        vc.currenttypeOfQrBAR = currenttypeOfQrBAR
        vc.isFromQr = isfromQr
        transitionVc(vc: vc, duration: 0.4, type: .fromRight)
        
        
    }
    
    func saveData() {
        
        var temp = ""
        var tempText = ""
        
        if let value = templateFileName {
            temp = value
            tempText = templateResultView?.labelText ?? ""
        }
        
        if isfromUpdate {
            DBmanager.shared.updateTableData(id: idF, Text: stringValue, position: position1, shape: shape1, logo: currenttypeOfQrBAR,temp: temp,tempText: tempText,fontcolor: fontColor,fontfamily:fontFamily,fontsize: fontSize, pupil: pupil1)
            
        }
        else {
            
            
            if !isfromUpdate, let data = gifData  {
                
                self.saveGifToDocuments(gifData: data , templateFileName: templateFileName ?? "")
                Store.sharedInstance.currentIndexPath = "3"
                DBmanager.shared.insertRecordIntoFile(Text: stringValue, codeType: "3", indexPath: "2",position: position1, shape: shape1, logo: currenttypeOfQrBAR,temp: temp,tempText: tempText,fontcolor: fontColor,fontfamily:fontFamily,fontsize: fontSize, pupil: pupil1)
            }
            
            else if isfromQr {
                
                if isFromScanned  {
                    Store.sharedInstance.currentIndexPath = "1"
                    DBmanager.shared.insertRecordIntoFile(Text: stringValue, codeType: "1", indexPath: "1",position: position1, shape: shape1, logo: currenttypeOfQrBAR,temp: temp,tempText: tempText,fontcolor: fontColor,fontfamily:fontFamily,fontsize: fontSize, pupil: pupil1)
                }
                else {
                    Store.sharedInstance.currentIndexPath = "2"
                    DBmanager.shared.insertRecordIntoFile(Text: stringValue, codeType: "1", indexPath: "2",position: position1, shape: shape1, logo: currenttypeOfQrBAR,temp: temp,tempText: tempText,fontcolor: fontColor,fontfamily:fontFamily,fontsize: fontSize, pupil: pupil1)
                }
            }
            else {
                
                if isFromScanned  {
                    Store.sharedInstance.currentIndexPath = "1"
                    DBmanager.shared.insertRecordIntoFile(Text: stringValue, codeType: "2", indexPath: "1",position: position1, shape: shape1, logo: currenttypeOfQrBAR,temp: temp,tempText: tempText,fontcolor: fontColor,fontfamily:fontFamily,fontsize: fontSize, pupil: pupil1)
                }
                else {
                    Store.sharedInstance.currentIndexPath = "2"
                    DBmanager.shared.insertRecordIntoFile(Text: stringValue, codeType: "2", indexPath: "2",position: position1, shape: shape1, logo: currenttypeOfQrBAR,temp: temp,tempText: tempText,fontcolor: fontColor,fontfamily:fontFamily,fontsize: fontSize, pupil: pupil1)
                }
            }
        }
        
        DBmanager.shared.getMaxIdForRecord() { [weak self] id in
            guard let self else {
                print("Can't make self strong!")
                return
            }
            var id = id
            
            print(idF)
            if idF.count > 0 {
                id  = Int(idF) ?? 0
            }
            
            
            let cfcpArray = createDataModelArray.map{ $0.dictionaryRepresentation}
            UserDefaults.standard.set(cfcpArray, forKey: "array\(id)")
            
            let fileName = "Image\(id)"
            
            if isfromQr {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    saveImageInDocumentDirectory(image: self.imv.image!, fileName: fileName)
                }
            }
            else {
                if Store.sharedInstance.shouldShowLabel {
                    
                }
                else {
                    saveImageInDocumentDirectory(image: imv.image!, fileName: fileName)
                }
            }
            
            let stringValue = "colora\(id)"
            let stringValue1 = "colorb\(id)"
            let stringValue2 = "colorc\(id)"
            let stringValue3 = "colord\(id)"
            let stringValue4 = "colore\(id)"
            let stringValue5 = "colorf\(id)"
            let stringValue6 = "colorg\(id)"
            let stringValue7 = "colorh\(id)"
            
            if let v1 = eyeColor {
                UserDefaults.standard.set(v1, forKey: stringValue2)
            }
            if let v2 = pupilColor {
                UserDefaults.standard.set(v2, forKey: stringValue3)
            }
            if let v3 = shapeColor {
                UserDefaults.standard.set(v3, forKey: stringValue4)
            }
            
            UserDefaults.standard.set(eyeGradeint, forKey:stringValue5)
            UserDefaults.standard.set(pupilGradent, forKey: stringValue6)
            UserDefaults.standard.set(shapeGradeint, forKey: stringValue7)
            
            UserDefaults.standard.set(colora, forKey: stringValue)
            UserDefaults.standard.set(colorb, forKey: stringValue1)
            
            
            if let v = logo1 {
                guard let data = v.jpegData(compressionQuality: 1.0) else { return }
                let encoded = try! PropertyListEncoder().encode(data)
                UserDefaults.standard.set(encoded, forKey: "logo\(id)")
            }
            
            if let v1 = selectedIamge {
                guard let data = v1.jpegData(compressionQuality: 1.0) else { return }
                let encoded = try! PropertyListEncoder().encode(data)
                UserDefaults.standard.set(encoded, forKey: "backgroundIm\(id)")
            }
        }
        
        
        
        
    }
    
    @IBAction func gotoSve(_ sender: Any) {
        
        
        self.saveData()
        
        
        Store.sharedInstance.setPopValue(value: true)
        Store.sharedInstance.setShowHistoryPage(value: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sadiq"), object: nil)
        // self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        delegateDis?.dimissAllClass()
        
        
        let defaults = UserDefaults.standard
        
        var valueOfText  = defaults.integer(forKey: "no_of_image")
        
        let boolValue = UserDefaults.standard.bool(forKey: "given")
        
        
        if (valueOfText % 5 == 0 && boolValue == false && valueOfText < 15) {
            
            let alertView = SwiftAlertView(title: "Rate QRMaker App",
                                           message:  "rate_title".localize(),
                                           buttonTitles: ["Rate ScannR App".localize(), "Remind me later".localize()])
            alertView.delegate = self
            alertView.transitionType = .vertical
            alertView.appearTime = 0.2
            alertView.disappearTime = 0.2
            alertView.show()
            UserDefaults.standard.set(valueOfText + 1, forKey:"no_of_image")
            return
        }
        
        else if( valueOfText  == 2){
            
            if #available(iOS 14.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            } else {
                SKStoreReviewController.requestReview()
            }
        }
        
        UserDefaults.standard.set(valueOfText + 1, forKey:"no_of_image")
        self.dismiss(animated: true) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sadiq"), object: nil)
        }
        
    }
    
    func showNoConnectionAlert() {
        let alert = UIAlertController(title: "No Internet".localize(), message: "internet_connection".localize(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localize(), style: .default, handler: nil))
        
        if let topVC = UIApplication.topMostViewController {
            topVC.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        widthForMainView.constant =  200
        heightForMainView.constant = 200
        
        
        roundedHolderView.layer.cornerRadius = 40
        roundedHolderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        roundedHolderView.layer.masksToBounds = true
        
        let size = AVMakeRect(aspectRatio: imv.image!.size, insideRect: imv.frame)
        widthForMainView.constant = size.width
        heightForMainView.constant = size.height
    }
    
    
    func dialNumber(number : String) {
        
        if let url = URL(string: "tel://\(number)"),
           UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // add error message here
        }
        
    }
    
    func convertToSeconds(hours: Int, minutes: Int, seconds: Int) -> Int {
        let totalSeconds = hours * 3600 + minutes * 60 + seconds
        return totalSeconds
    }
    
    func calculateTimeDifference(referenceDate: Date) -> (hours: Int, minutes: Int, seconds: Int) {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: referenceDate, to: currentDate)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        return (hours, minutes, seconds)
    }
    
    
    @IBAction func gotoOffer(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OfferVc") as! OfferVc
        vc.modalPresentationStyle = .overCurrentContext
        UIApplication.topMostViewController?.present(vc, animated: true, completion: {
        })
        
    }
    
    
    func formatSecondsToHHMMSS(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func doSetup() {
        let userDefaults = UserDefaults.standard
        if let savedDate = userDefaults.object(forKey: "lastLoginDate") as? Date {
            
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                let (hours, minutes, seconds) = self.calculateTimeDifference(referenceDate: savedDate)
                
                let value = self.convertToSeconds(hours: hours, minutes: minutes, seconds: seconds)
                let value1 = self.convertToSeconds(hours: 24, minutes: 0, seconds: 0)
                
                
                
                let newValue = value1 - value
                
                if (newValue > 0 && !Store.sharedInstance.isActiveSubscription()) {
                    
                    let v = self.formatSecondsToHHMMSS(seconds: value1)
                    print("sadiq \(v)")
                    self.timeLabel.text = self.formatSecondsToHHMMSS(seconds: newValue)
                }
                else {
                    self.topView.isHidden = true
                    self.heightForTopView.constant = 0
                    
                }
                
                
            }
            
        }
    }
    
    
    @objc func appWillEnterForeground() {
        
        self.doSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       
        super.viewWillAppear(animated)
        
        self.shimmerText(label: preview)
        
       
       
        
        
        backBtn.setTitle("Back".localize(), for: .normal)
        saveBtn.setTitle("Save".localize(), for: .normal)
        
        print("template file name i got \(templateFileName ?? "")")
        
        let formattedPrice =  yearlyPrice + "/year"
        
        let attribtues = [
            NSAttributedString.Key.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue),
            NSAttributedString.Key.strikethroughColor: UIColor(red: 19/255.0, green: 105/255.0, blue: 79/255.0, alpha: 1.0)
        ]
        let attr = NSAttributedString(string: formattedPrice, attributes: attribtues)
        yearlyLabel.attributedText = attr
        
        lifeTime.text = oneTimePrice + "/" + "Lifetime"
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.doSetup()
        
        if !Store.sharedInstance.isActiveSubscription() {
            
            let userDefaults = UserDefaults.standard
            
            // Check if the date is nil in UserDefaults
            if let savedDate = userDefaults.object(forKey: "offer") as? Date {
                
                
                
            } else {
                // Date doesn't exist, save it
                //                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OfferVc") as! OfferVc
                //                vc.modalPresentationStyle = .overCurrentContext
                //                UIApplication.topMostViewController?.present(vc, animated: true, completion: {
                //                })
                //                let currentDate = Date()
                //                userDefaults.set(currentDate, forKey: "offer")
                //                userDefaults.synchronize() // Synchronize changes (optional in modern iOS/macOS)
                //                print("Saved new date: \(currentDate)")
            }
            
            
        }
        
        
        
        
        DispatchQueue.main.async {
            //KRProgressHUD.dismiss()
        }
        
        copyTetx.text = "Copy Text".localize()
        
      
        
        if stringValue.containsIgnoringCase(find: "geo") || stringValue.containsIgnoringCase(find: "vcalendar") {
            bnTextContent.isHidden = true
        }
        
        if stringValue.containsIgnoringCase(find: "WIFI") {
            
            copyTetx.text = "Connect".localize()
           
        }
        if stringValue.containsIgnoringCase(find: "tel") {
          
            
            copyTetx.text = "Call".localize()
        }
        if stringValue.containsIgnoringCase(find: "sms") {
           
            
            copyTetx.text = "SMS".localize()
        }
        if showText.containsIgnoringCase(find: "Url") {
           
            
            copyTetx.text = "Go to Url".localize()
        }
        
        if stringValue.containsIgnoringCase(find: "mailto") {
            
            copyTetx.text = "Email".localize()
            
        }
        
        if stringValue.containsIgnoringCase(find: "vcard") {
            
            copyTetx.text = "Add to Contact".localize()
            
        }
        
        if stringValue.containsIgnoringCase(find: "mecard") {
            
            copyTetx.text = "Add to Contact".localize()
             
        }
        
        
        
        
        if currenttypeOfQrBAR.containsIgnoringCase(find: "event") || currenttypeOfQrBAR.containsIgnoringCase(find: "location") {
            editContentView.isHidden =  true
        }
        
        if !isfromQr  {
            customizeView.isHidden =  true
            tempLabel.text = "Product Info"
            previewl.alpha = 0
            tempIcon.image = UIImage(named: "prod")
            
        }
        else {
            
            customizeView.isHidden =  false
            labelText.text = "QrCode Detail".localize()
        }
        IHProgressHUD.dismiss()
        
        var flag1  = 0
        for item in createDataModelArray {
            
            if item.description.count > 0 {
                print("paisi mia \(item.description)")
                flag1 = 1
            }
        }
        if flag1 == 0,isfromQr {
            editContentView.isHidden = true
        }
        
        if let data = gifData {
            isFromGif = true
        }
        
        
        if isFromGif {
            
            
            if !isfromUpdate {
                if shouldShowWhite {
                    colora = UIColor.white
                    self.updateAll()
                }
            }
            previewl.alpha = 0
            
            gifView.isHidden = false
            templateOption.isUserInteractionEnabled = false
           
            
            templateOption.alpha = 0.3
            
        
            
            createQRGif(from: gifData! as NSData, content: stringValue, isFromSave: false) { resultGifData in
                if let data = resultGifData {
                    do {
                        let gif = try UIImage(gifData: data as Data)
                        self.globalGifData = data
                        self.gifimv.setGifImage(gif, loopCount: -1) // -1 = infinite loop
                    } catch {
                        print("Failed to create GIF image: \(error)")
                    }
                } else {
                    print("Failed to create QR GIF")
                }
            }
            
            
            holderTemplateView.alpha = 0
            textChangeholderView.alpha = 0
        }
       
        //Store.sharedInstance.image = image
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
            
            present(mail, animated: true)
            
        } else {
            let alert = UIAlertController(title: "Note".localize(), message: "email_not_configured".localize(), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlert() {
        
        let alert = UIAlertController(title: "", message: "internet_connection".localize(), preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "ok".localize(), style: .default, handler: { action in
        })
        alert.addAction(ok)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        
    }
    
    func convertToCGFloat(fontSizeString: String) -> CGFloat {
        // Try to convert the string to a CGFloat (or Float/Double first)
        if let fontSizeFloat = Float(fontSizeString) {
            return CGFloat(fontSizeFloat)
        } else {
            // If conversion fails, return a default value
            print("Warning: Invalid font size string. Using default value of 12.0")
            return 15.0
        }
    }
    
    
    func updateAllTextValue() {
        
        
        
        self.applyLabelStyle()
    }
    
    func applyLabelStyle() {
        // Explicitly reference self for properties like fontColor, fontSize, fontFamily
        var colorIget = UIColor.brown
        let components = self.fontColor.split(separator: ",")
        
        if components.count == 3 {
            let red = CGFloat((Double(components[0]) ?? 0))
            let green = CGFloat((Double(components[1]) ?? 0))
            let blue = CGFloat((Double(components[2]) ?? 0))
            let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            colorIget = color
            print(color)
        }
        
        let fontSizeCGFloat = self.convertToCGFloat(fontSizeString: self.fontSize)
        
        self.templateResultView?.updateLabelStyle(
            text: tempText1, // You can modify this if needed
            font: {
                if self.fontFamily.containsIgnoringCase(find: "system") {
                    return UIFont.systemFont(ofSize: fontSizeCGFloat)
                } else {
                    if let customFont = UIFont(name: self.fontFamily, size: fontSizeCGFloat) {
                        return customFont
                    } else {
                        print("Warning: Custom font not found, falling back to system font.")
                        return UIFont.systemFont(ofSize: fontSizeCGFloat)
                    }
                }
            }(),
            color: colorIget
        )
    }
    
    @IBAction func copyText(_ sender: Any) {
        
        
        if stringValue.containsIgnoringCase(find: "vcard") {
            
            self.checkContactsAccess()
            return
        }
        
        if stringValue.containsIgnoringCase(find: "mecard") {
            
            
            contactCard = CNMutableContact()
            let value  = dict["vCard1"]
            var ar = value!.components(separatedBy: ",")  as? NSArray
            var array =  NSMutableArray(array: ar!) as! [String]
            var tempText = stringValue
            let maV = tempText.components(separatedBy: ";")
            tempText = tempText.replacingOccurrences(of: "mecard:", with: "")
            tempText = tempText.replacingOccurrences(of: "MECARD:", with: "")
            
            
            for item in maV {
                if(item.containsIgnoringCase(find:MeCardCostant.KEY_NAME)) {
                    var parsed = item.replacingOccurrences(of: MeCardCostant.KEY_NAME, with: "")
                    parsed = parsed.replacingOccurrences(of: MeCardCostant.KEY_NAME.lowercased(), with: "")
                    parsed = parsed.replacingOccurrences(of: "mecard:", with: "")
                    parsed = parsed.replacingOccurrences(of: "MECARD:", with: "")
                    let name = parsed.components(separatedBy: ",")
                    
                    
                    
                    if name.count == 1 {
                        array[0] = "First Name: " + name[0]
                        contactCard.givenName = name[0]
                        
                        print("yes")
                    }
                    
                    else if name.count == 2  {
                        array[0] = "First Name: " + name[1]
                        array[1] = "Last Name: " +  name[0]
                        
                        contactCard.givenName = name[1]
                        contactCard.familyName = name[0]
                        
                        print("yes1")
                    }
                }
                
                if(item.containsIgnoringCase(find:MeCardCostant.KEY_TELEPHONE)) {
                    
                    var parsed = item.replacingOccurrences(of: MeCardCostant.KEY_TELEPHONE.lowercased(), with: "")
                    parsed = parsed.replacingOccurrences(of: MeCardCostant.KEY_TELEPHONE.uppercased(), with: "")
                    parsed = parsed.replacingOccurrences(of: "mecard:", with: "")
                    parsed = parsed.replacingOccurrences(of: "MECARD:", with: "")
                    
                    
                    if parsed.count >= 1 {
                        array[2] =  "Phone Number: " + parsed
                    }
                    
                    let phoneNumber = CNPhoneNumber(stringValue: array[2])
                    let labelled = CNLabeledValue(label: "TEL", value:  phoneNumber)
                    contactCard.phoneNumbers = [labelled]
                    
                }
                
                if(item.containsIgnoringCase(find:MeCardCostant.KEY_EMAIL)) {
                    
                    var parsed = item.replacingOccurrences(of: MeCardCostant.KEY_EMAIL.lowercased(), with: "")
                    parsed = parsed.replacingOccurrences(of: MeCardCostant.KEY_EMAIL.uppercased(), with: "")
                    
                    
                    if parsed.count >= 1 {
                        array[3] =  "Email: " + parsed
                    }
                    let workEmail = CNLabeledValue(label:"Work Email", value:array[2]  as NSString)
                    contactCard.emailAddresses = [workEmail]
                    
                }
                
                if(item.containsIgnoringCase(find:MeCardCostant.KEY_URL)) {
                    
                    var parsed = item.replacingOccurrences(of: MeCardCostant.KEY_URL.lowercased(), with: "")
                    parsed = parsed.replacingOccurrences(of: MeCardCostant.KEY_URL.uppercased(), with: "")
                    
                    
                    if parsed.count >= 1 {
                        array[4] =  "URL: " + parsed
                    }
                    
                    let URL = CNLabeledValue(label:"URL", value:array[4]  as NSString)
                    contactCard.urlAddresses = [URL]
                    
                    
                }
                
                if(item.containsIgnoringCase(find:MeCardCostant.KEY_NICK_NAME)) {
                    
                    var parsed = item.replacingOccurrences(of: MeCardCostant.KEY_NICK_NAME.lowercased(), with: "")
                    parsed = parsed.replacingOccurrences(of: MeCardCostant.KEY_NICK_NAME.uppercased(), with: "")
                    
                    
                    if parsed.count >= 1 {
                        array[5] =  "NickName: " + parsed
                    }
                    
                    contactCard.nickname = array[5]
                }
                
                if(item.containsIgnoringCase(find:MeCardCostant.KEY_ADDRESS)) {
                    
                    var parsed = item.replacingOccurrences(of: MeCardCostant.KEY_ADDRESS.lowercased(), with: "")
                    parsed = parsed.replacingOccurrences(of: MeCardCostant.KEY_ADDRESS.uppercased(), with: "")
                    
                    if parsed.count >= 1 {
                        array[6] =  "Address: " + parsed
                    }
                    
                    let address = CNMutablePostalAddress()
                    address.street =  array[6]
                    let home = CNLabeledValue<CNPostalAddress>(label:CNLabelHome, value:address)
                    contactCard.postalAddresses = [home]
                }
                
                if item.containsIgnoringCase(find:MeCardCostant.KEY_ORG) {
                    
                    var parsed = item.replacingOccurrences(of: MeCardCostant.KEY_ORG.lowercased(), with: "")
                    parsed = parsed.replacingOccurrences(of: MeCardCostant.KEY_ORG.uppercased(), with: "")
                    
                    if parsed.count >= 1 {
                        array[7] =  "Organization: " + parsed
                    }
                    
                    contactCard.organizationName = array[7]
                }
                
                if item.containsIgnoringCase(find:MeCardCostant.KEY_NOTE) {
                    
                    var parsed = item.replacingOccurrences(of: MeCardCostant.KEY_NOTE.lowercased(), with: "")
                    parsed = parsed.replacingOccurrences(of: MeCardCostant.KEY_NOTE.uppercased(), with: "")
                    
                    if parsed.count >= 1 {
                        array[8] =  "Note: " + parsed
                    }
                }
                
                if item.containsIgnoringCase(find:MeCardCostant.KEY_DAY) {
                    
                    var parsed = item.replacingOccurrences(of: MeCardCostant.KEY_DAY.lowercased(), with: "")
                    parsed = parsed.replacingOccurrences(of: MeCardCostant.KEY_DAY.uppercased(), with: "")
                    
                    if parsed.count >= 1 {
                        array[9] =  "Birthday: " + parsed
                    }
                    contactCard.note = array[7]
                }
            }
            
            self.checkContactsAccess()
            return
        }
        
        
        if stringValue.containsIgnoringCase(find: "wifi") {
            
            var array = stringValue.components(separatedBy: ";")
            
            var name = ""
            var password = ""
            var type = ""
            
            for item in array {
                var mal = (item as? String)!.replacingOccurrences(of: "WIFI:", with: "", options: .literal, range: nil)
                mal = mal.replacingOccurrences(of: "wifi:", with: "", options: .literal, range: nil)
                
                if mal.containsIgnoringCase(find: "T:") {
                    
                    type =   mal.replacingOccurrences(of: "T:", with: "", options: .literal, range: nil)
                }
                
                if mal.containsIgnoringCase(find: "S:") {
                    
                    name =   mal.replacingOccurrences(of: "S:", with: "", options: .literal, range: nil)
                }
                if mal.containsIgnoringCase(find: "P:") {
                    
                    password =   mal.replacingOccurrences(of: "P:", with: "", options: .literal, range: nil)
                }
                
            }
            
            
            NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: name)
            
            var valuem = false
            if type.containsIgnoringCase(find: "wep") {
                valuem = true
            }
            
            let wiFiConfig = NEHotspotConfiguration(ssid: name, passphrase: password, isWEP: valuem)
            wiFiConfig.joinOnce = true
            NEHotspotConfigurationManager.shared.apply(wiFiConfig) { error in
                if let error = error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Alert".localize(), message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    // user confirmed
                }
            }
            
            return
            
        }
        
        
        
        
        if stringValue.containsIgnoringCase(find: "mailto") {
            
            var email = ""
            var  cc = ""
            var  subject = ""
            var body = ""
            
            
            let array = showText.components(separatedBy: "\n\n")
            
            for item in array {
                
                if let v = item as? String {
                    
                    if v.containsIgnoringCase(find: "email") {
                        let ar = v.components(separatedBy: ":")
                        
                        if ar.count > 1 {
                            email = ar[1]
                        }
                        
                    }
                    
                    if v.containsIgnoringCase(find: "cc") {
                        let ar = v.components(separatedBy: ":")
                        
                        if ar.count > 1 {
                            cc = ar[1]
                        }
                    }
                    
                    if v.containsIgnoringCase(find: "subject") {
                        let ar = v.components(separatedBy: ":")
                        
                        if ar.count > 1 {
                            subject = ar[1]
                        }
                    }
                    
                    if v.containsIgnoringCase(find: "body") {
                        let ar = v.components(separatedBy: ":")
                        if ar.count > 1 {
                            body = ar[1]
                        }
                    }
                }
            }
            
            
            if currentReachabilityStatus == .notReachable {
                self.showAlert()
                return
            }
            
            self.sendEmail(subject: subject, mailAddress: email, cc: cc, meessage: body)
            return
        }
        
        
        
        if stringValue.containsIgnoringCase(find: "tel") {
            var phoneNumber = stringValue.replacingOccurrences(of: "tel", with: "")
            phoneNumber = phoneNumber.replacingOccurrences(of: "TEL", with: "")
            phoneNumber = phoneNumber.replacingOccurrences(of: "Tel", with: "")
            phoneNumber = phoneNumber.replacingOccurrences(of: ":", with: "")
            phoneNumber = phoneNumber.trimmingCharacters(in: .whitespaces)
            self.dialNumber(number: phoneNumber)
            return
        }
        if stringValue.containsIgnoringCase(find: "SMS") {
            
            var sms = stringValue.replacingOccurrences(of: "sms", with: "")
            sms = sms.replacingOccurrences(of: "SMS", with: "")
            sms = sms.replacingOccurrences(of: "Sms", with: "")
            sms = sms.trimmingCharacters(in: .whitespaces)
            
            
            
            if let ar = sms.components(separatedBy: ":")  as? NSArray {
                
                if ar.count > 1 {
                    
                    if (MFMessageComposeViewController.canSendText()) {
                        let temp = (ar[1] as? String)!
                        var array:[String] = []
                        array.append(temp)
                        let controller = MFMessageComposeViewController()
                        controller.body = ar[2] as? String
                        controller.recipients =  [array[0]]
                        controller.messageComposeDelegate = self
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
            
            return
            
        }
        
        if showText.containsIgnoringCase(find: "url") {
            
            if currentReachabilityStatus == .notReachable {
                self.showAlert()
                return
            }
            
            guard let url = URL(string: stringValue) else {
                return //be safe
            }
            
            guard UIApplication.shared.canOpenURL(url) else {
                print("Can't open url!")
                return
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
            return
        }
        
        
        
        let pasteBoard = UIPasteboard.general
        pasteBoard.string =  stringValue
        
        self.showToast(message: "Text has been copied to clipboard", font: .systemFont(ofSize: 12.0))
        
        
        
    }
    
    @IBAction func gotoPreviousView(_ sender: Any) {
        
        
        if isFromGallery {
            Store.sharedInstance.shouldShowHomeScreen = true
        }
        
        if isFromScanned  {
            
            if !isfromUpdate {
                
                let e = UserDefaults.standard.integer(forKey: "history")
                
                if e == 2 {
                    self.saveData()
                }
            }
        }
        Store.sharedInstance.showPickerT = true
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        view.window?.layer.add(transition, forKey: "leftToRightTransition")
        dismiss(animated: false, completion: nil)
        
    }
    
    func parseDataForVCard(result:String) {
        
    }
    
    func parseDataForMECard(result:String) {
        
    }
    
    func parseDataForBarCode() {
        
    }
    
}

extension ShowResultVc: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    
    
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCellStyle", for: indexPath as IndexPath) as!TextCellStyle
        cell.lbl.text = ""
        cell.lbl.text = showText
        
        print("i am getting showtext \(showText)")
        
        cell.lbl.textColor  = UIColor.black
        return cell
    }
}
extension ShowResultVc: SwiftAlertViewDelegate {
    func alertView(_ alertView: SwiftAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if(buttonIndex == 0) {
            
            if #available(iOS 14.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            } else {
                SKStoreReviewController.requestReview()
            }
        }
        
        self.dismiss(animated: true)
        UserDefaults.standard.set(false, forKey: "given")
    }
    
    func didPresentAlertView(alertView: SwiftAlertView) {
        print("Did Present Alert View\n")
    }
    
    func didDismissAlertView(alertView: SwiftAlertView) {
        print("Did Dismiss Alert View\n")
    }
    
    func imageWithColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    
    
    func textToImage(drawText text: String, inImageSize size: CGSize, font: UIFont = UIFont.systemFont(ofSize: 20)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.black
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: rect, withAttributes: attributes)
        }
        
        return image
    }
    
    
}

struct DetectedInfo: Hashable {
    var id: Int?
    var date: String?
}

extension ShowResultVc:UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
       
        if collectionView == collectionViewForFont {
            
             
            
            return CGSize(width: 100, height: 50)
        }
        
        return CGSize(width: 60, height: 60)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewForFont {
            
            return fontArray.count
        }
        
        return backgroundColorValue.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == collectionViewForFont {
            
            let name = fontArray[indexPath.row]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FontCollectionViewCell", for: indexPath) as! FontCollectionViewCell
            
            cell.fontName.text = "QR Maker"
            cell.fontName.font = UIFont(name:name as! String, size: 16.0)
            
            
            return cell
        }
        
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ImageViewCell else {
            return UICollectionViewCell()
        }
        
        
        if indexPath.row == 0 {
            cell.imv.image = UIImage(named: "RGB_Color")
        } else if indexPath.row - 1 < backgroundColorValue.count {
            cell.imv.image = self.imageWithColor(color: backgroundColorValue[indexPath.row - 1], size: CGSize(width: 170, height: 170))
        } else {
            cell.imv.image = nil
        }
        cell.imv.layer.cornerRadius  = 10.0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if collectionView == collectionViewForFont {
            let name = fontArray[indexPath.row]
            
            fontFamily = name
            self.updateAllTextValue()
            
            
            if collectionView == collectionViewForFont {
                let name = fontArray[indexPath.row]
                fontFamily = name
                self.updateAllTextValue()
                
                // Scroll the selected item to the center of the screen
                collectionView.scrollToItem(
                    at: indexPath,
                    at: .centeredHorizontally,
                    animated: true
                )
            }
            
            
        }
        else if collectionView == collectionViewForColor {
            if indexPath.row > 0 {
                var color  = backgroundColorValue[indexPath.row - 1]
                
                if let rgb = uicolorToRGB(color: color) {
                    fontColor = "\(rgb.red),\(rgb.green),\(rgb.blue)"
                    print("color i found \(fontColor)")
                    self.updateAllTextValue()
                }
            }
            else {
                
                // Initializing Color Picker
                if #available(iOS 14.0, *) {
                    let picker = UIColorPickerViewController()
                    picker.selectedColor = self.view.backgroundColor!
                    picker.delegate = self
                    self.present(picker, animated: true, completion: nil)
                } else {
                    // Fallback on earlier versions
                }
                
                // Setting the Initial Color of the Picker
                
                
            }
        }
        
        
    }
}


extension UITextField {
    
    func addDoneButtonOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self, action: #selector(resignFirstResponder))
        keyboardToolbar.items = [flexibleSpace, doneButton]
        self.inputAccessoryView = keyboardToolbar
    }
}

extension CACornerMask {
    static var topLeft: CACornerMask {
        get {
            return CACornerMask.layerMinXMinYCorner
        }
    }
    
    static var topRight: CACornerMask {
        get {
            return CACornerMask.layerMaxXMinYCorner
        }
    }
    
    static var bottomLeft: CACornerMask {
        get {
            return CACornerMask.layerMinXMaxYCorner
        }
    }
    
    static var bottomRight: CACornerMask {
        get {
            return CACornerMask.layerMaxXMaxYCorner
        }
    }
}


extension UIColor {
    func toRGB() -> (red: Int, green: Int, blue: Int, alpha: Int)? {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            func clamp(_ value: CGFloat) -> Int {
                return max(0, min(255, Int(round(value * 255.0))))
            }
            
            return (
                red: clamp(fRed),
                green: clamp(fGreen),
                blue: clamp(fBlue),
                alpha: clamp(fAlpha)
            )
        } else {
            return nil
        }
    }
}


extension UIImage {
    static func animatedImage(withAnimatedGIFData data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var duration: Double = 0

        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
                
                let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [CFString: Any]
                let gifDict = properties?[kCGImagePropertyGIFDictionary] as? [CFString: Any]
                let delay = gifDict?[kCGImagePropertyGIFUnclampedDelayTime] as? Double ??
                            gifDict?[kCGImagePropertyGIFDelayTime] as? Double ?? 0.1
                duration += delay
            }
        }
        
        return UIImage.animatedImage(with: images, duration: duration)
    }
}
