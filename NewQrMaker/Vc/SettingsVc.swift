//
//  SettingsVc.swift
//  QrCode&BarCode
//
//  Created by Macbook pro 2020 M1 on 24/2/23.
//

import UIKit
import StoreKit
import MessageUI

class SettingsVc: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var purchaseLabel: UILabel!
    @IBOutlet weak var flash: UISwitch!
    
    @IBOutlet weak var settingsTitle: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var termsOfUseLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var OthersLabel: UILabel!
    @IBOutlet weak var appSettingLabel: UILabel!
    @IBOutlet weak var purchaseHeaderLabel: UILabel!
    @IBOutlet weak var linkOpenSubValue: UILabel!
    @IBOutlet weak var linkOpenValue: UILabel!
    @IBOutlet weak var historySubLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var restoreLabel: UILabel!
    @IBOutlet weak var vibrateSublabel: UILabel!
    @IBOutlet weak var vibrateLabel: UILabel!
    @IBOutlet weak var soundSubLabel: UILabel!
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var lifeTime: UILabel!
    @IBOutlet weak var btn1: UIImageView!
    @IBOutlet weak var yearlyv: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var heightTopAddView: NSLayoutConstraint!
    @IBOutlet weak var topAddView: UIView!
    @IBOutlet weak var timeLabelText: UILabel!
    @IBOutlet weak var heightforsetting: NSLayoutConstraint!
    @IBOutlet weak var historySwitch: UISwitch!
    @IBOutlet weak var linkOpen: UISwitch!
    @IBOutlet weak var beepSwitch: UISwitch!
    @IBOutlet weak var vibrateWatch: UISwitch!
    @IBOutlet weak var soundWatch: UISwitch!
    @IBOutlet weak var HeightForTotal: NSLayoutConstraint!
    @IBOutlet weak var holderView: UIView!
    
    
    @IBOutlet weak var sueg: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
      //  btn.setTitle("", for: .normal)
        soundWatch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        vibrateWatch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
       // beepSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        historySwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        linkOpen.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
        flash.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
        btn1.layer.cornerRadius = btn1.frame.size.height / 2
        btn1.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("purchaseNoti"), object: nil)
        
        self.updateText()
        // Do any additional setup after loading the view.
    }
    
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        heightforsetting.constant = 0
      
    }
    
    func updateText() {
        purchaseHeaderLabel.text = "Purchase".localize()
        sueg.text = "Suggest".localize()
        purchaseLabel.text = "Purchase".localize()
        historyLabel.text = "History".localize()
        soundLabel.text = "Sound".localize()
        soundSubLabel.text = "Sound when you scan codes".localize()
        vibrateLabel.text = "Vibrate".localize()
        vibrateSublabel.text = "Vibrate if scan is successful".localize()
        restoreLabel.text = "Restore".localize()
        shareLabel.text = "Share this app".localize()
        historySubLabel.text = "Save history of your scans".localize()
        linkOpenValue.text = "Link Open".localize()
        linkOpenSubValue.text = "Automatically Open if scan is successful".localize()
        appSettingLabel.text = "APP SETTING".localize()
        OthersLabel.text = "OTHER".localize()
        rateLabel.text = "Rate this app".localize()
        contactLabel.text = "Contact us".localize()
        termsOfUseLabel.text = "Terms of Use".localize()
        privacyLabel.text = "Privacy Policy".localize()
        settingsTitle.text = "Settings".localize()
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        
        if soundWatch.isOn {
            UserDefaults.standard.set(2, forKey: "sound")
        } else {
            UserDefaults.standard.set(1, forKey: "sound")
        }
        
        if historySwitch.isOn {
            UserDefaults.standard.set(2, forKey: "history")
        } else {
            UserDefaults.standard.set(1, forKey: "history")
        }
        
        if vibrateWatch.isOn {
            UserDefaults.standard.set(2, forKey: "vibrate")
        } else {
            UserDefaults.standard.set(1, forKey: "vibrate")
        }
        
        
        
        if linkOpen.isOn {
            UserDefaults.standard.set(2, forKey: "Link")
        } else {
            UserDefaults.standard.set(1, forKey: "Link")
        }
        
        if flash.isOn {
            UserDefaults.standard.set(2, forKey: "falsh")
        } else {
            UserDefaults.standard.set(1, forKey: "falsh")
        }
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print(holderView.frame.origin.y)
        print(holderView.frame.size.height)
        
        HeightForTotal.constant = holderView.frame.origin.y + holderView.frame.size.height + 100
    }
    
    
    
    
    @IBAction func gotoSubscription(_ sender: Any) {
        
        
        if currentReachabilityStatus == .notReachable {
            self.showAlert()
            return
            
        }
        
       
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        print("nosto")
        return .darkContent
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
    
    
    
    @IBAction func gotoOffer(_ sender: Any) {
        
       
        
    }
    
    func doSetup() {
        let userDefaults = UserDefaults.standard
        if let savedDate = userDefaults.object(forKey: "lastLoginDate") as? Date {
            
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                let (hours, minutes, seconds) = self.calculateTimeDifference(referenceDate: savedDate)
                
                let value = self.convertToSeconds(hours: hours, minutes: minutes, seconds: seconds)
                let value1 = self.convertToSeconds(hours: 24, minutes: 0, seconds: 0)
                
                
                
                let newValue = value1 - value
                
                if (newValue > 0 && !Store.sharedInstance.isActiveSubscription())  {
                    
                    let v = self.formatSecondsToHHMMSS(seconds: value1)
                    print("sadiq \(v)")
                    self.timeLabelText.text = self.formatSecondsToHHMMSS(seconds: newValue)
                }
                else {
                    self.topAddView.isHidden = true
                    self.heightTopAddView.constant = 0
                    
                }
                
                
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isFromMultiScan = false
        
        
        let formattedPrice =  yearlyPrice + "/year"
        
        let attribtues = [
            NSAttributedString.Key.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue),
            NSAttributedString.Key.strikethroughColor: UIColor(red: 19/255.0, green: 105/255.0, blue: 79/255.0, alpha: 1.0) 
        ]
        let attr = NSAttributedString(string: formattedPrice, attributes: attribtues)
        yearlyv.attributedText = attr
        
        lifeTime.text = oneTimePrice + "/" + "Lifetime"
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        doSetup()
        
        setNeedsStatusBarAppearanceUpdate()
        let a = UserDefaults.standard.integer(forKey: "sound")
        let b = UserDefaults.standard.integer(forKey: "vibrate")
        let c = UserDefaults.standard.integer(forKey: "Beep")
        let d = UserDefaults.standard.integer(forKey: "Link")
        let e = UserDefaults.standard.integer(forKey: "history")
        
        let f = UserDefaults.standard.integer(forKey: "falsh")
        
        if(Store.sharedInstance.isActiveSubscription()) {
            
            heightforsetting.constant = 0
        }
        
        if a == 2 {
            soundWatch.setOn(true, animated: true)
        }
        else {
            soundWatch.setOn(false, animated: true)
        }
        
        if b == 2 {
            vibrateWatch.setOn(true, animated: true)
        }
        else {
            vibrateWatch.setOn(false, animated: true)
        }
        
         
        
        if d == 2 {
            linkOpen.setOn(true, animated: true)
        }
        else {
            linkOpen.setOn(false, animated: true)
        }
        
        if e == 2 {
            historySwitch.setOn(true, animated: true)
        }
        else {
            historySwitch.setOn(false, animated: true)
        }
        
        if f == 2 {
            flash.setOn(true, animated: true)
        }
        else {
            flash.setOn(false, animated: true)
        }
        
        
    }
    
    
    @IBAction func gotoTermOfUse(_ sender: Any) {
        
        
        if currentReachabilityStatus == .notReachable {
            self.showAlert()
            
        } else {
            
            
            self.gotoWebView(name: "Terms of Use", url: termsOfUseValue)
        }
        
        
        
        
    }
    
    func showAlert() {
        
        let alert = UIAlertController(title: "", message: "internet_connection".localize(), preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "ok".localize(), style: .default, handler: { action in
        })
        alert.addAction(ok)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    
    func sendEmail(subject:String?,mailAddress:String?,cc:String?,meessage:String?) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.modalPresentationStyle = .fullScreen
            if let mailAddressV = mailAddress
            {
                mail.setToRecipients([mailAddressV])
            }
            if let meessageV = meessage
            {
                mail.setMessageBody(meessageV, isHTML: false)
            }
            
            if let subjectV = subject
            {
                mail.setSubject(subjectV)
            }
            if let cctV = cc
            {
                mail.setCcRecipients([cctV])
            }
            
            present(mail, animated: true)
            
        } else {
            let alert = UIAlertController(title: "Note".localize(), message: "email_not_configured".localize(), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok".localize(), style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func gotoPrivacyPolicy(_ sender: Any) {
        
        
        if currentReachabilityStatus == .notReachable {
            self.showAlert()
            
        } else {
            self.gotoWebView(name: "Privacy Policy", url: privacyPolicyValue)
        }
        
    }
    @IBAction func suggestATEMPLATYE(_ sender: Any) {
        
        self.sendEmail(subject: "Suggest a template", mailAddress: "assistance.scannr@gmail.com", cc: "", meessage: "")

        
    }
    
    @IBAction func rateThisApp(_ sender: Any) {
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            SKStoreReviewController.requestReview()
        }
        
    }
    
    
    @IBAction func sendFeedBack(_ sender: Any) {
        
        
        self.sendEmail(subject: "FeedBack About QRMaker", mailAddress: "assistance.scannr@gmail.com", cc: "", meessage: "")
        
    }
    
    @IBAction func shareTheApp(_ sender: Any) {
        
        if let link = NSURL(string: "https://apps.apple.com/app/id6480269610") {
            let objectsToShare = ["Hi, download this cool app now!",link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
        
    }
    func gotoWebView(name:String,url:String)
    
    {
        
        
        if currentReachabilityStatus == .notReachable {
            self.showAlert()
            return
            
        }
        
        
        if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CommonViewController") as? CommonViewController{
            vc.titleForValue = name
            vc.url = url
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
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
    
    
    
}
extension String{
    func localize() -> String{
        return NSLocalizedString(self, comment: "ANYTHING")
    }
}
