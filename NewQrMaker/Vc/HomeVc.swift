//
//  HomeVc.swift
//  NewQrMaker
//
//  Created by Sadiqul AMin on 7/2/26.
//

import UIKit
import FirebaseDatabase


class HomeVc: UIViewController {
    
    var gifData: [[String: String]] = []
    var totalCategory = [String]()
    var parsedTemplate: [String: [Dictionary<String,String>]] = [:]
    
    var ref: DatabaseReference!
    var trendingData: [[String: String]] = []
    var savedDictionaries: [[String: String]] = []
    var customizeData: [[String: String]] = []
    
    
    @IBOutlet weak var expandLabel: UILabel!
    @IBOutlet weak var heightForView: NSLayoutConstraint!
    @IBOutlet weak var collapseIcon: UIImageView!
    var isExpand = true
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
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
        gradientimv.layer.cornerRadius = 20.0
        gradientimv.clipsToBounds = true
       
    }
    
    
    func reigsterXib() {
        let nib = UINib(nibName: "ImageCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImageCell")
        
        collectionView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    func getAllData() {
        // Clear previous data
        ref = Database.database().reference()
        self.totalCategory.removeAll()
        
        ref.child("Template").observeSingleEvent(of: .value, with: { snapshot in
            guard let templateData = snapshot.value as? [String: Any] else {
                print("Failed to cast snapshot to dictionary")
                return
            }
            
            // Save BarcodeKey to UserDefaults
            if let barcodeArray = templateData["BarcodeKey"] as? [[String: Any]],
               let firstItem = barcodeArray.first,
               let barcodeKey = firstItem["key"] as? String {
                UserDefaults.standard.set(barcodeKey, forKey: "SavedBarcodeKey")
            }
            
            // Parse template data
            for (key, value) in templateData {
                if let urlArray = value as? [[String: String]] {
                    switch key {
                    case "Gif":
                        self.gifData = urlArray
                        
                    case "Customize":
                        self.customizeData = urlArray
                        
                    case "Trending":
                        self.trendingData = urlArray
                        
                        // Print trending data
                        print("Trending data count: \(self.trendingData)")
                        for (index, item) in self.trendingData.enumerated() {
                            let name = item["name"] ?? "No name"
                            let url = item["url"] ?? "No url"
                            print("Trending item \(index + 1): Name = \(name), URL = \(url)")
                        }
                        
                    default:
                        self.parsedTemplate[key] = urlArray
                    }
                }
            }
            
            // Load local plist for total categories
            if let path = Bundle.main.path(forResource: "Tempalate", ofType: "plist"),
               let array = NSArray(contentsOfFile: path) as? [String] {
                self.totalCategory = array
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                // Reload collection views or tables as needed
            }
            
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
        }
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
        gradientimv.image = gradientImage
        self.reigsterXib()
        self.getAllData()
        
        
    }
    
    
    
    @IBAction func expandCollapse(_ sender: Any) {
        
        isExpand.toggle()
        
        if isExpand == false {
            bottomView.isHidden = true
            collapseIcon.image = UIImage(named: "down")
            heightForView.constant = 130
            expandLabel.text = "Expand More"
        }
        else {
            bottomView.isHidden = false
            collapseIcon.image = UIImage(named: "up")
            heightForView.constant = 250
            expandLabel.text = "Collapse More"
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
import FirebaseDatabaseInternal
import SDWebImage

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


 

extension HomeVc: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return self.trendingData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.mm.isHidden = true
        
        
     
        guard let dic = trendingData[indexPath.row] else {
            return cell
        }
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
        
        cell.favBtn.tag = indexPath.row + 2000
        cell.favBtn.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)

        if (!Store.sharedInstance.isActiveSubscription()) {
            cell.proIcon.isHidden = false
        } else {
            cell.proIcon.isHidden = true
        }
        
        if indexPath.row < 3 {
            cell.proIcon.isHidden = true
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
        
        let cellWidth = cell.frame.width - 20
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
