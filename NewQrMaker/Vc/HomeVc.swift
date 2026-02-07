//
//  HomeVc.swift
//  NewQrMaker
//
//  Created by Sadiqul AMin on 7/2/26.
//

import UIKit

class HomeVc: UIViewController {
    
    
    let options = [
        "Batch Scan",
        "Create Template",
        "Create Gif",
        "Collapse More",
        "Create Vcard",
        "Decorate QR Code",
        "Create AI QR"
    ]
    
    
    @IBOutlet weak var proBtnHolder: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.applyDesignStyle(to: self.proBtnHolder)
        }
        
        
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
