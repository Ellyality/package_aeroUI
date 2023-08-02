Shader "Funique/URP/UI Blur Effet Fast" {
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
sampler2D _GrabbedTexture;
fixed4 _GrabbedTexture_TexelSize;

fixed4 PS_BlurA(PS_QuadProjColor_Appdata v) : SV_TARGET {
	return blur_f(v.uv1, v.uv2, v.img_color, _MainTex, _GrabbedTexture, _GrabbedTexture_TexelSize);
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