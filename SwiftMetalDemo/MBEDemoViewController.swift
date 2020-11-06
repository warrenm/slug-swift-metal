//
//  MBEDemoViewController.swift
//  SwiftMetalDemo
//
//  Created by Warren Moore on 11/4/14.
//  Copyright (c) 2014—2020 Warren Moore. All rights reserved.
//

import UIKit
import Metal

class MBEDemoViewController : UIViewController {
    let metalLayer = CAMetalLayer()
    let device = MTLCreateSystemDefaultDevice()!
    var pipeline: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!

    var timer: CADisplayLink! = nil
    var userToggle: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        initializeMetal()
        buildPipeline()
        buildResources()
        startDisplayTimer()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        self.resize()
    }
    
    @objc func tapGesture() {
        userToggle = !userToggle
    }
    
    func initializeMetal() {
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        view.layer.addSublayer(metalLayer)

        commandQueue = device.makeCommandQueue()
    }
    
    func buildPipeline() {
    }
    
    func buildResources() {
    }
    
    func startDisplayTimer() {
        timer = CADisplayLink(target: self, selector: #selector(redraw))
        timer.add(to: .main, forMode: .default)
    }
    
    func resize() {
        if let window = view.window {
            let scale = window.screen.nativeScale
            let viewSize = view.bounds.size
            let layerSize = viewSize
            let layerOrigin = CGPoint(x: 0, y: 0)
            
            view.contentScaleFactor = scale
            metalLayer.frame = CGRect(x: layerOrigin.x, y: layerOrigin.y, width: layerSize.width, height: layerSize.height)
            metalLayer.drawableSize = CGSize(width: layerSize.width * scale, height: layerSize.height * scale)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    deinit {
        timer.invalidate()
    }
    
    @objc
    func redraw() {
        autoreleasepool {
            self.draw()
        }
    }
    
    func draw() {
    }
}
