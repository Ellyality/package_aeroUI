Shader "Funique/URP/UI Blur Effet" {
Properties {
	[HideInInspector] 
	_MainTex("", 2D) = "" {}
	_Opacity("Opacity", Range(0.0, 1.0)) = 0.5
	_Size("Size", Range(1.0, 16.0)) = 4.0
}
SubShader {
	Tags {
		"Queue" = "Transparent"
		"IgnoreProjector" = "True"
		"RenderType" = "Transparent"
		"PreviewType" = "Plane"
	}
	Cull Off
	ZTest [unity_GUIZTestMode]
	ZWrite Off
	Blend SrcAlpha OneMinusSrcAlpha

	CGINCLUDE

UNITY_DECLARE_SCREENSPACE_TEXTURE(_MainTex);
#define MAINTEX
#include "UIBlur.cginc"
sampler2D _GrabbedTexture;

float4 PS_BlurA(
	float4 p : SV_POSITION,
	float2 uv1 : TEXCOORD0,
	float4 uv2 : TEXCOORD1,
	float4 img_color : COLOR
) : SV_TARGET {

#if defined(UNIVERSAL_PIPELINE_CORE_INCLUDED)
	return tex2D(_MainTex, uv1);
#else
	return blur_y(uv1, uv2, blur_x(uv1, uv2, _MainTex), _GrabbedTexture);
#endif
	
}

	ENDCG

	Pass {
		Tags
        {
            // Specify LightMode correctly.
            "LightMode" = "UseColorTexture"
        }
		CGPROGRAM
		#pragma vertex VS_QuadProj
		#pragma fragment PS_BlurA
		ENDCG
	}
}FallBack "Funique/Build-in/UI Blur Effet"
}