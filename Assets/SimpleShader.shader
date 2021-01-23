Shader "Custom/Unlit/SimpleShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,0)
        _Gloss ("Gloss", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            // Mesh data: vertex position, vertex normal, UVs, tangents, vertex colors 
            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;

                // float4 color : COLOR;
                // float4 tangent : TANGENT;
                // float2 uv1 : TEXCOORD1;
            };

            struct VertexOutput
            {
                float4 clipSpacePos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            // sampler2D _MainTex;
            // float4 _MainTex_ST;

            float4 _Color;
            float _Gloss;

            // Vertex Shader
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normal = v.normal;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.clipSpacePos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float3 InvLerp(float3 a, float3 b, float3 value)
            {
                return (value - a) / (b - a);
            }

            float3 MyLerp(float3 a, float3 b, float t)
            {
                return t * b + (1.0 - t) * a;
            }

            float Posterize(float steps, float value)
            {
                return floor(value * steps) / steps;
            }

            fixed4 frag(VertexOutput o) : SV_Target
            {
                float2 uv = o.uv0;

                float3 colorA = float3(0.1, 0.8, 0.25);
                float3 colorB = float3(0.5, 0.1, 0.2);
                float t = uv.y;

                t = Posterize(16,t);

                //return t;

                float3 blend = MyLerp(colorA, colorB, t);

                //return float4(blend, 0);

                float3 normal = normalize(o.normal);       // Interpolated
                
                // return float4(o.worldPos, 1);


                //float3 normal = o.normal * 0.5 + 0.5f; // 0 to 1
                //float3 normal = o.normal; // -1 to 1
                // float3 clipPos = o.clipSpacePos.xyz;
                    
                // hardcoded light
                // float3 lightDir = normalize(float3(1, 1, 1));
                // float3 lightColor = float3(0.9, 0.82, 0.7);
                
                //Lighting

                // using unity lights
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.xyz;

                // Direct diffuse Light
                float lightFallOff = max(0, dot(lightDir, normal));
                //lightFallOff = Posterize(4, lightFallOff);
                float3 directDiffuseLight = lightColor * lightFallOff;

                // Ambient Light
                float3 ambientLight = float3(0.15, 0.15, 0.15);
                
                // Direct Specular Light
                float3 camPos = _WorldSpaceCameraPos;
                float3 fragmentToCam = camPos - o.worldPos;
                float3 viewDir = normalize(fragmentToCam);
                float3 viewReflect = reflect(-viewDir, normal);
                float specularFallOff = max(0, dot(viewReflect, lightDir));
                //specularFallOff = Posterize(5, specularFallOff);
                // Modify Gloss
                specularFallOff = pow(specularFallOff, _Gloss);
                
                float3 directSpecular = specularFallOff * lightColor;

                //Composite Light
                float3 diffuseLight = ambientLight + directDiffuseLight;
                float3 finalSurfaceColor = diffuseLight * _Color.rgb + directSpecular;

                return float4( finalSurfaceColor, 0);
                
                // Phong
                // Blinn-Phong
            }
            ENDCG
        }
    }
}
