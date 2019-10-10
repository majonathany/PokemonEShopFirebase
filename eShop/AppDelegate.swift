//
//  AppDelegate.swift
//  eShop
//
//  Created by Jonathan Ma on 8/21/17.
//  Copyright © 2017 majonathany. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    FirebaseApp.configure()
    
    return true
  }
  
  
}

