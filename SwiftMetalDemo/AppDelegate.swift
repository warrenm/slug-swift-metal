//
//  AppDelegate.swift
//  SwiftMetalDemo
//
//  Created by Warren Moore on 10/17/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

import UIKit

let MBEDemoNumber = 3

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow!
    var rootViewController: UIViewController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        switch MBEDemoNumber
        {
            case 0:
                rootViewController = MBEDemoZeroViewController()
            case 1:
                rootViewController = MBEDemoOneViewController()
            case 2:
                rootViewController = MBEDemoTwoViewController()
            case 3:
                rootViewController = MBEDemoThreeViewController()
            default:
                break
        }
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        rootViewController.view.frame = window.bounds
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
        return true
    }
}
