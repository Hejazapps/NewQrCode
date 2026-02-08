//
//  AllCustom.swift
//  ScannR
//
//  Created by Sadiqul Amin on 24/6/25.
//

import UIKit
import FirebaseAnalytics

class AllCustom: UIView {
    
    
    @IBOutlet weak var create: UILabel!
    @IBOutlet weak var titlem: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var holderView: UIView!
    var element = 3
    
    var savedIDsGlobal: [Int] = []

    
    override func draw(_ rect: CGRect) {
        
        titlem.text = "messageT".localize()
        
        create.text = "Create".localize() + "->"
        collectionView.reloadData()
        self.reigsterXib()
         
        loadSavedIDs()
    }
   
    func reigsterXib() {
        let nib = UINib(nibName: "ImageCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImageCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func loadSavedIDs() {
        let savedIDStatus = UserDefaults.standard.dictionary(forKey: "savedIDs") as? [String: Bool] ?? [:]
        
        savedIDsGlobal = savedIDStatus.compactMap { (key, value) -> Int? in
            return value ? Int(key) : nil
        }.sorted(by: >)  // Sort descending

        collectionView.reloadData()
        
        holderView.alpha = savedIDsGlobal.isEmpty ? 1 : 0
    }
    
    
    func getAllSavedIDs() -> [Int] {
        let savedIDStatus = UserDefaults.standard.dictionary(forKey: "savedIDs") as? [String: Bool] ?? [:]
        let trueIDs = savedIDStatus.compactMap { (key, value) -> Int? in
            return value ? Int(key) : nil
        }
        return trueIDs.sorted(by: >)  // Descending order
    }
    
    
    
    
    @objc func proBtnTapped(_ sender: UIButton) {
        let index = sender.tag - 900
        let id = savedIDsGlobal[index]
        let idKey = String(id)

        let alert = UIAlertController(title: "deleteTemp".localize(), message: "deletem".localize(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel".localize(), style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "delete".localize(), style: .destructive, handler: { _ in
            // ✅ When user confirms delete
            var savedIDStatus = UserDefaults.standard.dictionary(forKey: "savedIDs") as? [String: Bool] ?? [:]
            savedIDStatus[idKey] = false
            UserDefaults.standard.set(savedIDStatus, forKey: "savedIDs")

            print("Template with ID \(idKey) marked as false")
            self.deleteOriginalImage(forID: idKey)
            self.deleteThumbnailImage (forID: idKey)

            // ✅ Reload your saved IDs and refresh UI
            self.loadSavedIDs()
            self.collectionView.reloadData()
        }))

        UIApplication.topMostViewController?.present(alert, animated: true, completion: nil)
    }

    
    
    @IBAction func gotoeditView(_ sender: Any) {
        
         
        
    }
    
    func deleteOriginalImage(forID id: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileName = "editedOriginal_\(id).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Deleted original image: \(fileURL.path)")
            } catch {
                print("Error deleting original image: \(error)")
            }
        }
    }

    func deleteThumbnailImage(forID id: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileName = "final_\(id).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Deleted thumbnail image: \(fileURL.path)")
            } catch {
                print("Error deleting thumbnail image: \(error)")
            }
        }
    }

    
    func loadOriginalImage(forID id: Int) -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileName = "editedOriginal_\(id).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        return UIImage(contentsOfFile: fileURL.path)
    }
    func loadThumbnailImage(forID id: Int) -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileName = "final_\(id).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        return UIImage(contentsOfFile: fileURL.path)
    }
    
}

extension AllCustom: UICollectionViewDelegateFlowLayout {
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
    
    func loadQRStyle(forID key: String) -> QRStyle? {
       
        if let savedData = UserDefaults.standard.data(forKey: key) {
            let decoder = JSONDecoder()
            if let loadedStyle = try? decoder.decode(QRStyle.self, from: savedData) {
                return loadedStyle
            }
        }
        return nil
    }
}

extension AllCustom: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return savedIDsGlobal.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.mm.alpha = 0
        var image = self.loadThumbnailImage(forID: savedIDsGlobal[indexPath.row])
        cell.imv.image = image
        
        let cellSize = collectionView.frame.width / CGFloat(element) - 20
        let padding: CGFloat = 8
        cell.widthForImv.constant = cellSize - (padding * 2)
        cell.heightForimv.constant = cellSize - (padding * 2)
        
        cell.imv.contentMode = .scaleAspectFill
         cell.imv.clipsToBounds = true
        
        cell.proIcon.isHidden = false
        cell.proBtn.isHidden = false
        cell.favBtn.isHidden = true
        cell.favImv.isHidden = true
        
        cell.proBtn.tag = indexPath.row + 900
        cell.proBtn.addTarget(self, action: #selector(proBtnTapped(_:)), for: .touchUpInside)

        cell.proIcon.image = UIImage(named: "fb")
        
        cell.layoutIfNeeded()

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
    }
}


struct QRStyle: Codable {
    let position: String
    let shape: String
    let pupil: String
    let backgroundColor: String
    let eyeColor: String
    let shapeColor: String
    let pupilColor: String
    let eyegradient: String
    let shapegradient: String
    let pupilgradient: String

    enum CodingKeys: String, CodingKey {
        case position = "Position"
        case shape = "Shape"
        case pupil = "Pupil"
        case backgroundColor = "BackgroundColor"
        case eyeColor = "eyeColor"
        case shapeColor = "shapeColor"
        case pupilColor = "pupilColor"
        case eyegradient = "eyegradient"
        case shapegradient = "shapegradient"
        case pupilgradient = "pupilgradient"
    }
}
