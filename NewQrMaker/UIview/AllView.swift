//
//  AllView.swift
//  ScannR
//
//  Created by Sadiqul Amin on 28/5/25.
//

import UIKit

protocol dismissTheView {
    func dismissAll()
    func sendEmoji(image:UIImage)
    func sendLgo(image:UIImage?)
    func sendPositionMaker(name:String)
    func sendBodyShape(name:String)
    func snedColoeData(color:UIColor,index:Int)
    func snedColoeData(color:UIColor,pixedlIndex:Int)
    func snedColoeDataf(color:Int,gradientpixelIndex:Int)
    func setPupil(name:String)
    func addGradient()
}


class AllView: UIView, UIColorPickerViewControllerDelegate {
    var tempArray: [String] = []
    @IBOutlet weak var label: UILabel!
    var isFromEmoji = false
    var isFromLogo = false
    var isFromPosition = false
    var isfromShape = false
    var isFromBBackrgound = false
    var isfromGradient = false
    var isFromPupil  = false
    var currentIndex = 0
    var isFromPixel = false
    var currentPixel = 0
    var currentpixelGradient = 0
    var isFromGif = false
    
    @IBOutlet weak var segment1: UISegmentedControl!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var gradientBtn: UIButton!
    
    @IBOutlet weak var pro: UIImageView!
    var backgroundColorValue:[UIColor] = []
    public var delegate: dismissTheView?
    
    var maingradientColors = [[(r: Int, g: Int, b: Int)]]()
    
    @IBOutlet weak var glabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    override func draw(_ rect: CGRect) {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "AllViewCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "AllViewCell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        self.setColor()
        glabel.text = "gradient".localize()
         
        
        if(Store.sharedInstance.isActiveSubscription()) {
            pro.isHidden = true
        }
        else {
            pro.isHidden =  false
        }
    }
    
     
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        
        if isFromBBackrgound {
            delegate?.snedColoeData(color: viewController.selectedColor, index: currentIndex)
        }
        else {
            delegate?.snedColoeData(color: viewController.selectedColor, pixedlIndex: currentPixel)
        }
        
        
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
    @IBAction func coloeChnages(_ sender: UISegmentedControl) {
        
        if isFromGif {
            currentIndex = 1
            return
        }
        currentIndex = sender.selectedSegmentIndex
        
    }
    public func setUp(isFromEmoji:Bool,isfromLogo:Bool,isFromPosition:Bool,isShape:Bool,isFromBBackrgound:Bool,isFromPupil:Bool,isFromPiexl:Bool,isfromGradient:Bool) {
        self.isFromEmoji = isFromEmoji
        self.isFromLogo = isfromLogo
        self.isFromPosition = isFromPosition
        self.isfromShape = isShape
        self.isFromBBackrgound = isFromBBackrgound
        self.isFromPupil = isFromPupil
        self.isFromPixel = isFromPiexl
        self.isfromGradient = isfromGradient
        
        segment.alpha = 0
        segment1.alpha = 0
        gradientBtn.alpha = 0
        glabel.alpha = 0
        segment.selectedSegmentIndex = 0
        segment1.selectedSegmentIndex = 0
        if isFromBBackrgound {
            label.text = "Color".localize()
            segment.alpha = 1
            
        }
        
        if isfromGradient {
            gradientBtn.alpha = 1
            label.text = "Gradient".localize()
            segment1.alpha = 1
            glabel.alpha = 1
            
        }
        
        if isFromPixel {
            label.text = "Pixel Color".localize()
            segment1.alpha = 1
            
        }
        if isfromShape {
            label.text = "Body Shape".localize()
        }
        
        if isFromPosition {
            label.text = "Position maker".localize()
        }
        
        if isFromEmoji {
            label.text = "Emoji".localize()
        }
        if isFromLogo {
            label.text = "Logo".localize()
        }
        
        if isFromPupil {
            label.text = "Pupil".localize()
        }
        self.collectionView.reloadData()
        if isFromGif {
            
            currentIndex = 1
            
            segment.setEnabled(false, forSegmentAt: 0)
            segment.selectedSegmentIndex = 1
            

        }
    }
    
    @IBAction func crossTheView(_ sender: Any) {
        print("it has been pressec cross")
        
        delegate?.dismissAll()
        
    }
    
