// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/GrassGeometryShader" {
	Properties{
		[HDR]_BackgroundColor("Background Color", Color) = (1,0,0,1)
		[HDR]_ForegroundColor("Foreground Color", Color) = (0,0,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Cutoff("Cutoff", Range(0,1)) = 0.25
		_GrassHeight("Grass Height", Float) = 0.25
		_GrassWidth("Grass Width", Float) = 0.25
		_WindSpeed("Wind Speed", Float) = 100
		_WindStrength("Wind Strength", Float) = 0.05		
	}
		SubShader{
			Tags{ "RenderType" = "Opaque"}
			LOD 200

			Pass
		{
			CULL OFF

			CGPROGRAM
#include "UnityCG.cginc"
#pragma vertex vert
#pragma fragment frag
#pragma geometry geom

			// Use shader model 4.0 target, we need geometry shader support
			sampler2D _MainTex;

		struct v2g
		{
			float4 pos : SV_POSITION;
			float3 norm : NORMAL;
			float2 uv : TEXCOORD0;
			float3 color : TEXCOORD1;
		};

		struct g2f
		{
			float4 pos : SV_POSITION;
			float3 norm : NORMAL;
			float2 uv : TEXCOORD0;
			float3 diffuseColor : TEXCOORD1;
			//float3 specularColor : TEXCOORD2;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _BackgroundColor;
		fixed4 _ForegroundColor;

		half _GrassHeight;
		half _GrassWidth;
		half _Cutoff;
		half _WindStrength;
		half _WindSpeed;

		v2g vert(appdata_full v)
		{
			float3 v0 = v.vertex.xyz;

			v2g OUT;
			OUT.pos = v.vertex;
			OUT.norm = v.normal;
			OUT.uv = v.texcoord;
			OUT.color = tex2Dlod(_MainTex, v.texcoord).rgb;
			return OUT;
		}

		[maxvertexcount(4)]
		void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
		{
			float3 lightPosition = _WorldSpaceLightPos0;

			float3 perpendicularAngle = float3(1, 0, 0);
			float3 faceNormal = cross(perpendicularAngle, IN[0].norm);

			float3 v0 = IN[0].pos.xyz;
			float3 v1 = IN[0].pos.xyz + IN[0].norm * _GrassHeight;

			float3 wind = float3(
				sin(_Time.x * _WindSpeed + v0.x) + sin(_Time.x * _WindSpeed + v0.z * 2) + sin(_Time.x * _WindSpeed * 0.1 + v0.x), 0,
				0);//cos(_Time.x * _WindSpeed + v0.x * 2)	+ cos(_Time.x * _WindSpeed + v0.z));
			v1 += wind * _WindStrength;

			float3 color = (IN[0].color);

			g2f OUT;
			UNITY_INITIALIZE_OUTPUT(g2f, OUT);

			//Quad
			OUT.pos = UnityObjectToClipPos(v0 + perpendicularAngle * 0.5 * _GrassHeight);
			OUT.norm = faceNormal;
			OUT.uv = float2(1, 0);
			OUT.diffuseColor = color;
			triStream.Append(OUT);

			OUT.pos = UnityObjectToClipPos(v0 - perpendicularAngle * 0.5 * _GrassHeight);
			OUT.norm = faceNormal;
			OUT.uv = float2(0, 0);
			OUT.diffuseColor = color;
			triStream.Append(OUT);

			OUT.pos = UnityObjectToClipPos(v1 + perpendicularAngle * 0.5 * _GrassHeight);
			OUT.norm = faceNormal;
			OUT.uv = float2(1, 1);
			OUT.diffuseColor = color;
			triStream.Append(OUT);

			OUT.pos = UnityObjectToClipPos(v1 - perpendicularAngle * 0.5 * _GrassHeight);
			OUT.norm = faceNormal;
			OUT.uv = float2(0,1);
			OUT.diffuseColor = color;
			triStream.Append(OUT);
		}

		half4 frag(g2f IN) : COLOR
		{
			fixed4 c = tex2D(_MainTex, IN.uv);
			clip(c.a - _Cutoff);	
			return c;
		}
			ENDCG
		}
		}
}
