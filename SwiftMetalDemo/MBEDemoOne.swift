//
//  MBEDemoOne.swift
//  SwiftMetalDemo
//
//  Created by Warren Moore on 10/23/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

import UIKit

class MBEDemoOneViewController : MBEDemoViewController {
    var vertexBuffer: MTLBuffer! = nil
    var uniformBuffer: MTLBuffer! = nil
    var rotationAngle: Float32 = 0.0

    override func buildPipeline() {
        let library = device.newDefaultLibrary()!
        let vertexFunction = library.newFunctionWithName("vertex_demo_one")
        let fragmentFunction = library.newFunctionWithName("fragment_demo_one")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = .Float4
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].offset = sizeof(ColorRGBA)
        vertexDescriptor.attributes[1].format = .Float4
        vertexDescriptor.attributes[1].bufferIndex = 0

        vertexDescriptor.layouts[0].stepFunction = .PerVertex
        vertexDescriptor.layouts[0].stride = sizeof(ColoredVertex)

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        pipeline = device.newRenderPipelineStateWithDescriptor(pipelineDescriptor, error: nil)

        commandQueue = device.newCommandQueue()
    }
    
    override func buildResources() {
        let vertices: [ColoredVertex] = [ ColoredVertex(position:Vector4(x:  0.000, y:  0.50, z: 0, w: 1),
                                                        color:ColorRGBA(r: 1, g: 0, b: 0, a: 1)),
                                          ColoredVertex(position:Vector4(x: -0.433, y: -0.25, z: 0, w: 1),
                                                        color:ColorRGBA(r: 0, g: 1, b: 0, a: 1)),
                                          ColoredVertex(position:Vector4(x:  0.433, y: -0.25, z: 0, w: 1),
                                                        color:ColorRGBA(r: 0, g: 0, b: 1, a: 1))]

        vertexBuffer = device.newBufferWithBytes(vertices, length: sizeof(ColoredVertex) * 3, options:.OptionCPUCacheModeDefault)
        
        uniformBuffer = device.newBufferWithLength(sizeof(Matrix4x4), options:.OptionCPUCacheModeDefault)
    }

    // this override of resize shapes the Metal layer into a square and centers it in the containing view
    override func resize() {
        if let window = view.window {
            let scale = window.screen.nativeScale
            let viewSize = view.bounds.size
            let minSize = min(viewSize.width, viewSize.height)
            let layerSize = CGSizeMake(minSize, minSize)
            let layerOrigin = CGPointMake((viewSize.width - layerSize.width) * 0.5, (viewSize.height - layerSize.height) * 0.5)
            
            view.contentScaleFactor = scale
            metalLayer.frame = CGRectMake(layerOrigin.x, layerOrigin.y, layerSize.width, layerSize.height)
            metalLayer.drawableSize = CGSizeMake(layerSize.width * scale, layerSize.height * scale)
        }
    }

    override func draw() {
        if let drawable = metalLayer.nextDrawable() {
            let passDescriptor = MTLRenderPassDescriptor()
            passDescriptor.colorAttachments[0].texture = drawable.texture
            passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
            passDescriptor.colorAttachments[0].loadAction = .Clear
            passDescriptor.colorAttachments[0].storeAction = .Store

            let zAxis = Vector4(x: 0, y: 0, z: -1, w: 0)
            let rotationMatrix = [Matrix4x4.rotationAboutAxis(zAxis, byAngle: rotationAngle)]
            memcpy(uniformBuffer.contents(), rotationMatrix, sizeof(Matrix4x4))
            
            let commandBuffer = commandQueue.commandBuffer()

            let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(passDescriptor)!
            commandEncoder.setRenderPipelineState(pipeline)
            commandEncoder.setFrontFacingWinding(.CounterClockwise)
            commandEncoder.setCullMode(.Back)
            commandEncoder.setVertexBuffer(vertexBuffer, offset:0, atIndex:0)
            commandEncoder.setVertexBuffer(uniformBuffer, offset:0, atIndex:1)
            commandEncoder.drawPrimitives(.Triangle, vertexStart:0, vertexCount:3)
            
            commandEncoder.endEncoding()
            
            commandBuffer.presentDrawable(drawable)
            commandBuffer.commit()
            
            rotationAngle += 0.01
        }
    }
}

