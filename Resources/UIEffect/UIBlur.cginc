#ifndef UI_BLUR_CGINC
#define UI_BLUR_CGINC

#pragma target 3.0

#include "UnityCG.cginc"
#include "GaussianBlur.cginc"

#ifndef ITER
	#define ITER 6
#endif

// Pixel size.
static const float2 ps = _ScreenParams.zw - 1.0;

// Parameters.
#if !defined(MAINTEX)
uniform sampler2D _MainTex;
uniform float4 _MainTex_TexelSize;
#endif
float _Opacity;
int _Size;

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

float4 blur_x(float2 img_uv) {
	float4 color = tex2D(_MainTex, img_uv);
    return color;
}
float4 blur_y(float2 img_uv, float4 grab_uv, float4 img_color, sampler2D main_tex, sampler2D grab_tex, float4 grab_texelSize) {
	pixel_info pi;
	pi.tex = grab_tex;
	pi.uv = grab_uv.xy / grab_uv.w;
	pi.texelSize = grab_texelSize;
	float4 blur = GaussianBlurOnePass(pi, _Size, float2(_Size, _Size), int(_Size));
	blur.a = 1.0;

	float4 main_pixel = tex2D(main_tex, img_uv) * img_color;
	float4 color = main_pixel * _Opacity;
	color *= blur;
	color = lerp(blur, color, color.a);
	color.a = 1.0;

	return color;
}
float4 blur_a(float2 img_uv, float4 grab_uv, float4 img_color, sampler2D main_tex, sampler2D grab_tex, float4 grab_texelSize) {
	pixel_info pi;
	pi.tex = grab_tex;
	pi.uv = grab_uv.xy / grab_uv.w;
	pi.texelSize = grab_texelSize;
	float4 blur = GaussianBlurOnePass(pi, _Size, float2(_Size, _Size), int(_Size));
	blur.a = 1.0;

	float4 main_pixel = tex2D(main_tex, img_uv) * img_color;
	float4 color = main_pixel * _Opacity;
	color *= blur;
	color = lerp(blur, color, color.a);
	color.a = 1.0;

	return color;
}
#endif