//
//  DemoThree.metal
//  MetalSwift
//
//  Created by Warren Moore on 10/23/14.
//  Copyright (c) 2014—2020 Warren Moore. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct TexturedInVertex {
    float4 position  [[attribute(0)]];
    float4 normal    [[attribute(1)]];
    float2 texCoords [[attribute(2)]];
};

struct TexturedColoredOutVertex {
    float4 position [[position]];
    float3 normal;
    float2 texCoords;
};

struct Uniforms {
    float4x4 projectionMatrix;
    float4x4 modelViewMatrix;
};

vertex TexturedColoredOutVertex vertex_demo_three(TexturedInVertex vert [[stage_in]],
                                                  constant Uniforms &uniforms [[buffer(1)]])
{
    float4x4 MV = uniforms.modelViewMatrix;
    float3x3 normalMatrix(MV[0].xyz, MV[1].xyz, MV[2].xyz);
    float4 modelNormal = vert.normal;
    
    TexturedColoredOutVertex outVertex;
    outVertex.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * vert.position;
    outVertex.normal = normalMatrix * modelNormal.xyz;
    outVertex.texCoords = vert.texCoords;
    
    return outVertex;
}

fragment half4 fragment_demo_three(TexturedColoredOutVertex vert [[stage_in]],
                                   texture2d<float, access::sample> diffuseTexture [[texture(0)]],
                                   sampler samplr [[sampler(0)]])
{
    float4 diffuseColor = diffuseTexture.sample(samplr, vert.texCoords);
    return half4(diffuseColor.r, diffuseColor.g, diffuseColor.b, 1);
}
