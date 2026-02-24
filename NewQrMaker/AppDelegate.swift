//
//  AppDelegate.swift
//  NewQrMaker
//
//  Created by Sadiqul AMin on 7/2/26.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.loadData()
        FirebaseApp.configure()
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func stringByAppendingPathComponent(fileName: String) -> String {
        
        let path = Bundle.main.path(forResource: "Fonts", ofType: "")
        let nsSt = path! as NSString
        return nsSt.appendingPathComponent(fileName)
    }
    
    func loadData()
    {
        
        do {
            let path = Bundle.main.path(forResource: "Fonts", ofType: "")
            let fileList = try FileManager.default.contentsOfDirectory(atPath: path!)
            
            for item in fileList {
                
                let fileName :NSString!
                fileName = (item as NSString)
                NSLog("sadiqul amin %@", fileName)
                let writePath = self.stringByAppendingPathComponent(fileName: fileName as String)
                self.registerFontWith(path: writePath)
            }
            
            
        } catch {
            //handle error
            print(error)
        }
        arrayForFont = NSArray.init(array: fontArray)
       // Store.sharedInstance.setfontArray(array: arrayForFont)
        //Store.sharedInstance.setFontName(name: arrayForFont![0] as! NSString)
        
        
    }
    
    func registerFontWith(path: String) {
        if let fontData = NSData(contentsOfFile: path), let dataProvider = CGDataProvider.init(data: fontData) {
            
            
            let fontRef = CGFont.init(dataProvider)
            var errorRef: Unmanaged<CFError>? = nil
            if (CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false) {
                print("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
            }
            let fontName = fontRef!.postScriptName
            let name:NSString = NSString(string:fontName!)
            fontArray.append(name as String)
            NSLog("%@", name)
        }
        
    }


}

