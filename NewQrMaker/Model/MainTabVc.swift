import UIKit
import Foundation
import AVFoundation

 
class MainTabVc: UITabBarController, UITabBarControllerDelegate {

    let titles = ["Home", "Template", "Scan", "Drafts","Settings"]
    var isProfileSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        setupTabBarItems()

       
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



extension String{
    func localize() -> String{
        return NSLocalizedString(self, comment: "ANYTHING")
    }
}
