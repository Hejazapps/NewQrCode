//
//  HomeVc.swift
//  NewQrMaker
//
//  Created by Sadiqul AMin on 7/2/26.
//

import UIKit

class HomeVc: UIViewController {
    
    @IBOutlet weak var dropDownCustomView: CustomView!
    
    @IBOutlet weak var gradientimv: UIImageView!
    @IBOutlet weak var collectionViewHolder: UIView!
    let options = [
        "Create Template",
        "Batch Scan",
        "Create Gif",
        "Collapse More",
        "Create Vcard",
        "Decorate QR Code",
        "Create AI QR"
    ]
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
    }
    
    
    func createGradientImage(size: CGSize) -> UIImage? {
        let colors = [
            UIColor(red: 229/255, green: 31/255, blue: 31/255, alpha: 1).cgColor,
            UIColor(red: 119/255, green: 89/255, blue: 228/255, alpha: 1).cgColor,
            UIColor(red: 35/255, green: 181/255, blue: 254/255, alpha: 1).cgColor
        ]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        gradientLayer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }

    
    @IBOutlet weak var proBtnHolder: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientImage = createGradientImage(size: CGSize(width: 200, height: 200))
        //gradientimv.image = gradientImage
        
    }
    
    
    
    
    func applyDesignStyle(to view: UIView) {
        // Corner radius (fully rounded look)
        view.layer.cornerRadius = view.frame.height / 2
        view.layer.masksToBounds = false
        
        // Shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 2
    }
    
    
    
}


import UIKit

@IBDesignable
class CustomView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    // Update border dynamically
    func updateBorder(color: UIColor, width: CGFloat? = nil, radius: CGFloat? = nil) {
        layer.borderColor = color.cgColor
        if let w = width {
            layer.borderWidth = w
        }
        if let r = radius {
            layer.cornerRadius = r
        }
    }
}


 
