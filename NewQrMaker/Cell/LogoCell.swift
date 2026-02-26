//
//  LogoCell.swift
//  NewQrMaker
//
//  Created by Sadiqul AMin on 25/2/26.
//

import UIKit

protocol LogoCellDelegate: AnyObject {
    func didSelectLogo(_ image: UIImage?)
}

class LogoCell: UITableViewCell {
    @IBOutlet weak var logoCollectionView: UICollectionView!
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    
    weak var delegate: LogoCellDelegate?
    
    
    var imageList = [String]()
    
    private enum Layout {
        static let cellSize = CGSize(width: 60, height: 60)
        static let rowCount: CGFloat = 2
        static let lineSpacing: CGFloat = 8
        static let interitemSpacing: CGFloat = 8
        static let sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 16)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        self.getLogo()
        setupCollectionView()
    }
    
    
    func getLogo() {
        print("🔹 Starting getLogo()")
        
        guard let path = Bundle.main.resourcePath else {
            print("❌ Could not get the main resource path")
            return
        }
        print("📂 Main resource path: \(path)")
        
        let logoPath = (path as NSString).appendingPathComponent("Logo")
        print("📂 kishor directory path: \(logoPath)")
        
        do {
            let fileList = try FileManager.default.contentsOfDirectory(atPath: logoPath)
            print("✅ Files found in kishor directory: \(fileList.count)")
            
            for fileName in fileList {
                print("🖼 Found file: \(fileName)")
                imageList.append(fileName)
            }
            
            print("🔹 Reloading collection view with \(imageList.count) images")
            logoCollectionView.reloadData()
            
        } catch {
            print("❌ Error loading images: \(error.localizedDescription)")
        }
        
        print("🔹 getLogo() finished")
    }
    
    
    
    private func setupCollectionView() {
        configureCollectionView(logoCollectionView)
        configureCollectionView(emojiCollectionView)
    }
    
    private func configureCollectionView(_ collectionView: UICollectionView) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = Layout.cellSize
        layout.minimumLineSpacing = Layout.lineSpacing
        layout.minimumInteritemSpacing = Layout.interitemSpacing
        layout.sectionInset = Layout.sectionInset
        layout.estimatedItemSize = .zero
        
        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            UINib(nibName: "LogoCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "LogoCollectionViewCell"
        )
    }
    
    
    
    
    
    
}

extension LogoCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == logoCollectionView {
            return imageList.count + 1
        }
        return 103
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogoCollectionViewCell", for: indexPath) as? LogoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if collectionView == emojiCollectionView {
            
            if indexPath.row == 0 {
                
                cell.imv.image = UIImage(named: "oh")
                return cell
            }
            
            cell.imv.image = UIImage(named: "Emoji\(indexPath.row - 1).png")
            return cell
            
        }
        
        
        if indexPath.row == 0 {
            
            cell.imv.image = UIImage(named: "oh")
            return cell
        }
        
        let imageName = imageList[indexPath.item - 1]
        if let path = Bundle.main.path(forResource: "Logo/\(imageName)", ofType: nil) {
            cell.imv.image = UIImage(contentsOfFile: path)
        }
        return cell
        
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var selectedImage: UIImage?
        
        if collectionView == emojiCollectionView {
            
            if indexPath.row == 0 {
                selectedImage = nil
            } else {
                selectedImage = UIImage(named: "Emoji\(indexPath.row - 1).png")
            }
            
        } else { // logoCollectionView
            
            if indexPath.row == 0 {
                selectedImage = nil
            } else {
                let imageName = imageList[indexPath.item - 1]
                if let path = Bundle.main.path(forResource: "Logo/\(imageName)", ofType: nil) {
                    selectedImage = UIImage(contentsOfFile: path)
                }
            }
        }
        
        print("🔥 Selected image at row \(indexPath.row)")
        
        delegate?.didSelectLogo(selectedImage)
        
        
        
    }
}
