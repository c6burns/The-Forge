/*
 * Copyright (c) 2018 Confetti Interactive Inc.
 * 
 * This file is part of The-Forge
 * (see https://github.com/ConfettiFX/The-Forge).
 * 
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
*/

// Shader for Skybox in Unit Test 01 - Transformations

cbuffer uniformBlock : register(b0)
{
    float4x4 mvp;
};

struct VSOutput {
	float4 Position : SV_POSITION;
    float4 TexCoord : TEXCOORD;
};

VSOutput VSMain(float4 Position : POSITION)
{
	VSOutput result;
 
    float4 p = float4(Position.x*9, Position.y*9, Position.z*9, 1.0);
    float4x4 m =  mvp;
    p = mul(m,p);
    result.Position = p.xyww;
    result.TexCoord = float4(Position.x, Position.y, Position.z,Position.w);
	return result;
}

SamplerState uSampler0 : register(s7);
Texture2D RightText : register(t1);
Texture2D LeftText : register(t2);
Texture2D TopText : register(t3);
Texture2D BotText : register(t4);
Texture2D FrontText : register(t5);
Texture2D BackText : register(t6);

float4 PSMain(VSOutput input) : SV_TARGET
{
    float2 newtextcoord;
    float side = round(input.TexCoord.w);

	if(side==1.0f)
    {
        newtextcoord = (input.TexCoord.zy) / 20 + 0.5;
        newtextcoord = float2(1 - newtextcoord.x, 1 - newtextcoord.y);
        return RightText.Sample(uSampler0, newtextcoord);
    }
    else if (side == 2.0f)
    {
        newtextcoord = (input.TexCoord.zy) / 20 + 0.5;
        newtextcoord = float2(newtextcoord.x, 1 - newtextcoord.y);
        return LeftText.Sample(uSampler0, newtextcoord);
    }
    if (side == 4.0f)
    {
        newtextcoord = (input.TexCoord.xz) / 20 +0.5;
        newtextcoord = float2(newtextcoord.x, 1 - newtextcoord.y);
        return BotText.Sample(uSampler0, newtextcoord);
    }
    else if (side == 5.0f)
    {
        newtextcoord = (input.TexCoord.xy) / 20 + 0.5;
        newtextcoord = float2(newtextcoord.x, 1 - newtextcoord.y);
        return FrontText.Sample(uSampler0, newtextcoord);  
    }
    else if (side == 6.0f)
    {
        newtextcoord = (input.TexCoord.xy) / 20 + 0.5;
        newtextcoord = float2(1-newtextcoord.x, 1 - newtextcoord.y);
        return BackText.Sample(uSampler0, newtextcoord);  
    }
	else
    {
        newtextcoord = (input.TexCoord.xz) / 20 + 0.5;
        newtextcoord = float2(newtextcoord.x, newtextcoord.y);
        return TopText.Sample(uSampler0, newtextcoord);
    }
}
