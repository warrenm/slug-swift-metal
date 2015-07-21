//
//  MBEDemoTwo.swift
//  SwiftMetalDemo
//
//  Created by Warren Moore on 10/23/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

import UIKit

class MBEDemoTwoViewController : MBEDemoViewController {
    var depthStencilState: MTLDepthStencilState! = nil
    var vertexBuffer: MTLBuffer! = nil
    var indexBuffer: MTLBuffer! = nil
    var uniformBuffer: MTLBuffer! = nil
    var depthTexture: MTLTexture! = nil
    var rotationAngle: Float32 = 0

    override func buildPipeline() {
        let library = device.newDefaultLibrary()!
        let fragmentFunction = library.newFunctionWithName("fragment_demo_two")
        let vertexFunction = library.newFunctionWithName("vertex_demo_two")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = .Float4
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].offset = sizeof(Float32) * 4
        vertexDescriptor.attributes[1].format = .Float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.attributes[2].offset = sizeof(Float32) * 8
        vertexDescriptor.attributes[2].format = .Float2
        vertexDescriptor.attributes[2].bufferIndex = 0

        vertexDescriptor.layouts[0].stepFunction = .PerVertex
        vertexDescriptor.layouts[0].stride = sizeof(Vertex)

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .Depth32Float
        
        var error: NSErrorPointer = nil
        pipeline = device.newRenderPipelineStateWithDescriptor(pipelineDescriptor, error:error)
        if (pipeline == nil) {
            print("Error occurred when creating pipeline \(error)")
        }
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .Less
        depthStencilDescriptor.depthWriteEnabled = true
        depthStencilState = device.newDepthStencilStateWithDescriptor(depthStencilDescriptor)

        commandQueue = device.newCommandQueue()
    }

    override func buildResources() {
        (vertexBuffer, indexBuffer) = SphereGenerator.sphereWithRadius(1, stacks: 10, slices: 10, device: device)

        uniformBuffer = device.newBufferWithLength(sizeof(Matrix4x4) * 2, options: .OptionCPUCacheModeDefault)
    }
    
    override func resize() {
        super.resize()
        
        let layerSize = metalLayer.drawableSize
        var depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.Depth32Float,
            width: Int(layerSize.width),
            height: Int(layerSize.height),
            mipmapped: false)
        depthTexture = device.newTextureWithDescriptor(depthTextureDescriptor)
    }

    override func draw() {
        if let drawable = metalLayer.nextDrawable() {
            let yAxis = Vector4(x: 0, y: -1, z: 0, w: 0)
            var modelViewMatrix = Matrix4x4.rotationAboutAxis(yAxis, byAngle: rotationAngle)
            
            modelViewMatrix.W.z = -2

            let aspect = Float32(metalLayer.drawableSize.width) / Float32(metalLayer.drawableSize.height)

            let projectionMatrix = Matrix4x4.perspectiveProjection(aspect, fieldOfViewY: 60, near: 0.1, far: 100.0)
            
            let matrices = [projectionMatrix, modelViewMatrix]
            memcpy(uniformBuffer.contents(), matrices, sizeof(Matrix4x4) * 2)

            let commandBuffer = commandQueue.commandBuffer()

            let passDescriptor = MTLRenderPassDescriptor()
            passDescriptor.colorAttachments[0].texture = drawable.texture
            passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1)
            passDescriptor.colorAttachments[0].loadAction = .Clear
            passDescriptor.colorAttachments[0].storeAction = .Store
            
            passDescriptor.depthAttachment.texture = depthTexture
            passDescriptor.depthAttachment.clearDepth = 1
            passDescriptor.depthAttachment.loadAction = .Clear
            passDescriptor.depthAttachment.storeAction = .DontCare
            
            let indexCount = indexBuffer.length / sizeof(UInt16)
            let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(passDescriptor)!
            if userToggle {
                commandEncoder.setTriangleFillMode(.Lines)
            }
            commandEncoder.setRenderPipelineState(pipeline)
            commandEncoder.setDepthStencilState(depthStencilState)
            commandEncoder.setFrontFacingWinding(.CounterClockwise)
            commandEncoder.setCullMode(.Back)
            commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
            commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, atIndex: 1)
            commandEncoder.drawIndexedPrimitives(.Triangle,
                                                 indexCount: indexCount,
                                                 indexType: .UInt16,
                                                 indexBuffer: indexBuffer,
                                                 indexBufferOffset: 0)
            
            commandEncoder.endEncoding()
            
            commandBuffer.presentDrawable(drawable)
            commandBuffer.commit()
            
            rotationAngle += 0.01
        }
    }
}

