//
//  MBEDemoViewController.swift
//  SwiftMetalDemo
//
//  Created by Warren Moore on 11/4/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

import UIKit
import Metal

class MBEDemoViewController : UIViewController {
    let metalLayer = CAMetalLayer()
    let device = MTLCreateSystemDefaultDevice()
    var pipeline: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil

    var timer: CADisplayLink! = nil
    var userToggle: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        initializeMetal()
        buildPipeline()
        buildResources()
        startDisplayTimer()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapGesture"))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        self.resize()
    }
    
    func tapGesture() {
        userToggle = !userToggle
    }
    
    func initializeMetal() {
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        view.layer.addSublayer(metalLayer)

        commandQueue = device.newCommandQueue()
    }
    
    func buildPipeline() {
    }
    
    func buildResources() {
    }
    
    func startDisplayTimer() {
        timer = CADisplayLink(target: self, selector: Selector("redraw"))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func resize() {
        if let window = view.window {
            let scale = window.screen.nativeScale
            let viewSize = view.bounds.size
            let layerSize = viewSize
            let layerOrigin = CGPointMake(0, 0)
            
            view.contentScaleFactor = scale
            metalLayer.frame = CGRectMake(layerOrigin.x, layerOrigin.y, layerSize.width, layerSize.height)
            metalLayer.drawableSize = CGSizeMake(layerSize.width * scale, layerSize.height * scale)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit {
        timer.invalidate()
    }
    
    func redraw() {
        autoreleasepool {
            self.draw()
        }
    }
    
    func draw() {
    }
}
