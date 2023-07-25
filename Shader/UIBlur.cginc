#ifndef UI_BLUR_CGINC
#define UI_BLUR_CGINC

#include "UnityCG.cginc"

// Pixel size.
static const float2 ps = _ScreenParams.zw - 1.0;

// Parameters.
sampler2D _MainTex;
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

struct VSQuad
{
    float3 positionOS   : POSITION;
    float4 color        : COLOR;
    float2 uv           : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VSQuadColor
{
    float3 positionOS   : POSITION;
    float4 color        : COLOR;
    float2 uv           : TEXCOORD0;
	float4 img_color : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct PSQuad{
	float4 p : SV_POSITION;
	float2 uv1 : TEXCOORD0;
	float4 uv2 : TEXCOORD1;
	UNITY_VERTEX_OUTPUT_STEREO
};

struct PSQuadI{
	float4 p : SV_POSITION;
	float2 uv1 : TEXCOORD0;
	float4 uv2 : TEXCOORD1;
	float4 img_color : COLOR;
	UNITY_VERTEX_OUTPUT_STEREO
};

PSQuad VS_Quad(VSQuad a) {
	PSQuad o;
	UNITY_SETUP_INSTANCE_ID(o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
	o.p = UnityObjectToClipPos(a.positionOS);
	o.uv1 = a.uv;
	return o;
}

PSQuad VS_QuadProj(VSQuad a) {
    PSQuad o = VS_Quad(a);
	UNITY_SETUP_INSTANCE_ID(o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
	//o.uv2 = ComputeGrabScreenPos(a.positionOS);
	return o;
}

PSQuadI VS_QuadProjColor(VSQuadColor a) {
	VSQuad v;
	v.positionOS = a.positionOS;
    v.color = a.color;
    v.uv = a.uv;
	PSQuad ob = VS_QuadProj(v);
	PSQuadI o;
	o.p = ob.p;
	o.uv2 = ob.uv2;
	o.uv1 = a.uv;
	o.img_color = a.img_color;
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