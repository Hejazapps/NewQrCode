import UIKit
import Foundation
import AVFoundation

 
class MainTabVc: UITabBarController, UITabBarControllerDelegate {

    let titles = ["Home", "Template", "Scan", "Drafts"]
    var isProfileSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        setupTabBarItems()
        
        NotificationCenter.default.addObserver(self, selector:#selector(reloadData5(notification:)), name:NSNotification.Name(rawValue: "kishor"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(reloadData4(notification:)), name:NSNotification.Name(rawValue: "sadiqul"), object: nil)
        
        
        

       
    }

  
    
    @objc func reloadData5(notification: NSNotification) {
        
        if notification.name == NSNotification.Name(rawValue: "kishor"){
            self.selectedIndex = 1
           // Store.sharedInstance.setShowHistoryPage(value: false)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kishor1"), object: nil)
           
            self.tabBar.isHidden = false
        }

        
    }
    
    @objc func reloadData4(notification: NSNotification) {
        
        if notification.name == NSNotification.Name(rawValue: "sadiqul"){
            self.selectedIndex = 0
            self.tabBar.isHidden = false
            
        }

        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
           // Hide tab bar if index 2 (Scan) is selected
           if let index = viewControllers?.firstIndex(of: viewController), index == 2 {
               tabBar.isHidden = true
           } else {
               tabBar.isHidden = false
           }
       }
    
    // MARK: - Tab Items
    private func setupTabBarItems() {

        guard let vcs = viewControllers, vcs.count == titles.count else {
            print("Warning: Tab count mismatch. Expected \(titles.count), got \(viewControllers?.count ?? 0)")
            return
        }

        for (index, title) in titles.enumerated() {

            let normalIconName = title
            let selectedIconName = title + "s"

            let normalImage = UIImage(named: normalIconName)?
                .withRenderingMode(.alwaysOriginal)

            let selectedImage = UIImage(named: selectedIconName)?
                .withRenderingMode(.alwaysOriginal)

            vcs[index].tabBarItem = UITabBarItem(
                title: title.localize(),
                image: normalImage,
                selectedImage: selectedImage
            )
        }
    }

    // MARK: - Appearance
}

