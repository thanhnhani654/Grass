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
		_WindMap("Wind Map", 2D) = "white" {}
		_WindSpeed("Wind Speed", Float) = 100
		_WindStrength("Wind Strength", Float) = 0.05
		_WindZone("Wind Zone", Vector) = (0,0,0,0)
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
	sampler2D _WindMap;

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
		float3 _WindZone;

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

		void buildQuadGrass(inout TriangleStream<g2f> triStream, float3 points[4], float3 color)
		{
			g2f OUT;
			float3 faceNormal = cross(points[1] - points[0], points[2] - points[0]);
			for (int i = 0; i < 4; i++)
			{
				OUT.pos = UnityObjectToClipPos(points[i]);
				OUT.norm = faceNormal;
				OUT.diffuseColor = color;
				OUT.uv = float2(i % 2, (int)(i / 2));
				triStream.Append(OUT);
			}
			triStream.RestartStrip();
		}

		[maxvertexcount(24)]
		void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
		{
			float3 lightPosition = _WorldSpaceLightPos0;

			float3 perpendicularAngle = float3(1, 0, 0);
			float3 faceNormal = cross(perpendicularAngle, IN[0].norm);

			float3 v0 = IN[0].pos.xyz;
			float3 v1 = IN[0].pos.xyz + IN[0].norm * _GrassHeight;

			//Wind Shader
			float3 wind = float3(0,0,0);
			float y = _Time.y / 2;

			wind.x = (sin(y) + sin(2 * y) * sin(3 * y) + 1.5)*0.02 * sin(_Time.x * _WindSpeed + v0.x) * sin(_Time.x * _WindSpeed + v0.z * 2);
			wind.z = (sin(_Time.x * _WindSpeed) + 1) ;
			//wind.z = 10 / (-(_WindZone.z - v0.z)) * (sin(_Time.x * _WindSpeed) + 1);
			//wind.z = -5;
			//wind.x = 0;
			wind.x *= _WindSpeed;


			v1 += wind *_WindStrength;

			float3 color = (IN[0].color);

			g2f OUT;
			UNITY_INITIALIZE_OUTPUT(g2f, OUT);
			//Quad
			/*OUT.pos = UnityObjectToClipPos(v0 + perpendicularAngle * 0.5 * _GrassHeight);
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
*/

			//Quad1
			float3 quad1[4] = { v0 + perpendicularAngle * 0.5 * _GrassWidth,
				v0 - perpendicularAngle * 0.5 * _GrassWidth,
				v1 + perpendicularAngle * 0.5 * _GrassWidth,
				v1 - perpendicularAngle * 0.5 * _GrassWidth, };
			buildQuadGrass(triStream, quad1, color);
			//Quad2
			float3 quad2[4] = { v0 + float3(sin(60),0,-cos(60)) * 0.5 * _GrassWidth,
				v0 - float3(sin(60),0,-cos(60)) * 0.5 * _GrassWidth,
				v1 + float3(sin(60),0,-cos(60)) * 0.5 * _GrassWidth,
				v1 - float3(sin(60),0,-cos(60)) * 0.5 * _GrassWidth, };
			buildQuadGrass(triStream, quad2, color);
			//Quad2
			float3 quad3[4] = { v0 + float3(sin(60),0,cos(60)) * 0.5 * _GrassWidth,
				v0 - float3(sin(60),0,cos(60)) * 0.5 * _GrassWidth,
				v1 + float3(sin(60),0,cos(60)) * 0.5 * _GrassWidth,
				v1 - float3(sin(60),0,cos(60)) * 0.5 * _GrassWidth, };
			buildQuadGrass(triStream, quad3, color);
			
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
