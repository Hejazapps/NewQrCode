//
//  AllViewData.swift
//  NewQrMaker
//
//  Created by Sadiqul AMin on 9/2/26.
//

import UIKit
import SDWebImage

class AllViewData: UIViewController {
    var selectedIndexPath: IndexPath?
    var trendingData: [[String: String]] = []
    var savedDictionaries: [[String: String]] = []
 
    var categoryName = [String]()
    var element = 3
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadDictionariesFromUserDefaults()
        self.reigsterXib()
        titleLabel.text = "Trending".localize()
        // Do any additional setup after loading the view.
    }
    
    func reigsterXib() {
        let nib = UINib(nibName: "ImageCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImageCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBAction func dimissView(_ sender: Any) {
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        view.window?.layer.add(transition, forKey: "leftToRightTransition")
        dismiss(animated: false, completion: nil)
    }
    
    func loadDictionariesFromUserDefaults() {
        let defaults = UserDefaults.standard
        
        if let data = defaults.data(forKey: "SavedDictionariesKey"),
           let decoded = try? PropertyListDecoder().decode([[String: String]].self, from: data) {
            savedDictionaries = decoded  // Load saved data
        } else {
               
        }
        
        if let savedFruits = UserDefaults.standard.stringArray(forKey: "savedCategory") {
            categoryName = savedFruits
        } else {
            print("No fruits found in UserDefaults.")
        }
        
       
    }

}

extension AllViewData: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemsPerRow: CGFloat = CGFloat(element)
        let padding: CGFloat = 10
        let interItemSpacing: CGFloat = 10
        
        let totalSpacing = padding * 3 + (itemsPerRow - 1) * interItemSpacing
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = availableWidth / itemsPerRow
        
        return CGSize(width: itemWidth, height: itemWidth)
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
    
  
}

extension AllViewData: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return self.trendingData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.mm.isHidden = true
        
        let dic = trendingData[indexPath.row]
        
     
       
        loadDictionariesFromUserDefaults()
        
        cell.imv.sd_cancelCurrentImageLoad()
        cell.imv.image = nil
        
        for subview in cell.contentView.subviews {
            if let indicator = subview as? UIActivityIndicatorView {
                indicator.removeFromSuperview()
            }
        }
        
        if savedDictionaries.contains(dic) {
            cell.favImv.image = UIImage(named: "Selected")
        } else {
            cell.favImv.image = UIImage(named: "Not Selected")
        }
        
        
        cell.favBtn.isHidden = true
        cell.favImv.isHidden = true
        
        cell.proIcon.isHidden = true
        cell.proBtn.isHidden = true
        

        if (!Store.sharedInstance.isActiveSubscription()) {
            cell.proIcon.isHidden = false
            cell.proBtn.isHidden = false
        } else {
            cell.proIcon.isHidden = true
            cell.proBtn.isHidden = true
        }
        
        if indexPath.row < 3 {
            cell.proIcon.isHidden = true
            cell.proBtn.isHidden = true
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        cell.contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        cell.imv.contentMode = .scaleAspectFit
        cell.layoutIfNeeded()
        
        let cellWidth = cell.frame.width - 25
        cell.widthForImv.constant = cellWidth
        cell.heightForimv.constant = cellWidth
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        if indexPath == selectedIndexPath {
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            cell.layer.borderWidth = 0
        }
        
        if let thumbnailString = dic["thumbnail"], let imageUrl = URL(string: thumbnailString) {
            activityIndicator.startAnimating()
            
            let options: SDWebImageOptions = [.progressiveLoad, .retryFailed, .highPriority, .scaleDownLargeImages]
            
            cell.imv.sd_setImage(
                with: imageUrl,
                placeholderImage: nil,
                options: options,
                progress: nil,
                completed: { (image, error, cacheType, imageURL) in
                    activityIndicator.stopAnimating()
                    
                    if let image = image {
                        cell.imv.contentMode = .scaleAspectFit
                        cell.setNeedsLayout()
                        cell.layoutIfNeeded()
                        
                        print("image size i get \(image.size.width) \(image.size.height)")
                        
                        switch cacheType {
                        case .memory:
                            print("🟢 Image loaded from memory cache: \(imageURL?.lastPathComponent ?? "")")
                        case .disk:
                            print("🔵 Image loaded from disk cache: \(imageURL?.lastPathComponent ?? "")")
                        case .none:
                            print("🟠 Image loaded from network: \(imageURL?.lastPathComponent ?? "")")
                        default:
                            break
                        }
                    } else if let error = error {
                        print("❌ Error loading image: \(error.localizedDescription)")
                    }
                }
            )
        } else {
            activityIndicator.stopAnimating()
        }
       
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
}
