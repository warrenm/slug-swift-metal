//
//  MBEDemoZero.swift
//  SwiftMetalDemo
//
//  Created by Warren Moore on 10/23/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
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
            metalLayer.drawableSize = CGSizeMake(size.width * scale, size.height * scale)
        }
    }
    
    override func draw() {
        if let drawable = metalLayer.nextDrawable() {
            let passDescriptor = MTLRenderPassDescriptor()
            passDescriptor.colorAttachments[0].texture = drawable.texture
            passDescriptor.colorAttachments[0].loadAction = .Clear
            passDescriptor.colorAttachments[0].storeAction = .Store
            passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.8, 0.0, 0.0, 1.0)
            
            let commandBuffer = commandQueue.commandBuffer()
            
            let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(passDescriptor)!

            commandEncoder.endEncoding()
            
            commandBuffer.presentDrawable(drawable)
            commandBuffer.commit()
        }
    }
}

