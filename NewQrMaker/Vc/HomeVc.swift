//
//  HomeVc.swift
//  NewQrMaker
//
//  Created by Sadiqul AMin on 7/2/26.
//

import UIKit

class HomeVc: UIViewController {
    
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
