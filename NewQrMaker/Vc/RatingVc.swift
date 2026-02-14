//
//  RatingVc.swift
//  NovelAINew
//
//  Created by Sadiqul AMin on 27/11/25.
//

import UIKit

class RatingVc: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.incrementRateCounter()
        

        // Do any additional setup after loading the view.
    }
    

    @IBAction func rateApp(_ sender: Any) {
        self.dismiss(animated: true) {
            
            self.incrementRateCounter()
            let appID = "6480269610"
               if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
               }
        }
        
        
    }
    
    func incrementRateCounter() {
        let current = UserDefaults.standard.integer(forKey: "rate_press_count")
        UserDefaults.standard.set(current + 1, forKey: "rate_press_count")
    }
    
    
    @IBAction func dismiissView(_ sender: Any) {
        self.dismiss(animated:  true)
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