    @IBAction func addGradient(_ sender: Any) {
        
        delegate?.addGradient()
    }
    func countFiles(flag: String) -> Int {
        let folderName: String
        
        switch flag {
        case "Logo":
            folderName = "Logo"
        case "Position maker":
            folderName = "Position maker"
        case "Body Shape":
            folderName = "Body Shape"
        case "Pupil":
            return allShapes.count
        default:
            return 0
        }
        
        if let path = Bundle.main.path(forResource: folderName, ofType: nil) {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: path)
                return contents.sorted().count
            } catch {
                print("Error reading contents of directory at path: \(path), error: \(error)")
                return 0
            }
        }
        
        return 0
    }
    @IBAction func pixelIndexChanges(_ sender: UISegmentedControl) {
        if isfromGradient {
            currentpixelGradient = sender.selectedSegmentIndex
        }
        else {
            currentPixel = sender.selectedSegmentIndex
        }
    }
    
    func handleSelection(indexPath: IndexPath) {
        func process(folderName: String, handler: (String, String, [String]) -> Void) {
            var tempArray: [String] = []
            if let path = Bundle.main.path(forResource: folderName, ofType: nil) {
                do {
                    try tempArray = FileManager.default.contentsOfDirectory(atPath: path)
                    tempArray = tempArray.sorted()
                } catch {
                    return
                }

                if indexPath.row < tempArray.count {
                    let filename = tempArray[indexPath.row]
                    handler(path, filename, tempArray)
                }
            }
        }

        if isFromLogo {
            process(folderName: "Logo") { path, filename, tempArray in
                if indexPath.row == 0 {
                    delegate?.sendLgo(image: nil)
                } else {
                    let imagePath = "\(path)/\(filename)"
                    delegate?.sendLgo(image: UIImage(contentsOfFile: imagePath) ?? UIImage())
                }
            }
        }

        if isFromPosition {
            process(folderName: "Position maker") { path, filename, _ in
                let imagePath = "\(path)/\(filename)"
                delegate?.sendPositionMaker(name: imagePath)
            }
        }

        if isfromShape {
            process(folderName: "Body Shape") { _, filename, _ in
                delegate?.sendBodyShape(name: filename)
            }
        }
        
        if isFromPupil {
            process(folderName: "Pupil") { _, filename, _ in
                delegate?.setPupil(name: filename)
            }
        }
    }

    
   
    func generateGradientImage(from colorPair: [(r: Int, g: Int, b: Int)], size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        guard colorPair.count == 2 else { return nil }

        let color1 = UIColor(red: CGFloat(colorPair[0].r)/255.0,
                             green: CGFloat(colorPair[0].g)/255.0,
                             blue: CGFloat(colorPair[0].b)/255.0,
                             alpha: 1.0)

        let color2 = UIColor(red: CGFloat(colorPair[1].r)/255.0,
                             green: CGFloat(colorPair[1].g)/255.0,
                             blue: CGFloat(colorPair[1].b)/255.0,
                             alpha: 1.0)

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: [color1.cgColor, color2.cgColor] as CFArray,
                                      locations: [0.0, 1.0])!

            let startPoint = CGPoint(x: 0, y: 0)
            let endPoint = CGPoint(x: 0, y: size.height)

            context.cgContext.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        }

        return image
    }

    
    func imageWithColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func configureImage(cell: AllViewCell, indexPath: IndexPath, resourceName: String) {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: nil) else { return }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: path).sorted()
            if indexPath.row < files.count {
                let imagePath = "\(path)/\(files[indexPath.row])"
                cell.imv.image = UIImage(named: imagePath)
            } else {
                
            }
        } catch {
            print("Error reading directory at path: \(path), error: \(error)")
        }
    }
    
}

extension AllView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 50, height: 50)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isfromGradient {
            
            return maingradientColors.count
        }
        
        if isFromEmoji {
            
            return 102
        }
        
        if isFromLogo {
            
            return   countFiles(flag: "Logo")
            
        }
        
        if isFromPosition {
            
            return   countFiles(flag: "Position maker")
            
        }
        if isfromShape {
            
            return   countFiles(flag: "Body Shape")
            
        }
        
        if isFromPupil {
            
            return   countFiles(flag: "Pupil")
            
        }
        
        return backgroundColorValue.count + 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllViewCell", for: indexPath) as? AllViewCell else {
            return UICollectionViewCell()
        }
        
        cell.width.constant = 45
        if isfromGradient {
            
            cell.imv.image = generateGradientImage(from: maingradientColors[indexPath.row])
            return cell
        }
        
        
        
       
        
        if isFromBBackrgound || isFromPixel {
            if indexPath.row == 0 {
                cell.imv.image = UIImage(named: "RGB_Color")
            } else if indexPath.row - 1 < backgroundColorValue.count {
                cell.imv.image = self.imageWithColor(color: backgroundColorValue[indexPath.row - 1], size: CGSize(width: 170, height: 170))
            } else {
                cell.imv.image = nil
            }
            return cell
            
        }
        
        
        if isFromEmoji {
            cell.imv.image =  UIImage(named: "Emoji\(indexPath.row)")
        }
        
        if isFromLogo {
            configureImage(cell: cell, indexPath: indexPath, resourceName: "Logo")
        }
        
        if isFromPosition {
            configureImage(cell: cell, indexPath: indexPath, resourceName: "Position maker")
        }
        
        if isfromShape {
            configureImage(cell: cell, indexPath: indexPath, resourceName: "Body Shape")
        }
        
        if isFromPupil {
            cell.imv.image = UIImage(named: allShapes[indexPath.row] + ".png")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isFromPupil {
            delegate?.setPupil(name: allShapes[indexPath.row])
            return
        }
        
        if isfromGradient {
            delegate?.snedColoeDataf(color: currentpixelGradient, gradientpixelIndex: indexPath.row)
        }
        if isFromBBackrgound {
            
            if indexPath.row == 0 {
                let picker = UIColorPickerViewController()
                picker.selectedColor = self.backgroundColor!
                picker.delegate = self
                
                if let topVC = UIApplication.topMostViewController {
                    topVC.present(picker, animated: true, completion: nil)
                }
            }
            else {
                delegate?.snedColoeData(color: backgroundColorValue[indexPath.row - 1], index: currentIndex)
            }
            
            return
        }
        
        if isFromPixel {
            
            if indexPath.row == 0 {
                let picker = UIColorPickerViewController()
                picker.selectedColor = self.backgroundColor!
                picker.delegate = self
                
                if let topVC = UIApplication.topMostViewController {
                    topVC.present(picker, animated: true, completion: nil)
                }
            }
            else {
                delegate?.snedColoeData(color: backgroundColorValue[indexPath.row - 1], pixedlIndex: currentPixel)
            }
            
            return
        }

        
        if isFromEmoji {
            
            if let img = UIImage(named: "Emoji\(indexPath.row)") {
                delegate?.sendEmoji(image:img)
            }
            return
        }
        handleSelection(indexPath: indexPath)
        
        
    }
}



