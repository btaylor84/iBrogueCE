//
//  Main.swift
//  iBrogueCE_iPad
//
//  Created by Robert Taylor on 4/28/22.
//  Copyright © 2022 Seth howard. All rights reserved.
//

import SwiftUI
import UIKit


//@main
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    var window: UIWindow?
//
//    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions:     NSDictionary?) -> Bool {
//        // Override point for customization after application launch.
//
//        return true
//    }
//
@main
struct BrogueApp: App {
    var body: some Scene {
        WindowGroup {
            BrogueView()
        }
    }
}

