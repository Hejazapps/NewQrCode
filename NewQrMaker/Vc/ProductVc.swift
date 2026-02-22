//
//  ProductVc.swift
//  ScannR
//
//  Created by Sadiqul Amin on 28/8/25.
//

import UIKit
import SDWebImage
import SVProgressHUD
import FirebaseAnalytics

class ProductVc: UIViewController {
    
    @IBOutlet weak var productNameholder: UIView!
    @IBOutlet weak var productName: UILabel!
    var api = ""
    var barCode = ""
    @IBOutlet weak var collectionView: UICollectionView!
    var images =   [ProductImage] ()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedKey = UserDefaults.standard.string(forKey: "SavedBarcodeKey") {
            api = savedKey
            print("api key i am getting \(api)")
        }
        Analytics.logEvent("Product Page", parameters: nil)
        
        SVProgressHUD.show()
        let nibName = UINib(nibName: "SliderimageCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier:  "m  ")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        
        self.fetchProduct(ean: barCode, jwtToken: api)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func gotoPreviousView(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    func fetchProduct(ean: String, jwtToken: String) {
        let url = URL(string: "https://ean-db.com/api/v2/product/\(ean)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error:", error)
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            // Print full JSON (pretty printed)
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📦 Full JSON:\n\(jsonString)")
            }
            
            do {
                // Decode into your model
                let decoded = try JSONDecoder().decode(ProductResponse.self, from: data)
                if let product = decoded.product {
                    // Save images if available
                    if let list = decoded.product?.images {
                        self.images = list
                    }
                    
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        
                        // Show titles
                        if let titles = decoded.product?.titles {
                            for (langCode, title) in titles {
                                print("Title (\(langCode)): \(title)")
                            }
                            
                            if titles.count > 0 {
                                let scrollTitlesView = self.addScrollTitlesView(with: titles)
                                // add scrollTitlesView to your UI if needed
                            }
                        } else {
                            print("No titles available")
                        }
                        
                        self.collectionView.reloadData()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.showAlert()
                    }
                }
                
            } catch {
                print("❌ JSON decoding error:", error)
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw response:", raw)
                }
            }
        }
        
        task.resume()
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "No Product Found",
                                      message: "No product was found for this barcode.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
        
    }
    
}



// MARK: - Response Models

struct ProductResponse: Codable {
    let balance: Int?
    let product: Product?
}

struct Product: Codable {
    let barcode: String?
    let barcodeDetails: BarcodeDetails?
    let titles: [String: String]?
    let categories: [Category]?
    let manufacturer: Manufacturer?
    let relatedBrands: [String]? // adjust if API returns objects instead
    let images: [ProductImage]?
    let metadata: Metadata?
}

struct BarcodeDetails: Codable {
    let type: String?
    let description: String?
    let country: String?
}

struct Category: Codable {
    let id: String?
    let titles: [String: String]?
}

struct Manufacturer: Codable {
    let id: String?
    let titles: [String: String]?
    let wikidataId: String?
}

struct ProductImage: Codable {
    let url: String?
}

struct Metadata: Codable {
    let printBook: PrintBook?
    let media: Media?
}

struct PrintBook: Codable {
    let numPages: Int?
}

struct Media: Codable {
    let publicationYear: Int?
}

// MARK: - API Call



extension ProductVc: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let bounds = UIScreen.main.bounds
        
        var value = UIScreen.main.bounds.size.width - 2 * 10
        
        
        
        return CGSize(width: value, height: 290)
        
        // Adjust height if needed
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


extension ProductVc: UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return  1 // The number of sections is the count of the `data` array
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return   images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderimageCell", for: indexPath) as! SliderimageCell
        
        let value = UIScreen.main.bounds.size.width - 2 * 10
        cell.widthForImv.constant = value
        cell.heightForImv.constant = 290
        
        
        cell.imv.layer.cornerRadius = 10.0
        cell.imv.clipsToBounds = true
        cell.imv.contentMode = .scaleAspectFit
        
        
        let imageURL = URL(string: images[indexPath.row].url ?? "")
        
        cell.imv.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
    }
}


extension Product {
    func allTitles() -> [String] {
        guard let titles = titles else { return [] }
        return titles.map { "\($0.key): \($0.value)" }
    }
}





extension ProductVc {
    func addScrollTitlesView(with titles: [String: String]) -> TitlesScrollView {
        let scrollTitlesView = TitlesScrollView(titles: titles)
        scrollTitlesView.translatesAutoresizingMaskIntoConstraints = false
        productNameholder.addSubview(scrollTitlesView)
        
        NSLayoutConstraint.activate([
            scrollTitlesView.topAnchor.constraint(equalTo: productNameholder.safeAreaLayoutGuide.topAnchor),
            scrollTitlesView.leadingAnchor.constraint(equalTo: productNameholder.leadingAnchor),
            scrollTitlesView.trailingAnchor.constraint(equalTo: productNameholder.trailingAnchor),
            scrollTitlesView.bottomAnchor.constraint(equalTo: productNameholder.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        return scrollTitlesView
    }
}


class TitlesScrollView: UIView {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    init(titles: [String: String]) {
        super.init(frame: .zero)
        setupScrollView()
        setupStackView()
        addTitleLabels(titles: titles)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10),
            
            // VERY IMPORTANT: stackView width = scrollView width minus padding
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20)
        ])
    }
    
    private func addTitleLabels(titles: [String: String]) {
        for (lang, title) in titles.sorted(by: { $0.key < $1.key }) {
            let label = UILabel()
            label.text = "\(lang.uppercased()): \(title)"
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
        }
    }
}
