//
//  ImageCell.swift
//  ScannR
//
//  Created by SADIQUL AMIN IBNE AZAD on 17/3/25.
//

import UIKit
import ImageIO

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var giic: UIImageView!
    @IBOutlet weak var mm: UIImageView!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var proBtn: UIButton!
    @IBOutlet weak var favImv: UIImageView!
    @IBOutlet weak var proIcon: UIImageView!
    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var heightForimv: NSLayoutConstraint!
    @IBOutlet weak var widthForImv: NSLayoutConstraint!
    
    var fileName = ""
    var currentGifURL: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imv.contentMode = .scaleAspectFit
        proIcon.isHidden = false
        widthForImv.constant = 300
        heightForimv.constant = 300
        giic.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentGifURL = nil
        imv.image = nil
        favImv.image = nil
        proIcon.isHidden = false
    }
    
    func setGifFirstFrame(from url: URL) {
        currentGifURL = url
        giic.isHidden = false
        // Reset image immediately
        DispatchQueue.main.async {
            self.imv.image = nil
        }
        
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = docURL.appendingPathComponent(fileName)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Download GIF if needed
            if !FileManager.default.fileExists(atPath: localURL.path) {
                if let data = try? Data(contentsOf: url) {
                    try? data.write(to: localURL)
                } else { return }
            }
            
            // Load GIF source
            guard let source = CGImageSourceCreateWithURL(localURL as CFURL, nil) else { return }
            
            // Number of frames
            let frameCount = CGImageSourceGetCount(source)
            if frameCount == 0 { return }
            
            // Take middle frame
            let middleIndex = frameCount / 2
            
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, middleIndex, nil) else { return }
            let middleFrame = UIImage(cgImage: cgImage)
            
            DispatchQueue.main.async {
                if self.currentGifURL == url {
                    self.imv.image = middleFrame
                }
            }
        }
    }
    
}

