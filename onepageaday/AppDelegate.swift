//
//  AppDelegate.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/08.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    func applicationWillTerminate(_ application: UIApplication) {
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(API.currentQuestions) {
//            let defaults = UserDefaults.standard
//            defaults.set(encoded, forKey: "Questions")
//        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //if nonpro
        //Firestore.firestore().disableNetwork(completion: nil)
        
//        let defaults = UserDefaults.standard
//        if let questions = defaults.object(forKey: "Questions") as? Data {
//            let decoder = JSONDecoder()
//            if let questions = try? decoder.decode([Question].self, from: questions) {
//                API.currentQuestions = questions
//                print(questions)
//            }
//        }
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

