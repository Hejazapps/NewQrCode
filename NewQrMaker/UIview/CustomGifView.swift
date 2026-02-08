import UIKit
import SwiftyGif
import SVProgressHUD
import FirebaseAnalytics

class CustomGifView: UIView {
    var shouldAnimateGifs: Bool = true
    var currentSelectedGif = 0
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Global SwiftyGif manager (limits memory use to 50 MB)
    let gifManager = SwiftyGifManager(memoryLimit: 50)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reigsterXib()
        Analytics.logEvent("gif view", parameters: nil)
    }
    
    func reigsterXib() {
        let nib = UINib(nibName: "ImageCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImageCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func showNoConnectionAlert() {
        let alert = UIAlertController(title: "No Internet".localize(), message: "internet_connection".localize(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localize(), style: .default, handler: nil))
        
        if let topVC = UIApplication.topMostViewController {
            topVC.present(alert, animated: true, completion: nil)
        }
    }
    
    func loadGIFData(for index: Int) -> Data? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documents.appendingPathComponent("custom\(index).gif")
        
        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            print("Failed to load GIF data at index \(index): \(error)")
            return nil
        }
    }

}

extension CustomGifView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 2
        let spacing: CGFloat = 10
        let totalSpacing = spacing * (numberOfItemsPerRow + 1)
        let width = (collectionView.bounds.width - totalSpacing) / numberOfItemsPerRow
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
}

extension CustomGifView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if currentSelectedGif == 1 {
            let defaults = UserDefaults.standard
            var fileIndex = defaults.integer(forKey: "customGIFIndex")
            
            return fileIndex
        }
        return gifData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        let cellWidth = cell.frame.width - 20
        cell.widthForImv.constant = cellWidth
        cell.heightForimv.constant = cellWidth
        cell.favBtn.alpha = 0
        cell.favImv.alpha = 0
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.mm.alpha = 1
        
        
        if currentSelectedGif == 1 {
            
            var fileName = "custom\(indexPath.row).gif"
            
            let docURL = FileManager.default.urls(for:  .documentDirectory, in: .userDomainMask).first!
            let localURL = docURL.appendingPathComponent(fileName)
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
              
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
                    cell.mm.image = UIImage(named: "baba")
                    cell.mm.image = UIImage(named: "200")
                    if let result = middleFrame.dominantColorPortion() {
                        if result.containsIgnoringCase(find: "white") {
                            cell.mm.image = UIImage(named: "200")
                        }
                    }
                    
                    cell.imv.image = middleFrame
                    
                    if (!Store.sharedInstance.isActiveSubscription()) {
                        cell.proIcon.isHidden = false
                    } else {
                        cell.proIcon.isHidden = true
                    }
                    
                    if indexPath.row < 1 {
                        cell.proIcon.isHidden = true
                    }
                    
                    
                }
               
              
            }
            return cell
            
        }
        var dic = gifData[indexPath.row]
        var lol = ""
        if let idValue = dic["imageId"] as? String {
            lol = "GIF" + idValue + ".gif"
            cell.fileName = lol
        }
        cell.mm.image = UIImage(named: "200")
        
        
       
        if let thumbnailString = dic["thumbnail"], let imageUrl = URL(string: thumbnailString) {
           
            cell.currentGifURL = imageUrl
            cell.setGifFirstFrame(from: imageUrl)

            
        }
        
        
        if let value = dic["color"] as? String {
            cell.mm.image = UIImage(named: "baba")
        }
        
        
        if (!Store.sharedInstance.isActiveSubscription()) {
            cell.proIcon.isHidden = false
        } else {
            cell.proIcon.isHidden = true
        }
        
        if indexPath.row < 1 {
            cell.proIcon.isHidden = true
        }
        
       
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
}

