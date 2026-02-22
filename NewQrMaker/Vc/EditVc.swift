//
//  EditVc.swift
//  QrCodeMaker
//
//  Created by Sadiqul Amin on 26/7/23.
//

import UIKit
import Contacts
import MapKit


protocol sendUpdatedArray {
    func processYelpData(ar: [ResultDataModel],sh:String,st:String)
}

class EditVc: UIViewController, UITextViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var widthF = 320
    var heightF = 320
    
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var donebtn: UIButton!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var lifeTime: UILabel!
    @IBOutlet weak var btn: UIImageView!
    @IBOutlet weak var topView: UIView!
    var delegate: sendUpdatedArray?
    var isFromQr = false
    
    @IBOutlet weak var heightTopView: NSLayoutConstraint!
    @IBOutlet weak var timeLabelText: UILabel!
    @IBOutlet weak var bottomSpacetableView: NSLayoutConstraint!
    var createDataModelArray = [ResultDataModel]()
    var currentTextview:UITextView?
    var isFinished  = false
    var currenttypeOfQrBAR = ""
    var showText = ""
    let locationManager = CLLocationManager()
    var currentLocationString = ""
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "InputTextTableViewCell", bundle: nil), forCellReuseIdentifier: "InputTextTableViewCell")
        tableView.separatorColor = UIColor.clear
        widthF  = Int((self.view.frame.size.width)*0.85)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        print(createDataModelArray)
        
        btn.layer.cornerRadius = btn.frame.size.height / 2.0
        btn.clipsToBounds = true
        
        backBtn.setTitle("Back".localize(), for: .normal)
        donebtn.setTitle("Done".localize(), for: .normal)
        
        editLabel.text = "Edit".localize()
        
        if  currenttypeOfQrBAR  == "Location" {
            self.checkLocationServices()
            tableView.isHidden = true
            mapView.isHidden = false
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("purchaseNoti"), object: nil)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func convertToSeconds(hours: Int, minutes: Int, seconds: Int) -> Int {
        let totalSeconds = hours * 3600 + minutes * 60 + seconds
        return totalSeconds
    }
    
    func formatSecondsToHHMMSS(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    @objc func appWillEnterForeground() {
        
        self.doSetup()
        
    }
    
    
    func calculateTimeDifference(referenceDate: Date) -> (hours: Int, minutes: Int, seconds: Int) {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: referenceDate, to: currentDate)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        return (hours, minutes, seconds)
    }
    
    
    
    @IBAction func gotoOffer(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OfferVc") as! OfferVc
        vc.modalPresentationStyle = .overCurrentContext
        UIApplication.topMostViewController?.present(vc, animated: true, completion: {
        })
    }
    
    
    func doSetup() {
        let userDefaults = UserDefaults.standard
        if let savedDate = userDefaults.object(forKey: "lastLoginDate") as? Date {
            
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                let (hours, minutes, seconds) = self.calculateTimeDifference(referenceDate: savedDate)
                
                let value = self.convertToSeconds(hours: hours, minutes: minutes, seconds: seconds)
                let value1 = self.convertToSeconds(hours: 24, minutes: 0, seconds: 0)
                
                
                
                let newValue = value1 - value
                
                if (newValue > 0 && !Store.sharedInstance.isActiveSubscription()) {
                    
                    let v = self.formatSecondsToHHMMSS(seconds: value1)
                    print("sadiq \(v)")
                    self.timeLabelText.text = self.formatSecondsToHHMMSS(seconds: newValue)
                }
                else {
                    self.topView.isHidden = true
                    self.topViewHeight.constant = 0
                    
                }
                
                
            }
            
        }
    }
    
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.doSetup()
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        
        
        let formattedPrice =  yearlyPrice + "/year"
        
        let attribtues = [
            NSAttributedString.Key.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue),
            NSAttributedString.Key.strikethroughColor: UIColor(red: 19/255.0, green: 105/255.0, blue: 79/255.0, alpha: 1.0)
        ]
        let attr = NSAttributedString(string: formattedPrice, attributes: attribtues)
        yearLabel.attributedText = attr
        
        lifeTime.text = oneTimePrice + "/" + "Lifetime"
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        print("nosto")
        return .darkContent
    }
    
    func setUpLocation () {
        locationManager.delegate = self
        locationManager.desiredAccuracy=kCLLocationAccuracyBest
        locationManager.distanceFilter=kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }
    
    func checkLocationServices() {
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.checkLocationAuthorization()
                self.setUpLocation()
            }
        }
        
        
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
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            
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
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        
        print(currentLocationString)
        
        if let v = currentTextview {
            v.resignFirstResponder()
        }
        
        if currenttypeOfQrBAR.containsIgnoringCase(find: "location") {
            
            if currentLocationString.count < 1 {
                self.dismiss(animated: true)
            }
            return
        }
        
        if !isFinished && (self.currentTextview != nil) {
            if (self.currentTextview?.text.count)! > 0 {
                self.dismissKeyboard()
            }
        }
        
        
        if !isFromQr {
            
            
            let value1  = createDataModelArray[0].description
            
            let image = BarCodeGenerator.getBarCodeImage(type: currenttypeOfQrBAR, value: value1)
            
            
            if let value = image {
                
                delegate?.processYelpData(ar: createDataModelArray, sh: showText, st: value1)
                self.dismiss(animated: true, completion: {
                    
                })
                
            }
            else {
                
                let alert = UIAlertController(title: "Note".localize(), message: "Invalid Code!".localize(), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: {_ in
                    ////self.dismissView()
                }))
                
                self.present(alert, animated: true)
                
            }
            
            return
            
        }
        
        Constant.createQrCode_BarCodeByType(type: currenttypeOfQrBAR, modelArray: self.createDataModelArray, complation: { [self] contact, string in
            
            var mal = string
            
            var flag  = 0
            if currenttypeOfQrBAR.containsIgnoringCase(find: "snapchat") {
                
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
            
            
            if currenttypeOfQrBAR.containsIgnoringCase(find: "wechat") {
                
                if let v = string {
                    
                    if v.containsIgnoringCase(find: "http"), v.containsIgnoringCase(find: "wechat") {
                        
                    }
                    else {
                        
                        let alert = UIAlertController(title: "Note".localize(), message: "Enter_f", preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: {_ in
                            ////self.dismissView()
                        }))
                        
                        UIApplication.topMostViewController?.present(alert, animated: true, completion: {
                            
                        })
                        
                        return
                        
                    }
                }
                
            }
            
            
            
            if currenttypeOfQrBAR.containsIgnoringCase(find: "vcard") || currenttypeOfQrBAR.containsIgnoringCase(find: "mecard"){
                
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
            
            
            if createDataModelArray.count == 1 ||  currenttypeOfQrBAR.containsIgnoringCase(find: "sms") || currenttypeOfQrBAR.containsIgnoringCase(find: "mms") || currenttypeOfQrBAR.containsIgnoringCase(find: "email"){
                
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
            
            
            if string == nil, !currenttypeOfQrBAR.containsIgnoringCase(find: "vcard") {
                
                let alert = UIAlertController(title: "Note".localize(), message: "Enter_f".localize(), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: {_ in
                    ////self.dismissView()
                }))
                
                UIApplication.topMostViewController?.present(alert, animated: true, completion: {
                    
                })
                
                return
            }
            
            if self.currenttypeOfQrBAR  == "Vcard"{
                var vcard = NSData()
                // let usersContact = CNMutableContact()
                do {
                    try vcard = CNContactVCardSerialization.data(with: [contact!] )  as NSData
                    mal = String(data: vcard as Data, encoding: .utf8)
                    // print("string  ", vcString)
                    
                    
                } catch {
                    print("Error \(error)")
                }
            }else{
                
            }
            
            
            
            showText = QrParser.getBarCodeObj(text: mal ?? "")
            delegate?.processYelpData(ar: createDataModelArray, sh: showText, st: mal!)
            
            
            let transition = CATransition()
            transition.duration = 0.4
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            view.window?.layer.add(transition, forKey: "leftToRightTransition")
            dismiss(animated: false, completion: nil)
            
            
        })
        
        
        
        
        
        
        
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        isFinished  = false
        self.currentTextview = textView
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let index = textView.tag
        isFinished = true
        print("kuttatat")
        if textView.text.count > 0 {
            self.createDataModelArray[index].description = textView.text
        }
        
    }
    
    
    
    @objc func dismissKeyboard() {
        UIView.animate(withDuration: 0.3) {
            self.bottomSpacetableView.constant = 0
            self.view.layoutIfNeeded()
        }
        
        view.endEditing(true)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
       
         
    }
    
    fileprivate func isOnlyDecimal(type: String) -> Bool {
        print("ayat : ", type)
        if type.containsIgnoringCase(find: "number") || type == "Mobile:" || type == "Phone:" || type == "Fax:" || type == "Zip:" || type.containsIgnoringCase(find: "ean-13") || type.containsIgnoringCase(find: "ean-8") || type == "Ean-E:" || type == "ITF:" || type.containsIgnoringCase(find: "upc-a") || type.containsIgnoringCase(find: "upc-e") || type.containsIgnoringCase(find: "itf"){
            return true
        }else{
            return false
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @objc func buttonAction(sender: UIButton!) {
        
         
        
    }
    
    
    @IBAction func gotoPreviousView(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        view.window?.layer.add(transition, forKey: "leftToRightTransition")
        dismiss(animated: false, completion: nil)
    }
    
    @objc func segmentAction(_ segmentedControl: UISegmentedControl) {
        currentTextview?.resignFirstResponder()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let indexPath = IndexPath(row: 2, section: 0)
            self.tableView.scrollToRow(at: indexPath , at: .bottom, animated: true)
            
        }
        
        if let gender = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) {
            
            self.createDataModelArray[2].description = gender
            
            
        }
    }
    
}




