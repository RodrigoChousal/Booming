//
//  AppDelegate.swift
//  xMexico
//
//  Created by Development on 2/12/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		delayPresentation()
		
		setupFirebase()
		
        let credentials = KeychainManager.fetchCredentials()
		
        Auth.auth().signIn(withEmail: credentials.email, password: credentials.password) { (dataResult, error) in

            if let error = error { // No credentials
                print("Credentials are not valid, first time signing in...")
                print(error)
                
                // Show user to AccessVC without automatic access
                self.grantAccess(newUser: true)
                
            } else { // Login successful
                print("Returning user has been successfully signed in to Firebase")
                 
                // Store important user data
                if let fireUser = Auth.auth().currentUser {
					SessionManager.populateLocalUser(withFireUser: fireUser)
                }
                
                // Show user to AccessVC with automatic access
				self.grantAccess(newUser: false)
            }
        }
		
		setupSystemStyles()
        
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
	
	// MARK: - Helper Methods
	
	func setupFirebase() {
		FirebaseApp.configure()
		let db = Firestore.firestore()
		let settings = db.settings
		settings.areTimestampsInSnapshotsEnabled = true
		db.settings = settings
	}
	
	func delayPresentation() {
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
		window?.makeKeyAndVisible()
	}
	
	func grantAccess(newUser: Bool) {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let accessVC = mainStoryboard.instantiateViewController(withIdentifier: "AccessViewController") as! AccessViewController
		self.window?.rootViewController = accessVC
		accessVC.view.hide(duration: 1.0)
		if !newUser {
			Global.returningAccess = true
			accessVC.performSegue(withIdentifier: "AccessGrantedNoAnimation", sender: self)
		}
	}
	
	func setupSystemStyles() {
		let attributes = [NSAttributedStringKey.foregroundColor: UIColor.black,
						  NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!]
		UINavigationBar.appearance().titleTextAttributes = attributes
	}
}

