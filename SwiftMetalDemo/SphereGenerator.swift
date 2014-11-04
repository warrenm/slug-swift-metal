//
//  SphereGenerator.swift
//  SwiftMetalDemo
//
//  Created by Warren Moore on 11/4/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

import Metal

struct SphereGenerator
{
    static func sphereWithRadius(radius: Float32, stacks: Int, slices: Int, device: MTLDevice) -> (MTLBuffer!, MTLBuffer!)
    {
        let pi = Float32(M_PI)
        let twoPi = pi * 2
        let deltaPhi = pi / Float32(stacks)
        let deltaTheta = twoPi / Float32(slices)
        
        var vertices = [Vertex]()
        var indices = [UInt16]()
        var index:UInt16 = 0
        var phi = Float32(-M_PI / 2)
        for stack in 0...stacks
        {
            var theta:Float32 = 0
            for slice in 0...slices
            {
                let x = cos(theta) * cos(phi)
                let y = sin(phi)
                let z = sin(theta) * cos(phi)
                
                let position = Vector4(x: radius * x, y: radius * y, z: radius * z, w: 1)
                let normal = Vector4(x: x, y: y, z: z, w: 0)
                let texCoords = TexCoords(u: 1 - Float32(slice) / Float32(slices), v: 1 - (sin(phi) + 1) * 0.5)
                
                let vertex = Vertex(position: position, normal: normal, texCoords: texCoords)
                
                vertices.append(vertex)
                
                theta += deltaTheta
            }
            
            phi += deltaPhi
        }
        
        for stack in 0..<stacks
        {
            for slice in 0..<slices
            {
                var i0 = UInt16(slice + stack * slices)
                var i1 = i0 + 1
                var i2 = i0 + slices
                var i3 = i2 + 1
                
                indices.append(i0)
                indices.append(i2)
                indices.append(i3)
                
                indices.append(i0)
                indices.append(i3)
                indices.append(i1)
            }
        }
        
        let vertexBuffer = device.newBufferWithBytes(vertices, length:sizeof(Vertex) * vertices.count, options:.OptionCPUCacheModeDefault)
        
        let indexBuffer = device.newBufferWithBytes(indices, length:sizeof(UInt16) * indices.count, options:.OptionCPUCacheModeDefault)
        
        return (vertexBuffer, indexBuffer)
    }
}
