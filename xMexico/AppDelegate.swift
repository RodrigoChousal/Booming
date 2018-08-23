//
//  AppDelegate.swift
//  xMexico
//
//  Created by Development on 2/12/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit
import Firebase

var userSignedIn = true

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        print("Application did finish launching")
        
        let credentials = KeychainManager.fetchCredentials()
        Auth.auth().signIn(withEmail: credentials.email, password: credentials.password) { (dataResult, error) in
            if let error = error { // No credentials
                print("First time signing in")
                print(error)
            } else { // Login successful
                // Store important user data
                if let fireUser = Auth.auth().currentUser {
                    Global.databaseRef.child("users").child(fireUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        let firstName = value?["firstName"] as? String ?? ""
                        let lastName = value?["lastName"] as? String ?? ""
                        let email = value?["email"] as? String ?? ""
                        Global.localUser = LocalUser(firstName: firstName,
                                                     lastName: lastName,
                                                     email: email,
                                                     profilePicture: ImageManager.fetchImageFromFirebase(forUser: fireUser))
                        
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                }
                
                userSignedIn = true
            }
        }
        
        // set common text attributes
//        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-light", size: 15)!], for: .normal)
//        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Cancelar"
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    }

}

