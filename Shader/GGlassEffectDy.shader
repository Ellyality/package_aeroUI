Shader "Funique/Build-in/UI Gaussian Blur Effet" {
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
	#define SIZE _Size
	#include "UIBlur.cginc"
	sampler2D _GrabTexture;
	float4 _GrabTexture_TexelSize;

	float4 PS_BlurX(PS_QuadProj_Appdata i) : SV_TARGET {
		UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
		return gblur_x(i.uv1, i.uv2, _GrabTexture, _GrabTexture_TexelSize);
	}

	float4 PS_BlurY(PS_QuadProjColor_Appdata i) : SV_TARGET {
		UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
		//return tex2D(_GrabTexture, i.uv2);
		return gblur_y(i.uv1, i.uv2, i.img_color, _GrabTexture, _GrabTexture_TexelSize);
	}
	ENDCG

	GrabPass {"_GrabTexture"}

	Pass {
		CGPROGRAM
		#pragma vertex VS_QuadProj
		#pragma fragment PS_BlurX
		ENDCG
	}

	GrabPass {"_GrabTexture"}

	Pass {
		CGPROGRAM
		#pragma vertex VS_QuadProjColor
		#pragma fragment PS_BlurY
		ENDCG
	}
}
}