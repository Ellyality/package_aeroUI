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

#include "UIBlur.cginc"
sampler2D _GrabbedTexture;

float4 PS_BlurA(PSQuadI p) : SV_TARGET {
	return blur_y(p.uv1, p.uv2, blur_x(p.uv1, p.uv2, _MainTex), _GrabbedTexture);
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