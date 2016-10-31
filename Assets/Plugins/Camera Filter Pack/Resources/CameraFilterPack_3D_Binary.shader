﻿////////////////////////////////////////////
// CameraFilterPack - by VETASOFT 2016 /////
////////////////////////////////////////////

Shader "CameraFilterPack/3D_Binary" {
Properties 
{
_MainTex ("Base (RGB)", 2D) = "white" {}
_TimeX ("Time", Range(0.0, 1.0)) = 1.0
_Distortion ("_Distortion", Range(0.0, 1.00)) = 1.0
_ScreenResolution ("_ScreenResolution", Vector) = (0.,0.,0.,0.)
_ColorRGB ("_ColorRGB", Color) = (1,1,1,1)

}
SubShader 
{
Pass
{
ZTest Always
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#pragma target 3.0
#include "UnityCG.cginc"


uniform sampler2D _MainTex;
uniform float _TimeX;
uniform float _Distortion;
uniform float4 _ScreenResolution;
uniform float4 _MatrixColor;
uniform float _DepthLevel;
uniform float _FarCamera;
uniform float _FadeFromBinary;
uniform sampler2D _CameraDepthTexture;
uniform float _FixDistance;
uniform float _LightIntensity;
uniform sampler2D _MainTex2;
uniform float _MatrixSize;
uniform float _MatrixSpeed;
uniform float2 _MainTex_TexelSize;

struct appdata_t
{
float4 vertex   : POSITION;
float4 color    : COLOR;
float2 texcoord : TEXCOORD0;
};

struct v2f
{
half2 texcoord  : TEXCOORD0;
float4 vertex   : SV_POSITION;
fixed4 color    : COLOR;
float4 projPos : TEXCOORD1; 
};   

v2f vert(appdata_t IN)
{
v2f OUT;
OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
OUT.texcoord = IN.texcoord;
OUT.color = IN.color;
OUT.projPos = ComputeScreenPos(OUT.vertex);

return OUT;
}


float4 frag (v2f i) : COLOR
{
float depth = LinearEyeDepth  (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)).r);
depth/=_FixDistance*10;
depth = 1-depth;
depth = saturate(depth);
depth = lerp(0.5,depth,_DepthLevel);
depth = lerp(depth,1,_FadeFromBinary);
float t=_Time*_MatrixSpeed;
float2 uv = i.texcoord.xy;
#if UNITY_UV_STARTS_AT_TOP
if (_MainTex_TexelSize.y < 0)
uv.y = 1-uv.y;
#endif
float2 uv2=uv;
depth=floor(depth*32)/32;
uv/=depth+0.2-(_FadeFromBinary/2);
uv.x-=t;
uv*=float2(1,0.5)+_MatrixSize;
float4 mx = tex2D(_MainTex2,uv).r;
mx -=1-_MatrixColor;
float md=mx*0.01*_DepthLevel;
float4 txt = tex2D(_MainTex,uv2+float2(md,md));
mx+=txt*2+depth*(_LightIntensity-1);
mx=lerp(txt,mx,_DepthLevel);
return mx;
}

ENDCG
}

}
}