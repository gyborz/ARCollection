//
//  Feature3_shaders.metal
//  ARCollection
//
//  Created by Gyorgy Borz on 2022. 09. 25..
//

#include <metal_stdlib>

using namespace metal;

struct Feature3_ImageVertex {
    float2 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct Feature3_TexturedQuadVertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Feature3_FrameUniforms {
    float4x4 projectionMatrix;
    float4x4 viewMatrix;
};

struct Feature3_InstanceUniforms {
    float4x4 modelMatrix;
};

vertex Feature3_TexturedQuadVertexOut Feature3_cameraVertexTransform(Feature3_ImageVertex in [[stage_in]]) {
    Feature3_TexturedQuadVertexOut out;
    out.position = float4(in.position, 0.0, 1.0);
    out.texCoord = in.texCoord;
    return out;
}

fragment float4 Feature3_cameraFragmentShader(Feature3_TexturedQuadVertexOut in [[stage_in]],
                                     texture2d<float, access::sample> cameraTextureY [[ texture(1) ]],
                                     texture2d<float, access::sample> cameraTextureCbCr [[ texture(2) ]])
{

    constexpr sampler colorSampler(filter::linear);

    const float4x4 ycbcrToRGBTransform = float4x4(
                                                  float4( 1.0000f,  1.0000f,  1.0000f, 0.0000f),
                                                  float4( 0.0000f, -0.3441f,  1.7720f, 0.0000f),
                                                  float4( 1.4020f, -0.7141f,  0.0000f, 0.0000f),
                                                  float4(-0.7010f,  0.5291f, -0.8860f, 1.0000f)
                                                  );

    float4 ycbcr = float4(cameraTextureY.sample(colorSampler, in.texCoord).r,
                          cameraTextureCbCr.sample(colorSampler, in.texCoord).rg, 1.0);
    return ycbcrToRGBTransform * ycbcr;
}

struct Feature3_Vertex {
    float3 position [[attribute(0)]];
    float3 normal   [[attribute(1)]];
};

struct Feature3_VertexOut {
    float4 position [[position]];
    float4 color;
    float3 eyePosition;
    float3 normal;
};

vertex Feature3_VertexOut Feature3_anchorGeometryVertexTransform(Feature3_Vertex in [[stage_in]],
                                                         constant Feature3_FrameUniforms &uniforms [[ buffer(3) ]],
                                                         constant Feature3_InstanceUniforms *instanceUniforms [[ buffer(2) ]],
                                                         uint vid [[vertex_id]],
                                                         uint iid [[instance_id]]) {
    Feature3_VertexOut out;

    float4 position = float4(in.position, 1.0);

    float4x4 modelMatrix = instanceUniforms[iid].modelMatrix;
    float4x4 modelViewMatrix = uniforms.viewMatrix * modelMatrix;

    out.position = uniforms.projectionMatrix * modelViewMatrix * position;

    out.eyePosition = (modelViewMatrix * position).xyz;

    float4 normal = modelMatrix * float4(in.normal.xyz, 0.0);
    out.normal = normalize(normal.xyz);

    out.color = float4(out.normal + 1 * 0.5, 1.0);

    return out;
}

fragment float4 Feature3_anchorGeometryFragmentLighting(Feature3_VertexOut in [[stage_in]],
                                               texture2d<float, access::sample> colorMap [[texture(0)]])
{
    constexpr sampler linearSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    float dist = length(in.eyePosition);
    float4 color = colorMap.sample(linearSampler, float2(dist / 3.0, 0.0));
    return float4(color.rgb, 0.25);
}

fragment float4 Feature3_geometryOutlineFragment(Feature3_VertexOut in [[stage_in]])
{
    return float4(1.0);
}


