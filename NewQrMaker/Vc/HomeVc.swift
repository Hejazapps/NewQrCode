//
//  HomeVc.swift
//  NewQrMaker
//
//  Created by Sadiqul AMin on 7/2/26.
//

import UIKit
import FirebaseDatabase



class HomeVc: UIViewController {
    
    @IBOutlet weak var viewAll: UILabel!
    @IBOutlet weak var tlabel: UILabel!
    @IBOutlet weak var prolabel: UILabel!
    @IBOutlet weak var hlabel: UILabel!
    @IBOutlet weak var bld: UILabel!
    @IBOutlet weak var bl1: UILabel!
    @IBOutlet weak var cld: UILabel!
    @IBOutlet weak var cl1: UILabel!
    @IBOutlet weak var option6: UILabel!
    @IBOutlet weak var option5: UILabel!
    @IBOutlet weak var option4: UILabel!
    @IBOutlet weak var option3: UILabel!
    @IBOutlet weak var option2: UILabel!
    @IBOutlet weak var option1: UILabel!
    var gifData: [[String: String]] = []
    var totalCategory = [String]()
    var parsedTemplate: [String: [Dictionary<String,String>]] = [:]
    
    @IBOutlet weak var rightView: CustomView!
    @IBOutlet weak var leftView: CustomView!
    var ref: DatabaseReference!
    var trendingData: [[String: String]] = []
    var savedDictionaries: [[String: String]] = []
    var customizeData: [[String: String]] = []
    var element = 3
    var categoryName = [String]()
    @IBOutlet weak var expandLabel: UILabel!
    @IBOutlet weak var heightForView: NSLayoutConstraint!
    @IBOutlet weak var collapseIcon: UIImageView!
    var isExpand = false
    var selectedIndexPath: IndexPath?
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
    
   
    @IBAction func gotoTrending(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "AllViewData") as!  AllViewData
        vc.modalPresentationStyle = .fullScreen
      
        vc.trendingData = trendingData
        
        
        self.transitionVc(vc: vc, duration: 0.4, type: .fromRight)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientimv.layer.cornerRadius = 20.0
        
    }
    
    
    @IBAction func gotoQrPage(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreateQrVc") as!  CreateQrVc
        vc.modalPresentationStyle = .fullScreen
        transitionVc(vc: vc, duration: 0.4, type: .fromRight)
        
    }
    
    func setUplabel() {
        option1.text = "Create Template".localize()
        option2.text = "Batch Scan".localize()
        option3.text = "Create Gif".localize()
        option4.text = "Create Vcard".localize()
        option5.text = "Decorate QR Code".localize()
        option6.text = "Create AI QR".localize()
        cl1.text = "Create".localize()
        bl1.text = "Create".localize()
        
        cld.text = "Qr Code".localize()
        bld.text = "Bar Code".localize()
        
        hlabel.text = "Home".localize()
       
        
        tlabel.text = "Trending".localize()
        viewAll.text = "View All".localize()
        
        
        
        expandLabel.text = "Expand More".localize()
        
    }
    
    func reigsterXib() {
        let nib = UINib(nibName: "ImageCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImageCell")
        
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
                        
                        self.trendingData = urlArray.sorted {
                               if let id1 = $0["id"], let id2 = $1["id"] {
                                   return Int(id1) ?? 0 > Int(id2) ?? 0
                               }
                               return false
                           }
                        
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
                self.collectionView.reloadData()
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
        
      
        self.reigsterXib()
        self.getAllData()
        self.setUplabel()
        
 
        
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
    
    func saveDictionariesToUserDefaults() {
        let defaults = UserDefaults.standard
        if let data = try? PropertyListEncoder().encode(savedDictionaries) {
            defaults.set(data, forKey: "SavedDictionariesKey")  // Save to UserDefaults
        }
        
        UserDefaults.standard.set(categoryName, forKey: "savedCategory")
    }
    
    
    func showNoConnectionAlert() {
        let alert = UIAlertController(title: "No Internet".localize(), message: "internet_connection".localize(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localize(), style: .default, handler: nil))
        
        if let topVC = UIApplication.topMostViewController {
            topVC.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func expandCollapse(_ sender: Any) {
        
        isExpand.toggle()
        
        if isExpand == false {
            bottomView.isHidden = true
            collapseIcon.image = UIImage(named: "down")
            heightForView.constant = 130
            expandLabel.text = "Expand More".localize()
        }
        else {
            bottomView.isHidden = false
            collapseIcon.image = UIImage(named: "up")
            heightForView.constant = 250
            expandLabel.text = "Collapse More".localize()
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


extension HomeVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = CGFloat(element)
        
        let bounds = collectionViewHolder.bounds
        let width = (bounds.size.width - 10*(numberOfItemsPerRow)) / numberOfItemsPerRow
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
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

extension UIView {
    func applyBlurShadowWithCorner(radius: CGFloat = 8) {
        self.layer.cornerRadius = radius
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.06
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 1   // Blur 2 ≈ radius 1
        self.layer.masksToBounds = false
    }
}

extension UIButton {
    func applyBlurShadowWithCornerBtn(radius: CGFloat = 8) {
        layer.cornerRadius = radius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 1
        layer.masksToBounds = false
    }
}
extension UIViewController {
    
    func transitionVc(vc: UIViewController, duration: CFTimeInterval, type: CATransitionSubtype) {
        // Safely get the window
        guard let window = view.window ?? UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first else {
            print("Window not available. Cannot perform transition.")
            return
        }

        // Configure transition
        let transition = CATransition()
        transition.duration = duration
        transition.type = .push
        transition.subtype = type
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Add transition to window
        window.layer.add(transition, forKey: kCATransition)

        // Present view controller
        present(vc, animated: false, completion: nil)
    }
 }
