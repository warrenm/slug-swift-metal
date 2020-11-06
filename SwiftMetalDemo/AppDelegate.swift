//
//  AppDelegate.swift
//  SwiftMetalDemo
//
//  Created by Warren Moore on 10/17/14.
//  Copyright (c) 2014—2020 Warren Moore. All rights reserved.
//

import UIKit

let MBEDemoNumber = 3

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootViewController: UIViewController!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
    {
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
        
        window = UIWindow(frame: UIScreen.main.bounds)
        rootViewController.view.frame = window!.bounds
        window!.rootViewController = rootViewController
        window!.makeKeyAndVisible()
        
        return true
    }
}
