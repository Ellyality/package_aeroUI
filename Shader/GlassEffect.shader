Shader "Funique/Build-in/UI Blur Effet" {
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

sampler2D _GrabTexture;

float4 PS_BlurX(PSQuad p) : SV_TARGET {
	return blur_x(p.uv1, p.uv2, _GrabTexture);
}

float4 PS_BlurY(PSQuadI p) : SV_TARGET {
	return blur_y(p.uv1, p.uv2, p.img_color, _GrabTexture);
}

	ENDCG

	GrabPass {
		Tags {
			"LightMode" = "Always"
		}
	}

	Pass {
		CGPROGRAM
		#pragma vertex VS_QuadProj
		#pragma fragment PS_BlurX
		ENDCG
	}

	GrabPass {
		Tags {
			"LightMode" = "Always"
		}
	}

	Pass {
		CGPROGRAM
		#pragma vertex VS_QuadProjColor
		#pragma fragment PS_BlurY
		ENDCG
	}
}Fallback "Funique/URP/UI Blur Effet"
}