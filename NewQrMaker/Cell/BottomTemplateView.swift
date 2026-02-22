//
//  BottomTemplateView.swift
//  ScannR
//
//  Created by SADIQUL AMIN IBNE AZAD on 1/4/25.
//

import UIKit

import FirebaseDatabase
import SDWebImage


protocol sendimageValue1 {
    func sendUrl1(name:String,fileName:String,catName:String)
}
 

class BottomTemplateView: UIView, sendimageValue {
    
    public var delegate: sendimageValue1?
    
    
    func sendUrl(name: String, fileName: String,catName:String) {
        
        delegate?.sendUrl1(name: name, fileName: fileName,catName:catName)
        
    }
    
    func sendimage(image: UIImage, fileName: String) {
       
    }
    
    var parsedTemplate: [String: [Dictionary<String,String>]] = [:]
    var totalCategory = [String]()
    @IBOutlet weak var collectionviewForTemplate: UICollectionView!
    @IBOutlet weak var collectionviewForText: UICollectionView!
    var ref: DatabaseReference!
    var shouldReset = false
 
    var currentItem = 0
    
    override func draw(_ rect: CGRect) {
        self.reigsterXib()
        self.getAllData()
    }
    
    
    func reigsterXib() {
        let nib = UINib(nibName: "TextCell", bundle: .main)
        collectionviewForText.register(nib, forCellWithReuseIdentifier: "TextCell")
        
        let nib1 = UINib(nibName: "TutotrialCell", bundle: .main)
        collectionviewForTemplate.register(nib1, forCellWithReuseIdentifier: "TutotrialCell")
        
        collectionviewForText.delegate = self
        collectionviewForText.dataSource = self
        
        collectionviewForTemplate.delegate = self
        collectionviewForTemplate.dataSource = self
        
        collectionviewForTemplate.isPagingEnabled = true
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == collectionviewForTemplate {
            let pageWidth = scrollView.frame.width
            currentItem = Int(scrollView.contentOffset.x / pageWidth)
            self.shouldReset = true
            collectionviewForText.reloadData()
            collectionviewForTemplate.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.collectionviewForText.scrollToItem(at: IndexPath(item: self.currentItem, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
        
    }
    
    func prefetchTemplateImages() {
        var urlsToPreload: [URL] = []
        
        for (categoryKey, templates) in parsedTemplate {
            for template in templates {
                // Add thumbnail URLs for prefetching
                if let thumbnailString = template["thumbnail"],
                   let thumbnailURL = URL(string: thumbnailString) {
                    urlsToPreload.append(thumbnailURL)
                }
            }
        }
        
        if !urlsToPreload.isEmpty {
            print("Prefetching \(urlsToPreload.count) template images")
            SDWebImagePrefetcher.shared.prefetchURLs(urlsToPreload) { finishedCount, skippedCount in
                print("✅ Prefetched \(finishedCount) images, skipped \(skippedCount)")
            }
        }
    }
    
    func getAllData(){
        
        ref = Database.database().reference()
        self.totalCategory.removeAll()
        
        ref.child("Template").observeSingleEvent(of: .value, with: { snapshot in
            // Convert snapshot data into a [String: Any] dictionary
            guard let templateData = snapshot.value as? [String: Any] else {
                print("Failed to cast snapshot to dictionary")
                return
            }
            
            // Parse the data into [String: [String]]
         
            
            for (key, value) in templateData {
                // Ensure each value is an array of URLs (as Strings)
                if let urlArray = value as? [Dictionary<String,String>] {
                    self.parsedTemplate[key] = urlArray
                    
                } else {
                    print("Unexpected data format for key: \(key)")
                }
            }
            
            let path1 = Bundle.main.path(forResource: "Tempalate", ofType: "plist")
            self.totalCategory = NSArray(contentsOfFile: path1!) as! [String]
            
            DispatchQueue.main.async {
                self.collectionviewForText.reloadData()
                self.collectionviewForTemplate.reloadData()
                self.prefetchTemplateImages()
            }
            
            
            
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
        }
    }

}


extension BottomTemplateView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == collectionviewForTemplate {
            
            return CGSize(width: self.frame.size.width, height: collectionviewForTemplate.frame.size.height)

        }
        
        return CGSize(width: 100 , height: 40)
        
        
        // Adjust height if needed
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == collectionviewForTemplate{
            
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
        }
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == collectionviewForTemplate {
            return  0
        }
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collectionviewForTemplate {
            return  0
        }
        return 20
    }
}


extension BottomTemplateView: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
        return totalCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == collectionviewForTemplate {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TutotrialCell", for: indexPath) as! TutotrialCell
            cell.currentItem = currentItem
            cell.totalCategory = totalCategory
            cell.parsedTemplate = parsedTemplate
            cell.updateList()
            cell.element = 4
            
            cell.delegate = self
            
            if shouldReset {
                shouldReset = false
                cell.selectedIndexPath = nil
            }
            cell.collectionView.reloadData()
 
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
        cell.label.text = totalCategory[indexPath.row].localize()
        
        if currentItem == indexPath.row {
            cell.label.textColor = UIColor.blue.withAlphaComponent(0.6)
        }
        else {
            cell.label.textColor = UIColor.black
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        
        if collectionView == collectionviewForText {
            currentItem = indexPath.row
            print("it has been called irbaz")
            let currentOffset = collectionviewForTemplate.contentOffset
            self.shouldReset = true
            // Modify only the X position (keeping the Y position the same)
            let newOffset = CGPoint(x: CGFloat(currentItem) * self.frame.size.width, y: currentOffset.y) // Change 100 to whatever horizontal offset you want
            // Set the content offset with or without animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.collectionviewForText.scrollToItem(at: IndexPath(item: self.currentItem, section: 0), at: .centeredHorizontally, animated: true)
                self.collectionviewForText.reloadData()
                
                self.collectionviewForTemplate.reloadData()
            }
            
           


            collectionviewForTemplate.setContentOffset(newOffset, animated: true)
           
           
        }
        else {
            
        }
    }
}

