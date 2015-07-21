//
//  DemoTwo.metal
//  MetalSwift
//
//  Created by Warren Moore on 10/23/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

constant float3 lightDirection(0.577, 0.577, 0.577);

struct TexturedInVertex
{
    packed_float4 position [[attribute(0)]];
    packed_float4 normal [[attribute(1)]];
    packed_float2 texCoords [[attribute(2)]];
};

struct TexturedColoredOutVertex
{
    float4 position [[position]];
    float3 normal;
};

struct Uniforms
{
    float4x4 projectionMatrix;
    float4x4 modelViewMatrix;
};

vertex TexturedColoredOutVertex vertex_demo_two(device TexturedInVertex *vert [[buffer(0)]],
                                                           constant Uniforms &uniforms [[buffer(1)]],
                                                           uint vid [[vertex_id]])
{
    float4x4 MV = uniforms.modelViewMatrix;
    float3x3 normalMatrix(MV[0].xyz, MV[1].xyz, MV[2].xyz);
    float4 modelNormal = vert[vid].normal;
    
    TexturedColoredOutVertex outVertex;
    outVertex.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * float4(vert[vid].position);
    outVertex.normal = normalMatrix * modelNormal.xyz;
    
    return outVertex;
}

fragment half4 fragment_demo_two(TexturedColoredOutVertex vert [[stage_in]])
{
    float diffuseIntensity = saturate(dot(normalize(vert.normal), lightDirection));
    return half4(diffuseIntensity, diffuseIntensity, diffuseIntensity, 1);
}