extension EditVc: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let value = createDataModelArray[indexPath.row].title
        
        if value.containsIgnoringCase(find: "text") {
            return 400
        }
        
        if value.containsIgnoringCase(find: "message") {
            return 300
        }
        
        if value.containsIgnoringCase(find: "body") {
            return 300
        }
        
        return 110
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.createDataModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
        cell.textView.text = createDataModelArray[indexPath.row].description
        
        if  isFromQr {
            if self.isOnlyDecimal(type: self.createDataModelArray[indexPath.item].title) {
                cell.textView.keyboardType = .asciiCapableNumberPad
            }else{
                cell.textView.keyboardType = .default
            }
        }
        else {
            
            if self.isOnlyDecimal(type: currenttypeOfQrBAR) {
                cell.textView.keyboardType = .asciiCapableNumberPad
            }
            else {
                cell.textView.keyboardType = .default
            }
        }
        
        
        if indexPath.row == 0, currenttypeOfQrBAR.containsIgnoringCase(find: "vcard") {
            cell.contactBtn.isHidden = false
        }
        else {
            cell.contactBtn.isHidden = true
        }
        
        
        
        
        cell.textView.tag = indexPath.item
        cell.textView.delegate = self
        
        // cell.textView.layer.shadowColor = UIColor.black.cgColor
        // cell.textView.layer.shadowOpacity = 1
        // cell.textView.layer.shadowOffset = .zero
        
        
        cell.backgroundColor = tableView.backgroundColor
        
        
        
        // cell.textView.text =  self.inputParemeterArray[indexPath.item].description
        
        
        
        
        cell.label.text =  self.createDataModelArray[indexPath.item].title.localize()
        cell.label.textColor = UIColor.black
        cell.textView.textColor = UIColor.black
        cell.configCell()
        cell.textView.centerVertically()
        cell.textView.sizeToFit()
        
        let textF = self.createDataModelArray[indexPath.item].title
        
        cell.networkName.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        //  cell.networkName.addTarget(self, action: #selector(segmentAction(_:)), for: .touchUpInside)
        
        
        if textF.containsIgnoringCase(find: "Encription") {
            print("mamamamamammamamamamammama")
            cell.networkName.isHidden = false
            
        } else {
            cell.networkName.isHidden = true
            cell.textView.isHidden = false
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if !Store.sharedInstance.isActiveSubscription() {
            return 150
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = UIColor.clear
        heightF = (164*widthF)/976
        let titleLabel = UIImageView(frame: CGRect(x:(Int(self.view.frame.width) - widthF)/Int(2.0),y: 40 ,width:widthF,height:heightF))
        titleLabel.image =  UIImage(named: "App Ad.png")
        titleLabel.isUserInteractionEnabled = true
        vw.addSubview(titleLabel)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        vw.addGestureRecognizer(tap)
        vw.isUserInteractionEnabled = true

        return vw
    }
}

extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}
