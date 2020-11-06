//
//  MBEDemoTwo.swift
//  SwiftMetalDemo
//
//  Created by Warren Moore on 10/23/14.
//  Copyright (c) 2014—2020 Warren Moore. All rights reserved.
//

import UIKit

class MBEDemoTwoViewController : MBEDemoViewController {
    var depthStencilState: MTLDepthStencilState!
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    var uniformBuffer: MTLBuffer!
    var depthTexture: MTLTexture!
    var rotationAngle: Float = 0

    override func buildPipeline() {
        let library = device.makeDefaultLibrary()
        let fragmentFunction = library?.makeFunction(name: "fragment_demo_two")
        let vertexFunction = library?.makeFunction(name: "vertex_demo_two")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.stride * 4
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.attributes[2].offset = MemoryLayout<Float>.stride * 8
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].bufferIndex = 0

        vertexDescriptor.layouts[0].stepFunction = .perVertex
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        do {
            pipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Error occurred when creating pipeline \(error)")
        }
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        commandQueue = device.makeCommandQueue()
    }

    override func buildResources() {
        (vertexBuffer, indexBuffer) = SphereGenerator.makeSphere(radius: 1, stacks: 10, slices: 10, device: device)

        uniformBuffer = device.makeBuffer(length: MemoryLayout<Matrix4x4>.stride * 2, options: [])
    }
    
    override func resize() {
        super.resize()
        
        let layerSize = metalLayer.drawableSize
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float,
                                                                              width: Int(layerSize.width),
                                                                              height: Int(layerSize.height),
                                                                              mipmapped: false)
        depthTextureDescriptor.storageMode = .private
        depthTextureDescriptor.usage = .renderTarget
        depthTexture = device.makeTexture(descriptor: depthTextureDescriptor)
    }

    override func draw() {
        if let drawable = metalLayer.nextDrawable() {
            let yAxis = Vector4(x: 0, y: -1, z: 0, w: 0)
            var modelViewMatrix = Matrix4x4.rotation(about: yAxis, by: rotationAngle)
            
            modelViewMatrix.W.z = -2

            let aspect = Float(metalLayer.drawableSize.width) / Float(metalLayer.drawableSize.height)

            let projectionMatrix = Matrix4x4.perspectiveProjection(aspect: aspect, fieldOfViewY: 60, near: 0.1, far: 100.0)
            
            let matrices = [projectionMatrix, modelViewMatrix]
            memcpy(uniformBuffer.contents(), matrices, MemoryLayout<Matrix4x4>.stride * 2)

            guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }

            let passDescriptor = MTLRenderPassDescriptor()
            passDescriptor.colorAttachments[0].texture = drawable.texture
            passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
            passDescriptor.colorAttachments[0].loadAction = .clear
            passDescriptor.colorAttachments[0].storeAction = .store
            
            passDescriptor.depthAttachment.texture = depthTexture
            passDescriptor.depthAttachment.clearDepth = 1
            passDescriptor.depthAttachment.loadAction = .clear
            passDescriptor.depthAttachment.storeAction = .dontCare
            
            let indexCount = indexBuffer.length / MemoryLayout<UInt16>.size
            if let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) {
                if userToggle {
                    commandEncoder.setTriangleFillMode(.lines)
                }
                commandEncoder.setRenderPipelineState(pipeline)
                commandEncoder.setDepthStencilState(depthStencilState)
                commandEncoder.setFrontFacing(.counterClockwise)
                commandEncoder.setCullMode(.back)
                commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                commandEncoder.drawIndexedPrimitives(type: .triangle,
                                                     indexCount: indexCount,
                                                     indexType: .uint16,
                                                     indexBuffer: indexBuffer,
                                                     indexBufferOffset: 0)
                
                commandEncoder.endEncoding()
            }
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
            
            rotationAngle += 0.01
        }
    }
}

