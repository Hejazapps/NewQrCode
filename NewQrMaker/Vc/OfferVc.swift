//
//  OfferVc.swift
//  ScannR
//
//  Created by Sadiqul Amin on 6/19/24.
//

import UIKit
import Lottie
import ProgressHUD
import SwiftyStoreKit

class OfferVc: UIViewController {
    
    var presentMainTabOnAnyAction = false
    
    @IBOutlet weak var lifeTimeText: UILabel!
    var completeOnboarding : (() -> Void)?
    @IBOutlet weak var aniamtionView: LottieAnimationView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var lottiView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        crossBtn.setTitle("", for: UIControl.State.normal)
        aniamtionView.animation = LottieAnimation.named("bubble.json")
        aniamtionView.loopMode = .loop
        aniamtionView.play()
        aniamtionView.layer.cornerRadius = 20.0
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.doSetup()
       
        lifeTimeText.text =  oneTimePrice + "-" + "Lifetime"
        
    }
    
    func buyAproduct(value:String)
    {
        
        
        if currentReachabilityStatus == .notReachable {
            self.showAlert()
            return
            
        }
        
        DispatchQueue.main.async{
            
            ProgressHUD.animate("Purchasing...", interaction: false)
            
            
        }
        
        
        SwiftyStoreKit.purchaseProduct(value, quantity: 1, atomically: false) { result in
            switch result {
            case .success(let product):
                // fetch content from your server, then:
                if product.needsFinishTransaction {
                    Store.sharedInstance.setPurchaseActive(value: true)
                    Store.sharedInstance.verifyReciept()
                    ProgressHUD.dismiss()
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                print("Purchase Success: \(product.productId)")
                Store.sharedInstance.issubscribedIntsantly = true
                UserDefaults.standard.set(true, forKey: "OneTime")
                
                self.dismiss(animated: true)
                
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: Notification.Name("purchaseNoti"), object: nil)
                }
                
           
              

            case .error(let error):
                ProgressHUD.dismiss()
             
            case .deferred(let purchase):
                ProgressHUD.dismiss()
                print("Purchase deferred: \(purchase.productId)")
                let alert = UIAlertController(
                    title: "Purchase Pending".localize(),
                    message: "Your purchase is pending approval. You will be notified when it's complete.".localize(),
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK".localize(), style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    
    @IBAction func gotoPurchase(_ sender: Any) {
        
        
        self.buyAproduct(value: "com.sadiq.OneTime")
        
        
    }
    
    @IBAction func gotoTermOfUse(_ sender: Any) {
        
        if currentReachabilityStatus == .notReachable {
            self.showAlert()
            return
            
        }
        
        
        guard let url = URL(string:  termsOfUseValue) else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
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
                    self.timeLabel.text = self.formatSecondsToHHMMSS(seconds: newValue)
                }
                else {
                    
                  //  self.dismiss(animated: true)
                    
                }
                
                
            }
            
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
    
    
    @IBAction func gotoPrivacyPolicy(_ sender: Any) {
        
        if currentReachabilityStatus == .notReachable {
            self.showAlert()
            return
            
        }
        
        
        guard let url = URL(string:  privacyPolicyValue) else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    
    @IBAction func gotoManageSubscription(_ sender: Any) {
        
        if currentReachabilityStatus == .notReachable {
            self.showAlert()
            return
            
        }
        
        
        guard let url = URL(string:  managesub) else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBOutlet weak var gotoTermsOfUse: UILabel!
    
    
    func formatSecondsToHHMMSS(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    @IBAction func gotoPreviousView(_ sender: Any) {
        completeOnboarding?()
        
        if presentMainTabOnAnyAction {
            performSegue(withIdentifier: "onboardMainTabSegue", sender: nil)
        } else {
            self.dismiss(animated: true)
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

