//
//  TutotrialCell.swift
//  Cartibuy India
//
//  Created by SADIQUL AMIN IBNE AZAD on 6/2/25.
//

import UIKit
import SDWebImage
import ProgressHUD
import Reachability
import FirebaseAnalytics

protocol sendimageValue {
    func sendimage(image: UIImage, fileName: String)
    func sendUrl(name: String, fileName: String, catName: String)
}

class TutotrialCell: UICollectionViewCell {
    
    var isDownloded = false
    var selectedIndexPath: IndexPath?

    var savedDictionaries: [[String: String]] = []
    var categoryName = [String]()
    var totalCategory = [String]()
    var parsedTemplate: [String: [Dictionary<String, String>]] = [:]
    var currentItem = 0
    let reachability = try! Reachability()
    public var delegate: sendimageValue?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var holderView: UIView!
    var isPressed = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reigsterXib()
        self.setupReachability()
    }
    var element = 3
    
    func reigsterXib() {
        let nib = UINib(nibName: "ImageCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImageCell")
        
        collectionView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupReachability() {
          do {
 
              // Callbacksdid
              reachability.whenReachable = { reachability in
                  print("Internet available via \(reachability.connection.description)")
              }

              reachability.whenUnreachable = { _ in
                  DispatchQueue.main.async {
                      self.showNoConnectionAlert()
                  }
              }

              // Start monitoring
              try reachability.startNotifier()
          } catch {
              print("Unable to start Reachability: \(error)")
          }
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
                        
                        self.isPressed = false
                    }
                }
            } catch {
                
                DispatchQueue.main.async {
                    
                    self.isDownloded = false

                }
                print("Error saving image: \(error)")
            }
        }
        
        task.resume()
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
    
    
    @objc func favoriteButtonTapped(_ sender: UIButton) {
        let row = sender.tag - 2000
        
        
        let value = totalCategory[currentItem]
        guard let dic = parsedTemplate[value]?[row] else {
             return
        }
        
        loadDictionariesFromUserDefaults()
        if let index = savedDictionaries.firstIndex(of: dic) {
            savedDictionaries.remove(at: index)
            categoryName.remove(at: index)// Remove it if it exists
        } else {
            savedDictionaries.append(dic)
            categoryName.append(value)// Add it if it doesn't
        }
        saveDictionariesToUserDefaults()  // Don't forget to save changes!
        
        
        collectionView.reloadData()
       
    }
    
    func updateList() {
        for (sectionKey, sectionArray) in parsedTemplate {
            parsedTemplate[sectionKey] = sectionArray.sorted {
                if let id1 = $0["id"], let id2 = $1["id"] {
                    return Int(id1) ?? 0 > Int(id2) ?? 0
                }
                return false
            }
        }
        for (sectionKey, sectionArray) in parsedTemplate {
            for dictionary in sectionArray {
                print("hi hi mama\(dictionary):")
            }
        }
    }
}

extension TutotrialCell: UICollectionViewDelegateFlowLayout {
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

extension TutotrialCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentItem < totalCategory.count {
            let value = totalCategory[currentItem]
            return parsedTemplate[value]?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.mm.isHidden = true
        
        let value = totalCategory[currentItem]
        guard let dic = parsedTemplate[value]?[indexPath.row] else {
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
        if reachability.connection == .unavailable {
                    self.showNoConnectionAlert()
                    return
        }
        
       
     
        
        if indexPath.row > 2 {
            
        }
        
        selectedIndexPath = indexPath
        collectionView.reloadData()


        guard currentItem < totalCategory.count else {
            print("Invalid currentItem index.")
            return
        }
        
        let value1 = totalCategory[currentItem]
        
        
        isPressed = true
        
        guard let dic = parsedTemplate[value1]?[indexPath.row] else {
            print("No data found for the selected item.")
            return
        }
        
        print("dic i get wow \(dic)")
        
        guard let value = dic["original"] as? String, let imageUrl = URL(string: value) else {
            print("Invalid image URL.")
            return
        }
        
        if let idValue = dic["imageId"] as? String {
            
            Analytics.logEvent("Popular_Template", parameters: [
                "categoryName": value1,
                "imageid": idValue
            ])
            
            
            print("i am getting  actual value \(value1) \(idValue)")
            if element == 4 {
                delegate?.sendUrl(name: value, fileName: idValue, catName: value1)
                return
            }
            
            let fileName = value1 + idValue + ".jpg"
            print("URL I am getting: \(fileName)-\(imageUrl)")
            
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            if fileManager.fileExists(atPath: fileURL.path) {
                print("Image is already downloaded: \(fileName)")
                isPressed = false
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    delegate?.sendimage(image: image, fileName: fileName)
                }
            } else {
                isDownloded = true
                
                print("Image not found locally. Proceeding to download.")
                ProgressHUD.animate()
                downloadImage(from: imageUrl, to: fileURL, fileName: fileName)
            }
        } else {
            print("No ID found for the selected item.")
        }
    }
}
