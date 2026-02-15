//
//  CreateQrVc.swift
//  ScannR
//
//  Created by SADIQUL AMIN IBNE AZAD on 9/3/25.
//

import UIKit
import CoreLocation
import Contacts
import EventKit
import EventKitUI
import MapKit



class CreateQrVc: UIViewController, sendIndex,CLLocationManagerDelegate, EKEventEditViewDelegate, ContactSelectionDelegate, UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, MKLocalSearchCompleterDelegate{
    
    
    
    
    func didSelectContact(_ contact: CNContact) {
        
        let contactCard = CNMutableContact()
        
        contactCard.givenName = contact.givenName
        contactCard.familyName = contact.familyName
        contactCard.phoneNumbers = contact.phoneNumbers
        contactCard.emailAddresses = contact.emailAddresses
        contactCard.organizationName = contact.organizationName
        contactCard.jobTitle = contact.jobTitle
        contactCard.postalAddresses = contact.postalAddresses
        contactCard.urlAddresses = contact.urlAddresses
        
        if let vCardString = createVCardString(from: contactCard) {
            
            
            
            // print("string  ", vcString)
            self.goResultVc(string: vCardString)
            
            
            
        } else {
            let alert = UIAlertController(title: "Alert".localize(), message: "Failedcard".localize(), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func createVCardString(from contact: CNMutableContact) -> String? {
        
        var vcard = NSData()
        // let usersContact = CNMutableContact()
        do {
            try vcard = CNContactVCardSerialization.data(with: [contact] )  as NSData
            return  String(data: vcard as Data, encoding: .utf8)
            
            
            
        } catch {
            print("Error \(error)")
        }
        
        return nil
    }
    
    
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        self.btnTag(index: 0)
        self.tableView.reloadData()
        
        if action.rawValue == 0 {
            
            isFromEvnt = false
            print("mamal")
        }
        
        
        self.dismissKeyboard()
        currentSelectedName = "Text"
        inputParemeterArray = Constant.getInputParemeterByType(type: "Text")
        for v in self.inputParemeterArray {
            if v.text.count > 0 {
                self.createDataModelArray.append(ResultDataModel(title: v.title, description: v.text))
                
            }
            else {
                self.createDataModelArray.append(ResultDataModel(title: v.title, description: ""))
            }
            
        }
        //tableView.reloadData()
        collectionViewForIcon.reloadData()
        collectionViewForIcon.reloadData()
        
        
        self.dismissKeyboard()
        if action.rawValue == 0 {
            controller.dismiss(animated: true, completion: nil)
            return
        }
        
        var event = Event()
        
        if let eventV = controller.event?.title {
            event.summary = eventV
            
            self.createDataModelArray.append(ResultDataModel(title: "Title", description: event.summary!))
        }
        
        if let startDate = controller.event?.startDate {
            // Store.sharedInstance.setstartDate(date: startDate)
            event.dtstart = startDate
            let a = startDate.toString()
            self.createDataModelArray.append(ResultDataModel(title: "Start", description:(event.dtstart?.asString(style: .full))!))
        }
        
        if let endDate = controller.event?.endDate {
            // Store.sharedInstance.setstartDate(date: endDate)
            event.dtend = endDate
            let a = endDate.toString()
            self.createDataModelArray.append(ResultDataModel(title: "End", description:(event.dtend?.asString(style: .full))!))
        }
        
        if let location = controller.event?.location {
            event.location = location
            self.createDataModelArray.append(ResultDataModel(title: "Location", description: event.location!))
        }
        
        if let note = controller.event?.notes {
            event.descr = note
            self.createDataModelArray.append(ResultDataModel(title: "Notes", description: event.descr!))
        }
        
        let calendar = Calendar1(withComponents: [event])
        let iCalString = calendar.toCal()
        var value = iCal.parse([iCalString])
        let cals = try! iCal.load(string: iCalString)
        // or loadFile() or loadString(), all of which return [Calendar] as an ics file can contain multiple calendars
        
        for cal in cals {
            for event in cal.otherAttrs {
                print(event)
            }
        }
        print("Data ", iCalString)
        
        controller.dismiss(animated: true, completion: {
            
            
            self.goResultVc(string: iCalString,event: controller.event!)
        })
    }
    
    var gifData:Data?
    
    
    @IBOutlet weak var create: UIButton!
    @IBOutlet weak var progressBar: PercentageView!
    var fileName:String?
    var templateImage:UIImage?
    @IBOutlet weak var tableView: UITableView!
    var currentLocationString  = ""
    let eventStore = EKEventStore()
    var selectedIndex = 0
    var fromQrCode =  true
    var temp = ""
    @IBOutlet weak var collectionViewForIcon: UICollectionView!
    var shouldShowContact  = false
    @IBOutlet weak var mapView: MKMapView!
    var shouldShowWhite = false
    
    
    
    @IBOutlet weak var btnValue: UIButton!
    var isfromQr = true
    var currentIndex = IndexPath(row: 0, section: 0)
    var inputParemeterArray = [CreateDataModel]()
    var createDataModelArray = [ResultDataModel]()
    let locationManager = CLLocationManager()
    var currentTextView:UITextView! = UITextView(frame: CGRect(x: 20.0, y: 90.0, width: 250.0, height: 100.0))
    @IBOutlet weak var topLabel: UILabel!
    var currentBrCode  = 0
    var isFromEvnt = false
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var bottomSpaceView: NSLayoutConstraint!
    var currentSelectedName = ""
    var selectedPreset:QRStyle?
    
    var selectedMapCoordinate: CLLocationCoordinate2D?
    var mapPinAnnotation: MKPointAnnotation?
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults: [MKLocalSearchCompletion] = []
    var locationSearchBar: UISearchBar?
    var searchResultsTable: UITableView?
    var instructionLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.layer.cornerRadius = progressBar.frame.size.height / 2.0
        progressBar.clipsToBounds = true
        
        btnValue.setTitle("", for: .normal)
        let path2 = Bundle.main.path(forResource: "BarCategory", ofType: "plist")
        barCategoryArray = NSArray(contentsOfFile: path2!)
        
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        if isfromQr {
            progressBar.setPercentage(20)
        }
        else {
            progressBar.setPercentage(50)
        }
        
        tableView.register(UINib(nibName: "InputTextTableViewCell", bundle: nil), forCellReuseIdentifier: "InputTextTableViewCell")
        
        tableView.separatorColor = UIColor.clear
        
        
        collectionViewForIcon.isPagingEnabled = true
        collectionViewForIcon.showsVerticalScrollIndicator = false
        collectionViewForIcon.showsHorizontalScrollIndicator = false
        let emptyAutomationsCell = IconViewColl.nib
        collectionViewForIcon?.register(emptyAutomationsCell, forCellWithReuseIdentifier: IconViewColl.reusableID)
        
        collectionViewForIcon.delegate = self
        collectionViewForIcon.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        let path1 = Bundle.main.path(forResource: "QrCategory", ofType: "plist")
        qrCategoryArray = NSArray(contentsOfFile: path1!)
        
        
        let dic = qrCategoryArray[0] as? Dictionary<String, Any>
        
        if let  itemName  = dic!["Category"] as? String {
            //            topLabel.text = itemName
            //            topLabel.textColor = tabBarBackGroundColor
            
        }
        
        inputParemeterArray = Constant.getInputParemeterByType(type: "Text")
        for _ in self.inputParemeterArray {
            self.createDataModelArray.append(ResultDataModel(title: "", description: ""))
        }
        currentSelectedName = "Text"
        tableView.reloadData()
        tableView.isHidden = false
        mapView.isHidden = true
        
        if !isfromQr {
            label.text =  "Create Bar Code".localize()
            self.forBarCode()
        }
        else {
            label.text = "Create QR Code".localize()
        }
        create.setTitle("  Create".localize(), for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.gotoView()
        }
        
        setupMapInteraction()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setupMapInteraction() {
        mapView.delegate = self
        
        if let gestures = mapView.gestureRecognizers {
            for gesture in gestures {
                if gesture is UITapGestureRecognizer {
                    mapView.removeGestureRecognizer(gesture)
                }
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tapGesture)
        
        print("Map tap gesture added")
        setupLocationSearch()
    }
    
    private func setupLocationSearch() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
        
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for a location"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        self.locationSearchBar = searchBar
        
        
        let resultsTable = UITableView()
        resultsTable.delegate = self
        resultsTable.dataSource = self
        resultsTable.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
        resultsTable.isHidden = true
        resultsTable.backgroundColor = .white
        resultsTable.layer.cornerRadius = 8
        resultsTable.layer.shadowColor = UIColor.black.cgColor
        resultsTable.layer.shadowOpacity = 0.2
        resultsTable.layer.shadowOffset = CGSize(width: 0, height: 2)
        resultsTable.layer.shadowRadius = 4
        self.searchResultsTable = resultsTable
    }
    
    
    private func showSearchBar() {
        guard let searchBar = locationSearchBar,
              let searchResultsTable = searchResultsTable else {
            print("Search bar or results table is nil!")
            return
        }
        
        print("Showing search bar")
        
        searchBar.removeFromSuperview()
        searchResultsTable.removeFromSuperview()
        instructionLabel?.removeFromSuperview()
        
        if instructionLabel == nil {
            let label = UILabel()
            label.text = "Tap map to place pin 📍"
            label.textAlignment = .center
            label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.layer.cornerRadius = 8
            label.clipsToBounds = true
            instructionLabel = label
        }
        
        if let label = instructionLabel {
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16),
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.heightAnchor.constraint(equalToConstant: 36),
                label.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
            ])
            
            view.bringSubviewToFront(label)
        }
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        searchResultsTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchResultsTable)
        
        NSLayoutConstraint.activate([
            searchResultsTable.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            searchResultsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchResultsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchResultsTable.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        view.bringSubviewToFront(searchBar)
        view.bringSubviewToFront(searchResultsTable)
        
        view.layoutIfNeeded()
        
        print("Search bar frame: \(searchBar.frame)")
        print("Map view frame: \(mapView.frame)")
    }
    
    private func hideSearchBar() {
        locationSearchBar?.removeFromSuperview()
        searchResultsTable?.removeFromSuperview()
        instructionLabel?.removeFromSuperview()
        searchResultsTable?.isHidden = true
    }
    
    @objc private func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard !mapView.isHidden else { return }
        
        let tapPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        
        print("👀👀 Rafsan Map tapped: ---- lat=\(coordinate.latitude), long=\(coordinate.longitude)")
        
        addPinToMap(at: coordinate)
        selectedMapCoordinate = coordinate
    }
    
    private func addPinToMap(at coordinate: CLLocationCoordinate2D) {
        print("👀👀 Rafsan add pin at: \(coordinate.latitude), \(coordinate.longitude)")
        
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "📍 Selected Location"
        annotation.subtitle = String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude)
        
        mapView.addAnnotation(annotation)
        mapPinAnnotation = annotation
        
        selectedMapCoordinate = coordinate
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            if let annotationView = self?.mapView.view(for: annotation) {
                print("Ann view exists: \(annotationView)")
            } else {
                print("no ann---")
            }
        }
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("error: \(error.localizedDescription)")
            }
            
            if let placemark = placemarks?.first {
                var addressParts: [String] = []
                
                if let name = placemark.name {
                    addressParts.append(name)
                }
                if let locality = placemark.locality {
                    addressParts.append(locality)
                }
                if let country = placemark.country {
                    addressParts.append(country)
                }
                
                let address = addressParts.joined(separator: ", ")
                annotation.subtitle = address.isEmpty ? annotation.subtitle : address
                print("📍 Address: \(annotation.subtitle ?? "none")")
            }
        }
        
        updateLocationInDataModel(coordinate: coordinate)
    }
    
    private func updateLocationInDataModel(coordinate: CLLocationCoordinate2D) {
        let locationString = "\(coordinate.latitude),\(coordinate.longitude)"
        
        for (index, model) in createDataModelArray.enumerated() {
            if model.title.lowercased().contains("location") ||
               model.title.lowercased().contains("latitude") ||
               model.title.lowercased().contains("coordinate") {
                createDataModelArray[index].description = locationString
                tableView.reloadData()
                break
            }
        }
        
        currentLocationString = "GEO:\(coordinate.latitude),\(coordinate.longitude)"
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            print("User location annotation, using default")
            return nil
        }
        
        let identifier = "CustomPin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.animatesDrop = true
        } else {
            
            
            pinView?.annotation = annotation
        }
        

        pinView?.isEnabled = true
        pinView?.isHidden = false
        pinView?.alpha = 1.0
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            print("   - View: \(type(of: view)), annotation: \(view.annotation?.title ?? "no title")")
        }
    }
    
    private func showLocationInputAlert() {
        let alert = UIAlertController(
            title: "Enter Location",
            message: "Choose how to enter your location:",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Use Current Location", style: .default) { [weak self] _ in
            self?.useCurrentLocation()
        })
        
        alert.addAction(UIAlertAction(title: "Enter Address", style: .default) { [weak self] _ in
            self?.showAddressInputAlert()
        })

        
        alert.addAction(UIAlertAction(title: "Enter Coordinates", style: .default) { [weak self] _ in
            self?.showCoordinatesInputAlert()
        })
        
        alert.addAction(UIAlertAction(title: "Pick on Map", style: .default) { [weak self] _ in
            self?.showMapForPinPlacement()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.collectionViewForIcon.reloadData()
        })
        
        present(alert, animated: true)
    }
    
    private func showAddressInputAlert() {
        let alert = UIAlertController(
            title: "Enter Address",
            message: "Enter an address, place name, or zip code:",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "e.g., Times Square, New York"
            textField.autocapitalizationType = .words
            textField.keyboardType = .default
        }
        
        alert.addAction(UIAlertAction(title: "Search", style: .default) { [weak self] _ in
            guard let input = alert.textFields?.first?.text, !input.isEmpty else {
                self?.showError(message: "Please enter an address")
                return
            }
            self?.geocodeLocation(input)
        })
        
        alert.addAction(UIAlertAction(title: "Back", style: .cancel) { [weak self] _ in
            self?.showLocationInputAlert()
        })
        
        present(alert, animated: true)
    }
    
    private func showCoordinatesInputAlert() {
        let alert = UIAlertController(
            title: "Enter Coordinates",
            message: "Enter latitude and longitude:",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Latitude (e.g., 40.7580)"
            textField.keyboardType = .decimalPad
            textField.autocapitalizationType = .none
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Longitude (e.g., -73.9855)"
            textField.keyboardType = .decimalPad
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "Use Coordinates", style: .default) { [weak self] _ in
            guard let latText = alert.textFields?[0].text, !latText.isEmpty,
                  let lonText = alert.textFields?[1].text, !lonText.isEmpty else {
                self?.showError(message: "Please enter both latitude and longitude")
                return
            }
            self?.processCoordinatesInput(latitude: latText, longitude: lonText)
        })
        
        alert.addAction(UIAlertAction(title: "Back", style: .cancel) { [weak self] _ in
            self?.showLocationInputAlert()
        })
        
        present(alert, animated: true)
    }
    
    private func processCoordinatesInput(latitude latText: String, longitude lonText: String) {
        guard let lat = Double(latText.trimmingCharacters(in: .whitespaces)) else {
            showError(message: "Invalid latitude. Please enter a valid number.\nExample: 40.7580")
            return
        }

        guard let lon = Double(lonText.trimmingCharacters(in: .whitespaces)) else {
            showError(message: "Invalid longitude. Please enter a valid number.\nExample: -73.9855")
            return
        }

        guard lat >= -90 && lat <= 90 else {
            showError(message: "Invalid latitude. Must be between -90 and 90\nYour value: \(lat)")
            return
        }

        guard lon >= -180 && lon <= 180 else {
            showError(message: "Invalid longitude. Must be between -180 and 180\nYour value: \(lon)")
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let coordinateString = String(format: "%.6f, %.6f", lat, lon)
        showLocationConfirmation(coordinate: coordinate, address: coordinateString)
    }
    
    private func showMapForPinPlacement() {
        // Show map
        tableView.isHidden = true
        mapView.isHidden = false
        
        if let currentLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(
                center: currentLocation,
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            )
            mapView.setRegion(region, animated: true)
        } else {
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 23.8103, longitude: 90.4125),
                latitudinalMeters: 10000,
                longitudinalMeters: 10000
            )
            mapView.setRegion(region, animated: true)
        }

        addInstructionLabel()
        
        let instructionAlert = UIAlertController(
            title: "Tap Map to Place Pin",
            message: "Tap anywhere on the map to place your pin at that exact location. You can tap multiple times to adjust the position.\n\nThen tap 'Create' button to create QR code.",
            preferredStyle: .alert
        )
        
        instructionAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(instructionAlert, animated: true)
    }
    
    private func addInstructionLabel() {
        instructionLabel?.removeFromSuperview()
        
        let label = UILabel()
        label.text = "📍 Tap map to place pin, then tap 'Create'"
        label.textAlignment = .center
        label.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.numberOfLines = 1
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 10),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.heightAnchor.constraint(equalToConstant: 40),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        
        view.bringSubviewToFront(label)
        instructionLabel = label
    }

    private func processLocationInput(_ input: String) {
        let components = input.components(separatedBy: ",")
        if components.count == 2,
           let lat = Double(components[0].trimmingCharacters(in: .whitespaces)),
           let lon = Double(components[1].trimmingCharacters(in: .whitespaces)),
           lat >= -90 && lat <= 90,
           lon >= -180 && lon <= 180 {
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let coordinateString = String(format: "%.6f, %.6f", lat, lon)
            showLocationConfirmation(coordinate: coordinate, address: coordinateString)
            return
        }
        
        geocodeLocation(input)
    }
    
    private func geocodeLocation(_ locationString: String) {
        let geocoder = CLGeocoder()
        
        let loadingAlert = UIAlertController(title: nil, message: "Searching location...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: loadingAlert.view.bottomAnchor, constant: -20)
        ])
        present(loadingAlert, animated: true)
        
        geocoder.geocodeAddressString(locationString) { [weak self] placemarks, error in
            loadingAlert.dismiss(animated: true) {
                if let error = error {
                    self?.showError(message: "Could not find this location")
                    return
                }
                
                guard let placemark = placemarks?.first,
                      let coordinate = placemark.location?.coordinate else {
                    self?.showError(message: "No location found for '\(locationString)'")
                    return
                }
                
                var addressParts: [String] = []
                if let name = placemark.name { addressParts.append(name) }
                if let locality = placemark.locality { addressParts.append(locality) }
                if let country = placemark.country { addressParts.append(country) }
                let address = addressParts.isEmpty ? locationString : addressParts.joined(separator: ", ")
                
                self?.showLocationConfirmation(coordinate: coordinate, address: address)
            }
        }
    }
    
    private func useCurrentLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            guard let coordinate = locationManager.location?.coordinate else {
                showError(message: "Could not get current location. Please try again.")
                return
            }
            
            showLocationConfirmation(coordinate: coordinate, address: "Current Location")
            
        case .denied, .restricted:
            showError(message: "Location access denied. Please enable in Settings.")
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.useCurrentLocation()
            }
            
        @unknown default:
            showError(message: "Unable to access location")
        }
    }
    
    private func showLocationConfirmation(coordinate: CLLocationCoordinate2D, address: String) {
        tableView.isHidden = true
        mapView.isHidden = false
        addPinToMap(at: coordinate)
        
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )
        mapView.setRegion(region, animated: true)
        
        addInstructionLabel()
        
        let confirmAlert = UIAlertController(
            title: "Pin Placed",
            message: "\(address)\n\nTap map to adjust pin position, then tap 'Create' button to create QR code.",
            preferredStyle: .alert
        )
        
        confirmAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        confirmAlert.addAction(UIAlertAction(title: "Enter Different Location", style: .default) { [weak self] _ in
            self?.instructionLabel?.removeFromSuperview()
            self?.mapView.isHidden = true
            self?.tableView.isHidden = false
            self?.showLocationInputAlert()
        })
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.instructionLabel?.removeFromSuperview()
            self?.mapView.isHidden = true
            self?.tableView.isHidden = false
            self?.collectionViewForIcon.reloadData()
        })
        
        present(confirmAlert, animated: true)
    }
    
    private func createLocationQR(coordinate: CLLocationCoordinate2D, address: String) {
        selectedMapCoordinate = coordinate
        currentLocationString = "GEO:\(coordinate.latitude),\(coordinate.longitude)"
        
        instructionLabel?.removeFromSuperview()
        
        mapView.isHidden = true
        tableView.isHidden = false
        self.btnTag(index: 0)
        self.goResultVc(string: currentLocationString)
    }
    

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.showLocationInputAlert()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.collectionViewForIcon.reloadData()
        })
        present(alert, animated: true)
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTable?.isHidden = false
        searchResultsTable?.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
    
    private func selectSearchResult(_ result: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { [weak self] response, error in
            guard let self = self,
                  let response = response,
                  let mapItem = response.mapItems.first else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let coordinate = mapItem.placemark.coordinate
            
            self.addPinToMap(at: coordinate)
            
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            self.mapView.setRegion(region, animated: true)
            
            self.locationSearchBar?.resignFirstResponder()
            self.searchResultsTable?.isHidden = true
        }
    }
    
    
    func gotoView()  {
        
        let pressedCount = UserDefaults.standard.integer(forKey: "rate_press_count")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if pressedCount <= 2 {
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RatingVc") as! RatingVc
            vc.modalPresentationStyle = .overCurrentContext
            
            
            self.present(vc, animated: true)
        }
    }
    
    
    
    
    func presentVideoPicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]    // <-- allow videos
        picker.delegate = self
        picker.videoQuality = .typeHigh
        
        present(picker, animated: true)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        
        bottomSpaceView.constant = 0
        
    }
    
    @objc func dismissKeyboard() {
        
        currentTextView.resignFirstResponder()
    }
    
    func createEvent() {
        
        
        let event = EKEvent(eventStore: self.eventStore)
        // event.title = "My Event"
        event.startDate = Date(timeIntervalSinceNow: TimeInterval())
        event.endDate = Date(timeIntervalSinceNow: TimeInterval())
        //event.notes = "Yeah!!!"
        let eventController = EKEventEditViewController()
        eventController.event = event
        eventController.editViewDelegate = self
        eventController.eventStore = self.eventStore
        eventController.modalPresentationStyle = .fullScreen
        UIApplication.topMostViewController?.present(eventController, animated: true, completion: {
        })
    }
    
    func showLocationAlert()
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Location Access required",
                message: "To create qr code from Location you need to give location permission",
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "Cancel".localize(), style: .default, handler: { (alert) -> Void in
                // Store.sharedInstance.setshouldShowHomeScreen(value: true)
                
                
                
                
            }))
            alert.addAction(UIAlertAction(title: "Allow Access", style: .default, handler: { (alert) -> Void in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func goResultVc(string: String, event:EKEvent){
        
         
        
        
        
//        let value = QrParser.getBarCodeObj(text: string)
//        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVc") as! ShowResultVc
//        vc.stringValue = string
//        vc.modalPresentationStyle = .fullScreen
//        vc.createDataModelArray = createDataModelArray
//        vc.showText = value
//        vc.currenttypeOfQrBAR = "event"
//        vc.eventF = event
//        vc.templateImage = templateImage
//        vc.templateFileName = fileName
//        vc.selectedPreset = self.selectedPreset
//        vc.gifData = gifData
//        vc.shouldShowWhite = shouldShowWhite
//        UIApplication.topMostViewController?.present(vc, animated: true, completion: {
//            self.btnTag(index: 0)
//        })
        
    }
    @IBAction func createBtnPressed(_ sender: Any) {
        print("it  has been called wow \(currentSelectedName)")
        
        
        if (!Store.sharedInstance.isActiveSubscription()) {
            
            if !isfromQr {
                
                print("bar code name i found \(currentSelectedName)")
                
                
                if(currentSelectedName.containsIgnoringCase(find: "ean-13")) {
                    
                }
                else {
                    
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "SubscriptionVc") as! SubscriptionVc
//                    initialViewController.modalPresentationStyle = .fullScreen
//                    
//                    self.present(initialViewController, animated: true, completion: nil)
//                    return
                }
                
            }
            else {
                if  isfromQr  {
                    
                    
                    if currentIndex.section > 1 {
                        
                        
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let initialViewController = storyboard.instantiateViewController(withIdentifier: "SubscriptionVc") as! SubscriptionVc
//                        initialViewController.modalPresentationStyle = .fullScreen
//                        
//                        self.present(initialViewController, animated: true, completion: nil)
//                        return
                    }
                }
                
            }
        }
        
        self.gotoeditView()
        
    }
    
    func goResultVc(string: String){
        
        
        self.dismiss(animated: true) {
            
//            let value = QrParser.getBarCodeObj(text: string)
//            
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVc") as! ShowResultVc
//            vc.stringValue = string
//            vc.modalPresentationStyle = .fullScreen
//            vc.createDataModelArray = self.createDataModelArray
//            vc.showText = value
//            vc.currenttypeOfQrBAR = self.temp
//            vc.isfromQr = true
//            vc.templateImage = self.templateImage
//            vc.templateFileName = self.fileName
//            vc.selectedPreset = self.selectedPreset
//            vc.gifData = self.gifData
//            vc.shouldShowWhite = self.shouldShowWhite
//            UIApplication.topMostViewController?.transitionVc(vc: vc, duration: 0.4, type: .fromRight)
        }
        
    }
    
    func forBarCode () {
        
        fromQrCode = false
        mapView.isHidden = true
        self.createDataModelArray.removeAll()
        self.inputParemeterArray.removeAll()
        
        isfromQr = false
        
        currentIndex = IndexPath(row: 0, section: 0)
        currentSelectedName = "EAN-13"
        
        
        // hide7.isHidden = true
        
        
        
        
        self.collectionViewForIcon.reloadData()
        
        inputParemeterArray = Constant.getInputParemeterByType(type: "BarCode")
        for _ in self.inputParemeterArray {
            self.createDataModelArray.append(ResultDataModel(title: "Enter Code", description: ""))
        }
        self.tableView.reloadData()
    }
    
    func gotoeditView() {
        
        
        
        print("called has been done")
        
        
        if self.currentSelectedName == "Location" || self.currentSelectedName.localize() == "Location".localize() {
            
            // If we have a selected coordinate from the map pin, use it directly
            if let coordinate = selectedMapCoordinate {
                let locationString = "GEO:\(coordinate.latitude),\(coordinate.longitude)"
                print("✅ Using pin location: \(locationString)")
                
                self.btnTag(index: 0)
                self.goResultVc(string: locationString)
                
                temp = "Location"
                return
            }
            
            // Otherwise check location permissions and use current location
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
                
            case .denied:
                showLocationAlert()
                return
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
                mapView.showsUserLocation = true
            case .restricted:
                break
            case .authorizedAlways:
                break
            @unknown default: break
                
            }
            
            self.btnTag(index: 0)
            
            let locationString = self.currentLocationString.isEmpty ? "GEO:0,0" : self.currentLocationString
            self.goResultVc(string: locationString)
            
            temp = "Location"
            
            return
            
        }
        
        self.updateTextView()
        
        temp = currentSelectedName
        
        if  !isfromQr {
            
            temp = currentSelectedName
            
        }
        
        print(currentSelectedName)
        Constant.createQrCode_BarCodeByType(type: temp, modelArray: self.createDataModelArray, complation: { [self] contact, string in
            print("mamam")
            
            var flag = 0
            
            
            if currentSelectedName.containsIgnoringCase(find: "snapchat") {
                
                if let v = string {
                    
                    if v.containsIgnoringCase(find: "http"), v.containsIgnoringCase(find: "snapchat") {
                        
                    }
                    else {
                        
                        let alert = UIAlertController(title: "Note".localize(), message: "Enter_f".localize(), preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: {_ in
                            ////self.dismissView()
                        }))
                        
                        UIApplication.topMostViewController?.present(alert, animated: true, completion: {
                            
                        })
                        
                        return
                        
                    }
                }
                
            }
            
            
            if currentSelectedName.containsIgnoringCase(find: "wechat") {
                
                if let v = string {
                    
                    if v.containsIgnoringCase(find: "http"), v.containsIgnoringCase(find: "wechat") {
                        
                    }
                    else {
                        
                        let alert = UIAlertController(title: "Note".localize(), message: "Enter_f".localize(), preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: {_ in
                            ////self.dismissView()
                        }))
                        
                        UIApplication.topMostViewController?.present(alert, animated: true, completion: {
                            
                        })
                        
                        return
                        
                    }
                }
                
            }
            
            
            
            if currentSelectedName.containsIgnoringCase(find: "vcard") || currentSelectedName.containsIgnoringCase(find: "mecard"){
                
                for item in createDataModelArray {
                    
                    if item.description.count > 0 {
                        flag = 1
                    }
                }
                if flag == 0 {
                    let alert = UIAlertController(title: "Note".localize(), message: "Enter_f".localize(), preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: {_ in
                        ////self.dismissView()
                    }))
                    
                    UIApplication.topMostViewController?.present(alert, animated: true, completion: {
                        
                    })
                    
                    return
                }
            }
            
            
            if createDataModelArray.count == 1 ||  currentSelectedName.containsIgnoringCase(find: "sms") || currentSelectedName.containsIgnoringCase(find: "mms") || currentSelectedName.containsIgnoringCase(find: "email"){
                
                if createDataModelArray[0].description.count < 1 {
                    
                    let alert = UIAlertController(title: "Note".localize(), message: "Enter_f".localize(), preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: {_ in
                        ////self.dismissView()
                    }))
                    
                    UIApplication.topMostViewController?.present(alert, animated: true, completion: {
                        
                    })
                    
                    return
                    
                }
            }
            
            
            if string == nil, !currentSelectedName.containsIgnoringCase(find: "vcard") {
                
                let alert = UIAlertController(title: "Note".localize(), message: "Enter_f".localize(), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: {_ in
                    ////self.dismissView()
                }))
                
                UIApplication.topMostViewController?.present(alert, animated: true, completion: {
                    
                })
                
                return
            }
            
            
            if  !isfromQr {
                
                
                
                let image = BarCodeGenerator.getBarCodeImage(type: self.currentSelectedName, value: string!)
                
                if let value = image {
//                    self.dismiss(animated: true) {
//                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVc") as! ShowResultVc
//                        vc.stringValue = string!
//                        vc.modalPresentationStyle = .fullScreen
//                        vc.image = image
//                        vc.isfromQr = false
//                        vc.currenttypeOfQrBAR = self.currentSelectedName
//                        
//                        
//                        
//                        
//                        UIApplication.topMostViewController?.transitionVc(vc: vc, duration: 0.4, type: .fromRight)
//                    }
                    
                    return
                    
                }
                else {
                    let alert = UIAlertController(title: "Note".localize(), message: "Invalid Code!".localize(), preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: {_ in
                        ////self.dismissView()
                    }))
                    
                    UIApplication.topMostViewController?.present(alert, animated: true, completion: {
                        
                    })
                    
                    return
                    
                }
                
                
            }
            
            
            
            if self.currentSelectedName  == "Vcard"{
                var vcard = NSData()
                // let usersContact = CNMutableContact()
                do {
                    try vcard = CNContactVCardSerialization.data(with: [contact!] )  as NSData
                    let vcString = String(data: vcard as Data, encoding: .utf8)
                    // print("string  ", vcString)
                    self.goResultVc(string: vcString!)
                    
                } catch {
                    print("Error \(error)")
                }
            }else{
                self.goResultVc(string: string!)
                // print("String11  ", string)
            }
        })
    }
    
    func addEventToCalendar(){
        let completion: EKEventStoreRequestAccessCompletionHandler = { granted, error in
            DispatchQueue.main.async { [weak self] in
                if granted {
                    self?.createEvent()
                } else {
                    self?.showAlert()
                }
            }
        }
        
        switch EKEventStore.authorizationStatus(for: .event) {
            
        case .authorized:
            createEvent()
            
        case .denied:
            self.showAlert()
            
        case .notDetermined:
            if #available(iOS 17.0, *) {
                print("iOS 17.0 and higher")
                eventStore.requestFullAccessToEvents(completion: completion)
            } else {
                print("less than iOS 17.0")
                eventStore.requestAccess(to: .event, completion: completion)
            }
            
            print("Not Determined")
        default:
            print("Case Default")
        }
        
        
    }
    
    
    func checkLocationServices() {
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                self.setUpLocation()
                self.checkLocationAuthorization()
            } else {
                print("Location services are disabled")
            }
        }
    }
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: break
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            
        case .denied:
            
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
            mapView.showsUserLocation = true
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default: break
            
        }
    }
    
    
    
    func setUpLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }
    
    
    
    @objc func segmentAction(_ segmentedControl: UISegmentedControl) {
        
        
        let array = ["WAP/WAP2", "WEP", "NONE"]
        self.createDataModelArray[2].description = array[segmentedControl.selectedSegmentIndex]
        
        
    }
    
    func updateValue(){
        
        currentTextView.resignFirstResponder()
        tableView.reloadData()
        dismissKeyboard()
        
    }
    
    @objc func buttonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "ContactListViewController") as! ContactListViewController
        initialViewController.modalPresentationStyle = .fullScreen
        initialViewController.delegate = self
        transitionVc(vc: initialViewController, duration: 0.4, type: .fromRight)
    }
    
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        
        // tableView.reloadData()
        
        self.updateTextView()
        
        ///print("mammamamma")
        
    }
    
    func updateTextView(){
        
        let index = currentTextView.tag
        let type = self.inputParemeterArray[index].title
        // self.createDataModelArray[index].title = type
        self.createDataModelArray[index].description = currentTextView.text
        
        var height = 110
        
        if type.containsIgnoringCase(find: "text") || type.containsIgnoringCase(find: "Message") || type.containsIgnoringCase(find: "body") {
            height = 200
            
        }
        
        var frame = currentTextView.frame
        frame.size.height = currentTextView.contentSize.height
        
        self.inputParemeterArray[index].height = max(height, Int(frame.size.height) + 20 + 35 + 30)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        visibleRect.origin = collectionViewForIcon.contentOffset
        visibleRect.size = collectionViewForIcon.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = collectionViewForIcon.indexPathForItem(at: visiblePoint) else { return }
        let dic = qrCategoryArray[indexPath.section] as? Dictionary<String, Any>
        currentIndex = indexPath
        collectionViewForIcon.reloadData()
        
        var currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        // Print the current page
        print("Current Page lol: \(currentPage)")
        currentPage = currentPage + 1
        if isfromQr {
            progressBar.setPercentage(CGFloat(20 * currentPage))
        }
        else {
            progressBar.setPercentage(CGFloat(50 * currentPage))
        }
    }
    
    func showAlert(){
        
        let alertController = UIAlertController (title: "title".localize(), message: "Go".localize(), preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings".localize(), style: .default) { (_) -> Void in
            
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel".localize(), style: .default) { action in
            
            self.btnTag(index: 0)
            self.tableView.reloadData()
        }
        alertController.addAction(cancelAction)
        UIApplication.topMostViewController?.present(alertController, animated: true, completion: {
            
            
        })
        //present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        print("sadiq")
        let currentLocation = locations.first?.coordinate
        
        if let a = currentLocation?.longitude,let b = currentLocation?.latitude {
            currentLocationString = "GEO:\(a),\(b)"
        }
    }
    
    func btnTag(index: Int) {
        //conactBtn.isHidden = true
        selectedIndex = index
        shouldShowContact = false
        
        dismissKeyboard()
        inputParemeterArray.removeAll()
        createDataModelArray.removeAll()
        mapView.isHidden = true
        
        hideSearchBar()
        instructionLabel?.removeFromSuperview()
        
        self.currentTextView.text = ""
        
        if !isfromQr {
            
            currentBrCode = index
            print("muntasir = \(currentIndex.row)")
            print("muntasir1 = \(currentIndex.section)")
            
            
            
            currentSelectedName = barCategoryArray[currentIndex.row * 6 + index] as! String
            inputParemeterArray = Constant.getInputParemeterByType(type: "BarCode")
            for _ in self.inputParemeterArray {
                self.createDataModelArray.append(ResultDataModel(title: "Enter Code", description: ""))
            }
            collectionViewForIcon.reloadData()
            tableView.reloadData()
            return
        }
        
        
        
        print(currentIndex.row)
        print(currentIndex.section)
        
        print("muntasir = \(currentIndex.row)")
        print("muntasir1 = \(currentIndex.section)")
        
        
        
        let dic = qrCategoryArray[currentIndex.section] as? Dictionary<String, Any>
        if let  itemName  = dic!["items"] as? NSArray {
            
            
            if (itemName[index] as! String)  == "Event" {
                
                isFromEvnt = true
                self.createDataModelArray.removeAll()
                self.inputParemeterArray.removeAll()
                self.addEventToCalendar()
                self.collectionViewForIcon.reloadData()
                tableView.reloadData()
                return
            }
            
            let index =   currentIndex.row*6 + index
            print(itemName[index])
            
            currentSelectedName = itemName[index]  as! String
            createDataModelArray.removeAll()
            
            tableView.isHidden = false
            mapView.isHidden = true
            
            if (itemName[index] as! String).containsIgnoringCase(find: "vcard") {
                shouldShowContact = true
            }
            
            if (itemName[index] as! String)  == "Location" {
                let locationIndex = currentIndex.row * 6 + index
                currentSelectedName = (itemName[locationIndex] as! String).localize()
                
                collectionViewForIcon.reloadData()
                showLocationInputAlert()
                return
            }
            
            inputParemeterArray = Constant.getInputParemeterByType(type: itemName[index] as! String)
            for v in self.inputParemeterArray {
                if v.text.count > 0 {
                    self.createDataModelArray.append(ResultDataModel(title: v.title, description: v.text))
                    
                }
                else {
                    self.createDataModelArray.append(ResultDataModel(title: v.title, description: ""))
                }
                
            }
            
        }
        tableView.reloadData()
        collectionViewForIcon.reloadData()
        self.dismissKeyboard()
        isFromEvnt = false
        //self.currentTextView.becomeFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.currentTextView = textView
        collectionViewForIcon.reloadData()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            
            bottomSpaceView.constant  = 50
            
            
            
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        view.window?.layer.add(transition, forKey: "leftToRightTransition")
        dismiss(animated: false, completion: nil)
        
    }
    
    
    func getNotes() -> String {
        
        if currentSelectedName.containsIgnoringCase(find: "EAN-13") {
            
            return "12 digits and 1 check digit"
        }
        
        if currentSelectedName.containsIgnoringCase(find: "EAN-8") {
            
            return "7 digits and 1 check digit"
        }
        
        if currentSelectedName.containsIgnoringCase(find: "UPC-A") {
            
            return "11 digits and 1 check digit"
        }
        
        if currentSelectedName.containsIgnoringCase(find: "UPC-E") {
            
            return "7 digits and 1 check digit"
        }
        
        if currentSelectedName.containsIgnoringCase(find: "CODE 39") {
            
            return "Only A-Z, digits, -, ., space, $, /, +, %, *"
        }
        
        if currentSelectedName.containsIgnoringCase(find: "CODE 128") {
            
            return "Text, no special characters"
        }
        
        if currentSelectedName.containsIgnoringCase(find: "Data Matrix") {
            
            return "Numeric, alphanumeric and binary Data"
        }
        if currentSelectedName.containsIgnoringCase(find: "Aztec") {
            
            return "Numeric and alphanumeric characters, binary data, and special characters."
        }
        if currentSelectedName.containsIgnoringCase(find: "PDF417") {
            
            return "Alphanumeric characters & digits"
        }
        
        return "Alphanumeric characters & digits"
        
        
    }
    
    
    fileprivate func isOnlyDecimal(type: String) -> Bool {
        print("ayat : ", type)
        if type.containsIgnoringCase(find: "number") || type == "Mobile:" || type == "Phone:" || type == "Fax:" || type == "Zip:" || type.containsIgnoringCase(find: "ean-13") || type.containsIgnoringCase(find: "ean-8") || type == "Ean-E:" || type == "ITF:" || type.containsIgnoringCase(find: "upc-a") || type.containsIgnoringCase(find: "upc-e") || type.containsIgnoringCase(find: "itf"){
            return true
        }else{
            return false
        }
    }
    
    
    func isSmallerThaniPhoneX() -> Bool {
        
        let iPhoneXHeight = 812.0 // Height of iPhone X in points
        let currentDeviceHeight = UIScreen.main.bounds.height
        return currentDeviceHeight < iPhoneXHeight
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

extension CreateQrVc:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: IconViewColl.reusableID,
            for: indexPath) as? IconViewColl else {
            return IconViewColl()
        }

        // MARK: - Reset Shadows
        let views = [
            cell.view1, cell.view2, cell.view3, cell.view4,
            cell.view5, cell.view6, cell.view7, cell.view8
        ]

        for view in views {
            view?.dropShadow(shouldShow: false)
        }

        // MARK: - Reset Pro Badges
        let pros = [
            cell.pro1, cell.pro2, cell.pro3, cell.pro4,
            cell.pro5, cell.pro6, cell.pro7, cell.pro8
        ]

        for pro in pros {
            pro?.isHidden = true
        }

        // MARK: - Subscription Logic
        if !Store.sharedInstance.isActiveSubscription() {
            
            if !isfromQr {
                
                let index = indexPath.row * 8
                
                if index < barCategoryArray.count,
                   let v = barCategoryArray[index] as? String {
                    
                    if v.containsIgnoringCase(find: "ean-13") {
                        cell.pro1.isHidden = true
                    } else {
                        cell.pro1.isHidden = false
                    }
                }
                
                // Show PRO badge for others
                for i in 1..<8 {
                    pros[i]?.isHidden = false
                }
            }
            
            if isfromQr, currentIndex.section > 1 {
                for pro in pros {
                    pro?.isHidden = false
                }
            }
        }

        // MARK: - Data Binding

        let labels = [
            cell.lbl1, cell.lbl2, cell.lbl3, cell.lbl4,
            cell.lbl5, cell.lbl6, cell.lbl7, cell.lbl8
        ]

        let images = [
            cell.imv1, cell.imv2, cell.imv3, cell.imv4,
            cell.imv5, cell.imv6, cell.imv7, cell.imv8
        ]

        let startIndex = indexPath.row * 8

        if isfromQr,
           let dic = qrCategoryArray[indexPath.section] as? [String: Any],
           let items = dic["items"] as? [String] {
            
            for i in 0..<8 {
                let currentIndex = startIndex + i
                
                if currentIndex < items.count {
                    let text = items[currentIndex]
                    labels[i]?.text = text.localize()
                    images[i]?.image = UIImage(named: text)
                } else {
                    labels[i]?.text = ""
                    images[i]?.image = nil
                }
            }
            
        } else {
            
            for i in 0..<8 {
                let currentIndex = startIndex + i
                
                if currentIndex < barCategoryArray.count,
                   let text = barCategoryArray[currentIndex] as? String {
                    
                    labels[i]?.text = text.localize()
                    images[i]?.image = UIImage(named: text)
                    
                } else {
                    labels[i]?.text = ""
                    images[i]?.image = nil
                }
            }
        }

        // MARK: - Hide Empty Views Automatically
        for i in 0..<8 {
            let text = labels[i]?.text ?? ""
            views[i]?.isHidden = text.isEmpty
        }

        // MARK: - Highlight Selected
        for i in 0..<8 {
            if labels[i]?.text == currentSelectedName {
                views[i]?.dropShadow(shouldShow: true)
            }
        }

        // MARK: - Layout Updates
        cell.widthForBtn.constant = cell.view1.frame.width
        cell.heightForBtn.constant = cell.view1.frame.height

        cell.heightForImv.constant = 45

        cell.widthForLbl1.constant = cell.view1.frame.width
        cell.widthForLbl2.constant = cell.view2.frame.width
        cell.widthForlbl3.constant = cell.view3.frame.width
        cell.widthForlbl4.constant = cell.view4.frame.width
        cell.widthForLbl5.constant = cell.view5.frame.width
        cell.widthForLbl6.constant = cell.view6.frame.width
        cell.widthForLbl7.constant = cell.view7.frame.width
        cell.widthForLbl8.constant = cell.view8.frame.width

        cell.delegateForbtnTag = self

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width - 2 * 7, height: 290)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        // splace between two cell horizonatally
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        // splace between two cell vertically
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if !isfromQr {
            return 1
        }
        return qrCategoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if  !isfromQr {
            return 2
        }
        
        let dic = qrCategoryArray[section] as? Dictionary<String, Any>
        
        if let  itemName  = dic!["items"] as? NSArray {
            return  max(itemName.count / 8,1)
            
        }
        return 1
    }
}


