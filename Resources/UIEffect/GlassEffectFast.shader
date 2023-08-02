Shader "Funique/Build-in/UI Blur Effet Fast" {
Properties {
	[HideInInspector]
	_MainTex("", 2D) = "" {}
	_Opacity("Opacity", Range(0.0, 1.0)) = 0.5
	[KeywordEnum(NONE, LITTLE_KERNEL, MEDIUM_KERNEL, BIG_KERNEL)] _Level ("Level", Float) = 0
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
	#pragma multi_compile NONE LITTLE_KERNEL MEDIUM_KERNEL BIG_KERNEL
	#include "UIBlur.cginc"
	sampler2D _GrabTexture;
	fixed4 _GrabTexture_TexelSize;

	fixed4 PS_BlurX(PS_QuadProj_Appdata i) : SV_TARGET {
		UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
		return blur_x(i.uv1);
	}

	fixed4 PS_BlurY(PS_QuadProjColor_Appdata i) : SV_TARGET {
		UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
		//return tex2D(_GrabTexture, i.uv2);
		return blur_f(i.uv1, i.uv2, i.img_color, _MainTex, _GrabTexture, _GrabTexture_TexelSize);
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