//
//  MBEDemoZero.swift
//  SwiftMetalDemo
//
//  Created by Warren Moore on 10/23/14.
//  Copyright (c) 2014—2020 Warren Moore. All rights reserved.
//

import UIKit

class MBEDemoZeroViewController : MBEDemoViewController {
    override func resize() {
        if let window = view.window {
            let scale = window.screen.nativeScale
            let bounds = view.bounds
            let size = bounds.size
            
            view.contentScaleFactor = scale

            metalLayer.frame = bounds
            metalLayer.drawableSize = CGSize(width: size.width * scale, height: size.height * scale)
        }
    }
    
    override func draw() {
        if let drawable = metalLayer.nextDrawable() {
            let passDescriptor = MTLRenderPassDescriptor()
            passDescriptor.colorAttachments[0].texture = drawable.texture
            passDescriptor.colorAttachments[0].loadAction = .clear
            passDescriptor.colorAttachments[0].storeAction = .store
            passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
            
            guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
            
            if let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) {
                commandEncoder.endEncoding()
            }
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

