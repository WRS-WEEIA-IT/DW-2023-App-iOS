//
//  AppDelegate.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 17/02/2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        FirebaseApp.configure()
        //Messaging.messaging().delegate = self
        
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


}

