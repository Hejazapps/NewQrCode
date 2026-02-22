//
//  AllViewCell.swift
//  ScannR
//
//  Created by Sadiqul Amin on 28/5/25.
//

import UIKit

class AllViewCell: UICollectionViewCell {

    
    @IBOutlet weak var width: NSLayoutConstraint!
    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var holderView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        holderView.layer.cornerRadius = 10.0
        holderView.clipsToBounds = true
        
        // Initialization code
    }

}
