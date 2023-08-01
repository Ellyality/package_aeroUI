Shader "Funique/URP/UI Blur Effet" {
Properties {
	[HideInInspector] 
	_MainTex("", 2D) = "" {}
	_Opacity("Opacity", Range(0.0, 1.0)) = 0.5
	_Size("Size", Range(1.0, 30.0)) = 4.0
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
	#define SIZE KERNEL_SIZE
#include "UIBlur.cginc"
sampler2D _GrabbedTexture;
float4 _GrabbedTexture_TexelSize;

float4 PS_BlurA(PS_QuadProjColor_Appdata v) : SV_TARGET {
	return blur_a(v.uv1, v.uv2, v.img_color, _MainTex, _GrabbedTexture, _GrabbedTexture_TexelSize);
}

	ENDCG

	Pass {
		Tags
        {
            // Specify LightMode correctly.
            "LightMode" = "UseColorTexture"
        }
		CGPROGRAM
		#pragma target 3.0
		#pragma vertex VS_QuadProjColor
		#pragma fragment PS_BlurA
		ENDCG
	}
}FallBack "Funique/Build-in/UI Blur Effet"
}