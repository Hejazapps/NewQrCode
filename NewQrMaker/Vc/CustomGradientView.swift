//
//  CustomGradientView.swift
//  ScannR
//
//  Created by Sadiqul Amin on 14/6/25.
//

import UIKit

protocol sendcolor {
    func sendColorValue(color: UIColor, color1: UIColor)
}

class CustomGradientView: UIViewController, UIColorPickerViewControllerDelegate {

    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var secondColor1: UILabel!
    @IBOutlet weak var firstColor1: UILabel!
    @IBOutlet weak var makeM: UILabel!
    var firstColor:UIColor?
    var secondColor:UIColor?
    var currentSelectedIndex = 0
    public var delegate: sendcolor?
    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var tapView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(outsideTapped(_:)))
        tapView.isUserInteractionEnabled = true
        
        tapView.addGestureRecognizer(recognizer)
        makeM.text = "make_mess".localize()
        firstColor1.text = "Choose1".localize()
        secondColor1.text = "Choose2".localize()
        addBtn.setTitle("add".localize(), for: .normal)
       
        // Do any additional setup after loading the view.
    }
    @IBAction func option1Pressed(_ sender: Any) {
        
        let picker = UIColorPickerViewController()
        picker.selectedColor =  UIColor.white
        
        picker.delegate = self
        
        self.present(picker, animated: true, completion: nil)
        
        currentSelectedIndex = 0
    }
    
    @IBAction func addGradient(_ sender: Any) {
    
        if let color1 = firstColor ,let color2 = secondColor {
            
            delegate?.sendColorValue(color: color1, color1: color2)
            
        }
        
        self.dismiss(animated: true)
        
    }
    public override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.holderView.roundCorners([.topRight, .topLeft], radius: 20)
    }

    @IBAction func option2Pressed(_ sender: Any) {
        currentSelectedIndex = 1
        
        let picker = UIColorPickerViewController()
        picker.selectedColor =  UIColor.white
        
        picker.delegate = self
        
        self.present(picker, animated: true, completion: nil)
        
        
    }
    
    func generateGradientImage(from color1: UIColor, to color2: UIColor, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                            colors: [color1.cgColor, color2.cgColor] as CFArray,
                                            locations: [0.0, 1.0]) else { return }

            let startPoint = CGPoint(x: 0, y: 0)
            let endPoint = CGPoint(x: 0, y: size.height) // Vertical gradient

            context.cgContext.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        }
        return image
    }

    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        
        if currentSelectedIndex == 0{
            
            firstColor =  viewController.selectedColor
            firstView.backgroundColor = firstColor
            
        }
        else {
            
            secondColor =  viewController.selectedColor
            secondView.backgroundColor = secondColor
        }
        
        
        if let color1 = firstColor ,let color2 = secondColor {
            
            if let gradientImage = generateGradientImage(from: color1, to: color2, size: CGSizeMake(300, 300)) {
                imv.image = gradientImage
            }
            
        }
        
    }
    @objc func outsideTapped(_ recognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
      
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
