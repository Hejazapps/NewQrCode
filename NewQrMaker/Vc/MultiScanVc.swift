//
//  MultiScanVc.swift
//  ScannR
//
//  Created by Sadiqul Amin Ibne Azad on 6/9/25.
//

import UIKit
import EFQRCode
class MultiScanVc: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionViewHolder: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var codeArray = [CodeItem]()
    
    var currentPageValue = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "SliderimageCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier:  "SliderimageCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        
        print("code array count i fot \(codeArray.count)")

        // Do any additional setup after loading the view.
    }
    

    func genQRCode(from input: String, size: CGFloat = 1200) -> UIImage? {
        guard let data = input.data(using: .ascii),
              let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel") // High error correction

        guard let outputImage = filter.outputImage else { return nil }

        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        return UIImage(ciImage: transformedImage)
    }

    @IBAction func gotosave(_ sender: Any) {
        for codeItem in codeArray {
            if codeItem.isfromQr {
                
                DBmanager.shared.insertRecordIntoFile(Text: codeItem.code, codeType: "1", indexPath: "2",position: "", shape: "", logo: "",temp: "",tempText: "",fontcolor: "",fontfamily:"",fontsize: "", pupil: "")
                
                
                // Skip QR items
            } else {
                DBmanager.shared.insertRecordIntoFile(
                    Text: codeItem.code,
                    codeType: "2",
                    indexPath: "2",
                    position: "",
                    shape: "",
                    logo: codeItem.codeType,
                    temp: "",
                    tempText: "",
                    fontcolor: "",
                    fontfamily: "",
                    fontsize: "0",
                    pupil: ""
                )
            }
        }
        
        // Show alert after saving
        let alert = UIAlertController(title: "Saved",
                                      message: "Scans result has been saved. Check history page.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true   )
    }
    
    @IBAction func shareImage(_ sender: Any) {
        self.shareAllCodeImages()
    }
    
    func shareAllCodeImages() {
        var imagesToShare = [UIImage]()

        for codeItem in codeArray {
            if codeItem.isfromQr {
                if let qrImage = genQRCode(from: codeItem.code) {
                    imagesToShare.append(qrImage)
                }
            } else {
                if let barImage = BarCodeGenerator.getBarCodeImage(type: codeItem.codeType, value: codeItem.code) {
                    imagesToShare.append(barImage)
                }
            }
        }

        guard !imagesToShare.isEmpty else {
            let alert = UIAlertController(title: "Nothing to Share", message: "No code images available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let activityVC = UIActivityViewController(activityItems: imagesToShare, applicationActivities: nil)
        present(activityVC, animated: true)
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension MultiScanVc: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let bounds = UIScreen.main.bounds
        
        var value = UIScreen.main.bounds.size.width
        
     
     
        return CGSize(width: value,
                      height: collectionViewHolder.frame.size.height)


         
         // Adjust height if needed
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return  0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


extension MultiScanVc: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         
        return   codeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderimageCell", for: indexPath) as! SliderimageCell
        
        cell.lbl.isHidden = false
        
        let value = UIScreen.main.bounds.size.width - 2 * 10
        cell.widthForImv.constant = value
        
        cell.heightForImv.constant =  290
        cell.lbl.text = codeArray[indexPath.row].code
        cell.lbl.numberOfLines = 0
        if !codeArray[indexPath.row].isfromQr {
            
            let image = BarCodeGenerator.getBarCodeImage(type: codeArray[indexPath.row].codeType, value: codeArray[indexPath.row].code)
            
            cell.imv.image = image
            cell.imv.contentMode = .scaleAspectFit
            
        }
        else {
          
            cell.imv.image = self.genQRCode(from: codeArray[indexPath.row].code)
            cell.imv.contentMode = .scaleAspectFit
            
            
        }
        print("i am getting fucked \(cell.frame.size.width)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        
        
        
    }
}


extension MultiScanVc: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        let pageWidth = scrollView.frame.width
        let currentPage = scrollView.contentOffset.x / pageWidth // No need to cast to Int
       
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageWidth = scrollView.frame.width
        currentPageValue = Int(scrollView.contentOffset.x / pageWidth)
        
    }
}


 
