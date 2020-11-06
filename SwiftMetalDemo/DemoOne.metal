//
//  Demo.metal
//  MetalSwift
//
//  Created by Warren Moore on 10/23/14.
//  Copyright (c) 2014—2020 Warren Moore. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct ColoredInVertex {
    float4 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct ColoredOutVertex
{
    float4  position [[position]];
    float4  color;
};

struct Uniforms
{
    float4x4 rotation_matrix;
};

vertex ColoredOutVertex vertex_demo_one(ColoredInVertex vert [[stage_in]],
                                        constant Uniforms &uniforms [[buffer(1)]],
                                        uint vid [[vertex_id]])
{
    ColoredOutVertex outVertex;
    outVertex.position = uniforms.rotation_matrix * vert.position;
    outVertex.color = vert.color;
    return outVertex;
}

fragment half4 fragment_demo_one(ColoredOutVertex inFrag [[stage_in]])
{
    return half4(inFrag.color);
}
