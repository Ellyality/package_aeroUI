Shader "Funique/URP/UI Blur Square Effet"
{
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
	sampler2D _GrabbedTexture;
	fixed4 _GrabbedTexture_TexelSize;
	#include "UIBlur.cginc"

	float4 PS_BlurK(PS_QuadProjColor_Appdata p) : SV_TARGET {
		return sblur_a(p.uv1, p.uv2, p.img_color, _GrabbedTexture);
	}

		ENDCG

		Pass {
			CGPROGRAM
			#pragma vertex VS_QuadProjColor
			#pragma fragment PS_BlurK
			ENDCG
		}
	}
}