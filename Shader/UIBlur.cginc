#ifndef UI_BLUR_CGINC
#define UI_BLUR_CGINC

#include "UnityCG.cginc"

// Pixel size.
static const float2 ps = _ScreenParams.zw - 1.0;

// Parameters.
#if !defined(MAINTEX)
sampler2D _MainTex;
#endif
float _Opacity, _Size;

// Functions.

// Creates a linear blur from a projected texture.
// The blur is made centered, so the direction is always absolute.
// sp - Texture sampler.
// uv - Texture coordinates.
// dir - Blur direction vector.
float4 linear_blur(sampler2D sp, float4 uv, float2 dir) {
	static const int samples = 9;

	float4 color = 0.0;

	// Move coordinates in opposite direction to center the sampling.
	uv = UNITY_PROJ_COORD(float4(
		uv.x - dir.x * samples * 0.5,
		uv.y - dir.y * samples * 0.5,
		uv.z,
		uv.w
	));

	[unroll]
	for (int i = 0; i < samples; ++i) {
		uv = UNITY_PROJ_COORD(float4(
			uv.x + dir.x,
			uv.y + dir.y,
			uv.z,
			uv.w
		));
		color += tex2Dproj(sp, uv);
	}

	return color / samples;
}

// Vertex shaders.

struct VS_Quad_Appdata
{
	float4 v : POSITION;
	float2 uv : TEXCOORD;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VS_QuadProj_Appdata
{
	float4 v : POSITION;
	float2 uv : TEXCOORD;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VS_QuadProjColor_Appdata
{
	float4 v : POSITION;
	float2 uv : TEXCOORD;
	float4 img_color : COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct PS_Quad_Appdata{
	float4 p : SV_POSITION;
    UNITY_VERTEX_OUTPUT_STEREO
};

struct PS_QuadProj_Appdata{
	float4 p : SV_POSITION;
	float2 uv1 : TEXCOORD0;
	float4 uv2 : TEXCOORD1;
    UNITY_VERTEX_OUTPUT_STEREO
};

struct PS_QuadProjColor_Appdata{
	float4 p : SV_POSITION;
	float2 uv1 : TEXCOORD0;
	float4 uv2 : TEXCOORD1;
	float4 img_color : COLOR;
    UNITY_VERTEX_OUTPUT_STEREO
};

PS_Quad_Appdata VS_Quad(VS_Quad_Appdata v) {
	PS_Quad_Appdata o;
	UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_OUTPUT(PS_Quad_Appdata, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
	o.p = UnityObjectToClipPos(v.v);
	return o;
}

PS_QuadProj_Appdata VS_QuadProj(VS_QuadProj_Appdata v) {
	PS_QuadProj_Appdata o;
	UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_OUTPUT(PS_QuadProj_Appdata, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
	o.p = UnityObjectToClipPos(v.v);
	o.uv1 = v.uv;
	o.uv2 = ComputeGrabScreenPos(o.p);
	return o;
}

PS_QuadProjColor_Appdata VS_QuadProjColor(VS_QuadProjColor_Appdata v) {
	PS_QuadProjColor_Appdata o;
	UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_OUTPUT(PS_QuadProjColor_Appdata, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
	o.p = UnityObjectToClipPos(v.v);
	o.uv1 = v.uv;
	o.uv2 = ComputeGrabScreenPos(o.p);
	o.img_color = v.img_color;
	return o;
}

// Pixel shader functions (for changing the grab pass texture).

float4 blur_x(float2 img_uv, float4 grab_uv, sampler2D grab_tex) {
	float2 dir = float2(ps.x * _Size, 0.0);
    
	float4 blur = linear_blur(grab_tex, grab_uv, dir);
	blur.a = 1.0;

	float4 color = tex2D(_MainTex, img_uv);

    return blur * color.a;
}

float4 blur_y(float2 img_uv, float4 grab_uv, float4 img_color, sampler2D grab_tex) {
	float2 dir = float2(0.0, ps.y * _Size);
    
	float4 blur = linear_blur(grab_tex, grab_uv, dir);
	blur.a = 1.0;

	float4 color = tex2D(_MainTex, img_uv) * img_color;
	color = lerp(blur * color.a, color, _Opacity);

	return color;
}

#endif