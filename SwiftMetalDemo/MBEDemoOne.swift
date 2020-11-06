//
//  MBEDemoOne.swift
//  SwiftMetalDemo
//
//  Created by Warren Moore on 10/23/14.
//  Copyright (c) 2014—2020 Warren Moore. All rights reserved.
//

import UIKit

class MBEDemoOneViewController : MBEDemoViewController {
    private var vertexBuffer: MTLBuffer!
    private var uniformBuffer: MTLBuffer!
    private var rotationAngle: Float = 0.0

    override func buildPipeline() {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_demo_one")
        let fragmentFunction = library?.makeFunction(name: "fragment_demo_one")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].offset = MemoryLayout<ColorRGBA>.stride
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0

        vertexDescriptor.layouts[0].stepFunction = .perVertex
        vertexDescriptor.layouts[0].stride = MemoryLayout<ColoredVertex>.stride

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipeline = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        commandQueue = device.makeCommandQueue()
    }
    
    override func buildResources() {
        let vertices: [ColoredVertex] = [ ColoredVertex(position:Vector4(x:  0.000, y:  0.50, z: 0, w: 1),
                                                        color:ColorRGBA(r: 1, g: 0, b: 0, a: 1)),
                                          ColoredVertex(position:Vector4(x: -0.433, y: -0.25, z: 0, w: 1),
                                                        color:ColorRGBA(r: 0, g: 1, b: 0, a: 1)),
                                          ColoredVertex(position:Vector4(x:  0.433, y: -0.25, z: 0, w: 1),
                                                        color:ColorRGBA(r: 0, g: 0, b: 1, a: 1))]

        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<ColoredVertex>.stride * 3,
                                         options:[])
        
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Matrix4x4>.stride, options:[])
    }

    // this override of resize shapes the Metal layer into a square and centers it in the containing view
    override func resize() {
        if let window = view.window {
            let scale = window.screen.nativeScale
            let viewSize = view.bounds.size
            let minSize = min(viewSize.width, viewSize.height)
            let layerSize = CGSize(width: minSize, height: minSize)
            let layerOrigin = CGPoint(x: (viewSize.width - layerSize.width) * 0.5,
                                      y: (viewSize.height - layerSize.height) * 0.5)
            
            view.contentScaleFactor = scale
            metalLayer.frame = CGRect(x: layerOrigin.x, y: layerOrigin.y, width: layerSize.width, height: layerSize.height)
            metalLayer.drawableSize = CGSize(width: layerSize.width * scale, height: layerSize.height * scale)
        }
    }

    override func draw() {
        if let drawable = metalLayer.nextDrawable() {
            let passDescriptor = MTLRenderPassDescriptor()
            passDescriptor.colorAttachments[0].texture = drawable.texture
            passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
            passDescriptor.colorAttachments[0].loadAction = .clear
            passDescriptor.colorAttachments[0].storeAction = .store

            let zAxis = Vector4(x: 0, y: 0, z: -1, w: 0)
            var rotationMatrix = [Matrix4x4.rotation(about: zAxis, by: rotationAngle)]
            memcpy(uniformBuffer.contents(), &rotationMatrix, MemoryLayout<Matrix4x4>.size)
            
            let commandBuffer = commandQueue.makeCommandBuffer()!

            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)!
            commandEncoder.setRenderPipelineState(pipeline)
            commandEncoder.setFrontFacing(.counterClockwise)
            commandEncoder.setCullMode(.back)
            commandEncoder.setVertexBuffer(vertexBuffer, offset:0, index:0)
            commandEncoder.setVertexBuffer(uniformBuffer, offset:0, index:1)
            commandEncoder.drawPrimitives(type: .triangle, vertexStart:0, vertexCount:3)
            
            commandEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
            
            rotationAngle += 0.01
        }
    }
}