extension CreateQrVc: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == searchResultsTable {
            return 60
        }
        
        if isFromEvnt {
            print("perfect")
            return 0
        }
        
        let height = CGFloat(self.inputParemeterArray[indexPath.item].height) + 10
        return height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == searchResultsTable {
            return numberOfSearchResults()
        }
        
        if isFromEvnt {
            print("perfect")
            return 0
        }
        return   self.inputParemeterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == searchResultsTable {
            return searchResultCell(at: indexPath, for: tableView)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputTextTableViewCell", for: indexPath) as! InputTextTableViewCell
        cell.selectionStyle = .none
        cell.textView.textContainerInset = .zero
        cell.textView.font = UIFont.boldSystemFont(ofSize: 14.0)
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        cell.textView.inputAccessoryView = keyboardToolbar
        cell.textView.text = ""
        cell.textView.scrollRangeToVisible(NSMakeRange(0, 0))
        cell.contactBtn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        
        if shouldShowContact,indexPath.row == 0 {
            cell.contactBtn.isHidden = false
            cell.contactBtn.setTitle("", for: .normal)
        }
        else {
            cell.contactBtn.isHidden = true
        }
        
        if  fromQrCode,!isFromEvnt {
            if self.isOnlyDecimal(type: self.createDataModelArray[indexPath.item].title) {
                cell.textView.keyboardType = .asciiCapableNumberPad
            }else{
                cell.textView.keyboardType = .default
            }
        }
        else {
            
            if self.isOnlyDecimal(type: currentSelectedName) {
                cell.textView.keyboardType = .asciiCapableNumberPad
            }
            else {
                cell.textView.keyboardType = .default
            }
        }
        
        
        
        if indexPath.row == 0 {
            
        }
        
        
        //cell.switchF.isHidden =  true
        
        cell.textView.tag = indexPath.item
        cell.textView.delegate = self
        
        // cell.textView.layer.shadowColor = UIColor.black.cgColor
        // cell.textView.layer.shadowOpacity = 1
        // cell.textView.layer.shadowOffset = .zero
        
        
        cell.backgroundColor = tableView.backgroundColor
        
        print("mamam = \(inputParemeterArray[indexPath.item].text)")
        print("mamam = \(inputParemeterArray[indexPath.item].title)")
        
        cell.textView.text =  self.createDataModelArray[indexPath.item].description
        
        
        cell.textViewContainer.backgroundColor = UIColor.white
        
        cell.label.text =  self.inputParemeterArray[indexPath.item].title.localize()
        
        cell.label.textColor = UIColor.black
        cell.textView.textColor = UIColor.black
        cell.configCell()
        // cell.textView.centerVertically()
        cell.textView.textContainerInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        /// cell.textView.adjustUITextViewHeight()
        
        
        
        print(self.inputParemeterArray[indexPath.item].title)
        let textF = self.createDataModelArray[indexPath.item].title
        
        cell.networkName.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        
        if  self.createDataModelArray[indexPath.item].title.containsIgnoringCase(find: "hidden") {
            
            print("dada")
            
            cell.networkName.isHidden = true
            cell.textView.isHidden = true
            // cell.switchF.isHidden = false
            cell.textViewContainer.backgroundColor = UIColor.clear
            
            let genderIndex = cell.networkName.selectedSegmentIndex
            
            if genderIndex == 0 {
                self.createDataModelArray[indexPath.item].description = "Hidden"
            }
            else {
                self.createDataModelArray[indexPath.item].description = "Not"
            }
        }
        
        
        else if textF.contains(find: "Encription") {
            print("mamamamamammamamamamammama")
            cell.textView.isHidden = true
            cell.networkName.isHidden = false
            
        } else {
            cell.networkName.isHidden = true
            cell.textView.isHidden = false
        }
        
        
        if !fromQrCode, indexPath.row == 1 {
            
            cell.textView.isUserInteractionEnabled = false
            cell.textView.text =  self.getNotes().localize()
        }
        else {
            cell.textView.isUserInteractionEnabled = true
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        if tableView == searchResultsTable {
            didSelectSearchResult(at: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}



extension UIView {
    func dropShadow(scale: Bool = true ,shouldShow:Bool = false) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        if shouldShow {
            layer.borderWidth = 3.0
            layer.borderColor = tabBarBackGroundColor.withAlphaComponent(0.5).cgColor
        }
        else {
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
        }
    }
}


struct CreateDataModel {
    var title = ""
    var text = ""
    var height = 0
}

struct ResultDataModel {
    var title = ""
    var description = ""
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
    
    init(dictionary : [String:String]) {
        self.title = dictionary["title"]!
        self.description = dictionary["description"]!
    }
    
    var dictionaryRepresentation : [String:String] {
        return ["title" : title, "description" : description]
    }
    
    
}

extension CreateQrVc {
    
    func numberOfSearchResults() -> Int {
        return searchResults.count
    }
    
    func searchResultCell(at indexPath: IndexPath, for tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let result = searchResults[indexPath.row]
        
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        cell.textLabel?.numberOfLines = 1
        cell.detailTextLabel?.numberOfLines = 1
        
        return cell
    }
    
    func didSelectSearchResult(at indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        selectSearchResult(result)
    }
}

extension CreateQrVc: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchResults.removeAll()
            searchResultsTable?.isHidden = true
            searchResultsTable?.reloadData()
            return
        }
        
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResults.removeAll()
        searchResultsTable?.isHidden = true
        searchResultsTable?.reloadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
