//
//  PresetViewController.swift
//  ScannR
//
//  Created by Sadiqul Amin on 20/6/25.
//

import UIKit
import QRCode


protocol sendStyle {
    
    func  setAllValue(obj:QRStyle)
    
  
}


class PresetViewController: UIViewController {
    var element = 3
    
  
    var presetsList: [QRStyle] = []

    var delegate: sendStyle?
    @IBOutlet weak var collectionViewPreset: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.reigsterXib()
        
        
        if let presets = loadPresets() {
            
            presetsList = presets
            for preset in presets {
                print("Shape: \(preset.shape), Eye Gradient: \(preset.eyegradient)")
            }
        }
      
        
        collectionViewPreset.reloadData()
        // Do any additional setup after loading the view.
    }

    
    func reigsterXib() {
        let nib = UINib(nibName: "PresentCell", bundle: .main)
        collectionViewPreset.register(nib, forCellWithReuseIdentifier: "PresentCell")
        
        collectionViewPreset.delegate = self
        collectionViewPreset.dataSource = self
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true)
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
    
    
    func loadPresets() -> [QRStyle]? {
        guard let url = Bundle.main.url(forResource: "Preset", withExtension: "plist") else {
            print("Preset.plist not found in bundle")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            let presets = try decoder.decode([QRStyle].self, from: data)
            return presets
        } catch {
            print("Failed to decode Preset.plist: \(error)")
            return nil
        }
    }
    
    
}


extension PresetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = CGFloat(element)
        
        let bounds = UIScreen.main.bounds
        let width = (bounds.size.width - 10*(numberOfItemsPerRow+2)) / numberOfItemsPerRow
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func showNoConnectionAlert() {
        let alert = UIAlertController(title: "No Internet".localize(), message: "internet_connection".localize(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localize(), style: .default, handler: nil))
        
        if let topVC = UIApplication.topMostViewController {
            topVC.present(alert, animated: true, completion: nil)
        }
    }
    
    func updatePosition(name: String,doc: QRCode.Document) {
        
       
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
    
    func updateShape(name:String,doc: QRCode.Document) {
        
      
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
    
    func setPupilShape(for imageName: String,doc:QRCode.Document) {
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
    
    func setAllValue(obj: QRStyle) -> UIImage? {
        
        var eyeGradient  = -1
        var pupilGradient = -1
        var shapeGradient = -1
        
        let doc = QRCode.Document()
        doc.utf8String = "Preset Value"
        doc.errorCorrection = .high
        
        self.updatePosition(name: obj.position, doc: doc)
        self.updateShape(name: obj.shape, doc: doc)
        self.setPupilShape(for: obj.pupil, doc: doc)
        
        var eyeColor = colorFrom(rgbString: obj.eyeColor)
        var pupilColor = colorFrom(rgbString: obj.pupilColor)
        var shapeColor = colorFrom(rgbString: obj.shapeColor)
        
        let backgroundColor = colorFrom(rgbString: obj.backgroundColor) ?? .white
        doc.design.style.background = QRCode.FillStyle.Solid(backgroundColor.cgColor)
        
        // Parse gradient indexes
        eyeGradient = Int(obj.eyegradient) ?? -1
        pupilGradient = Int(obj.pupilgradient) ?? -1
        shapeGradient = Int(obj.shapegradient) ?? -1
        
        // Disable solid colors if gradient is present
        if eyeGradient > 0 { eyeColor = nil }
        if pupilGradient > 0 { pupilColor = nil }
        if shapeGradient > 0 { shapeColor = nil }
        
        // Apply solid colors
        if let eye = eyeColor {
            doc.design.style.eye = QRCode.FillStyle.Solid(eye.cgColor)
        }
        
        if let pupil = pupilColor {
            doc.design.style.pupil = QRCode.FillStyle.Solid(pupil.cgColor)
        }
        
        if let shape = shapeColor {
            doc.design.style.onPixels = QRCode.FillStyle.Solid(shape.cgColor)
        }
        
        // Apply gradients
        applyGradient(index: eyeGradient, target: .eye, doc: doc)
        applyGradient(index: pupilGradient, target: .pupil, doc: doc)
        applyGradient(index: shapeGradient, target: .onPixels, doc: doc)
        
        // Generate and return image
        do {
            let image = try doc.uiImage(CGSize(width: 400, height: 400), dpi: 216)
            return image
        } catch {
            print("Error generating QR code image: \(error)")
            return nil
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
    
    func cgColorFromRGB(_ rgb: (r: Int, g: Int, b: Int)) -> CGColor {
        return CGColor(
            red: CGFloat(rgb.r) / 255.0,
            green: CGFloat(rgb.g) / 255.0,
            blue: CGFloat(rgb.b) / 255.0,
            alpha: 1.0
        )
    }
    func applyGradient(index: Int, target: GradientTarget,doc:QRCode.Document) {
        
        
        
        
        var list = self.getUserGradients()
        
        var mainGradientColor = gradientColors + list
        
        
        
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
}

extension PresetViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return presetsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PresentCell", for: indexPath) as! PresentCell
        var obj = presetsList[indexPath.row]

        cell.imv.image = self.setAllValue(obj: obj)
        cell.imv.contentMode = .scaleAspectFit
     
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var obj = presetsList[indexPath.row]
        delegate?.setAllValue(obj: obj)
        self.dismiss(animated: true)
        
    }
}
