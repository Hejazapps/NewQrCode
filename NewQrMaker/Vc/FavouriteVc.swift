//
//  FavouriteVc.swift
//  ScannR
//
//  Created by Sadiqul Amin on 18/5/25.
//

import UIKit
import SDWebImage
import ProgressHUD

class FavouriteVc: UIViewController {
    var element = 3
    @IBOutlet weak var fav: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var templatel: UILabel!
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    public var delegate: sendimageValue?
    var categoryName = [String]()
    var savedDictionaries: [[String: String]] = []
    @IBOutlet weak var collectionviewForTemplate: UICollectionView!
    @IBOutlet weak var emptyView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        loadDictionariesFromUserDefaults()
        
        var value =  savedDictionaries
        self.reigsterXib()
        
        title1.text = "fav_text".localize()
        subTitle.text = "fave_subtext".localize()
        templatel.text = "Explore".localize() + "->"
        fav.text = "Favourite".localize()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func backBtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
   
    
    func reigsterXib() {
         
        let nib1 = UINib(nibName: "ImageCell", bundle: .main)
        collectionviewForTemplate.register(nib1, forCellWithReuseIdentifier: "ImageCell")
        
        
        
        collectionviewForTemplate.delegate = self
        collectionviewForTemplate.dataSource = self
        
        collectionviewForTemplate.isPagingEnabled = true
    }
    
    @IBAction func btnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    func downloadImage(from url: URL, to destinationURL: URL, fileName: String) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Failed to download image: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received during image download.")
                return
            }
            
            do {
                try data.write(to: destinationURL)
                print("Image downloaded and saved to: \(destinationURL.path)")
                
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.delegate?.sendimage(image: image, fileName: fileName)
                        ProgressHUD.dismiss()
                    }
                }
            } catch {
                print("Error saving image: \(error)")
            }
        }
        
        task.resume()
    }
    
    
    func saveDictionariesToUserDefaults() {
        let defaults = UserDefaults.standard
        if let data = try? PropertyListEncoder().encode(savedDictionaries) {
            defaults.set(data, forKey: "SavedDictionariesKey")  // Save to UserDefaults
        }
        
        UserDefaults.standard.set(categoryName, forKey: "savedCategory")
    }
    
    
    
    @objc func favoriteButtonTapped(_ sender: UIButton) {
        let row = sender.tag - 2000
        
        
        let dic = savedDictionaries[row]
        
        loadDictionariesFromUserDefaults()
        if let index = savedDictionaries.firstIndex(of: dic) {
            savedDictionaries.remove(at: index)
            categoryName.remove(at: index)// Remove it if it exists
        } else {
            savedDictionaries.append(dic)  // Add it if it doesn't
        }
        saveDictionariesToUserDefaults()  // Don't forget to save changes!
        
        
        collectionviewForTemplate.reloadData()
       
    }
    
    func loadDictionariesFromUserDefaults() {
        let defaults = UserDefaults.standard
        
        if let data = defaults.data(forKey: "SavedDictionariesKey"),
           let decoded = try? PropertyListDecoder().decode([[String: String]].self, from: data) {
            savedDictionaries = decoded
            
            if savedDictionaries.count < 1 {
                emptyView.alpha = 1
            }
            else {
                emptyView.alpha = 0
            }
            
            // Load saved data
        } else {
               
        }
        
        if let savedFruits = UserDefaults.standard.stringArray(forKey: "savedCategory") {
            categoryName = savedFruits
            
            print("cat i am getting \(categoryName)")
        } else {
            print("No fruits found in UserDefaults.")
        }
    }
    

}

extension FavouriteVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = CGFloat(element)
        
        let bounds = UIScreen.main.bounds
        let width = (bounds.size.width - 10*(numberOfItemsPerRow+2)) / numberOfItemsPerRow
        
        return CGSize(width: width, height: width)
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
    
    func showNoConnectionAlert() {
        let alert = UIAlertController(title: "No Internet".localize(), message: "internet_connection".localize(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localize(), style: .default, handler: nil))
        
        if let topVC = UIApplication.topMostViewController {
            topVC.present(alert, animated: true, completion: nil)
        }
    }
}

extension FavouriteVc: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var value = savedDictionaries.count
        
        return savedDictionaries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        let dic = savedDictionaries[indexPath.row]
        
        loadDictionariesFromUserDefaults()
        
        
        if savedDictionaries.contains(dic) {
            cell.favImv.image = UIImage(named: "Selected")
        }
        else {
            cell.favImv.image = UIImage(named: "Not Selected")
        }
        for subview in cell.contentView.subviews {
            if let indicator = subview as? UIActivityIndicatorView {
                indicator.removeFromSuperview()
            }
        }
        
        cell.favBtn.tag = indexPath.row + 2000
        
        cell.favBtn.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        
        
        
        if (!Store.sharedInstance.isActiveSubscription()) {
            cell.proIcon.isHidden = false
        } else {
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
        
        cell.imv.image = nil
        cell.imv.contentMode = .scaleAspectFit
        cell.layoutIfNeeded()
        
        let cellWidth = cell.frame.width - 20
        cell.widthForImv.constant = cellWidth
        cell.heightForimv.constant = cellWidth
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        if let thumbnailString = dic["thumbnail"], let imageUrl = URL(string: thumbnailString) {
            activityIndicator.startAnimating()
            
            if let cachedImage = SDImageCache.shared.imageFromCache(forKey: imageUrl.absoluteString) {
                cell.imv.image = cachedImage
                activityIndicator.stopAnimating()
            } else {
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
            }
        } else {
            activityIndicator.stopAnimating()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         
    }
    
    
    
}
