//
//  AppDelegate.swift
//  OFOBike
//
//  Created by kingcos on 11/08/2017.
//  Copyright © 2017 kingcos. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Setup Fabric - Crashlytics & Answers
        Fabric.with([Crashlytics.self])
        Fabric.with([Answers.self])
        
        // Setup A Map
        AMapServices.shared().apiKey = "YOUR_API_KEY"
        AMapServices.shared().enableHTTPS = true
        
        return true
    }

}

