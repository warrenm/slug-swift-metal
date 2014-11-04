//
//  Demo.metal
//  MetalSwift
//
//  Created by Warren Moore on 10/23/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct ColoredInVertex
{
    packed_float4 position [[attribute(0)]];
    packed_float4 color [[attribute(1)]];
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

vertex ColoredOutVertex vertex_demo_one(device ColoredInVertex *vert [[buffer(0)]],
                                        constant Uniforms &uniforms [[buffer(1)]],
                                        uint vid [[vertex_id]])
{
    ColoredOutVertex outVertex;
    outVertex.position = uniforms.rotation_matrix * float4(vert[vid].position);
    outVertex.color = vert[vid].color;
    return outVertex;
}

fragment half4 fragment_demo_one(ColoredOutVertex inFrag [[stage_in]])
{
    return half4(inFrag.color);
}
