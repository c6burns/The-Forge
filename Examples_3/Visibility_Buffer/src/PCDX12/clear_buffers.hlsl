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

#include "shader_defs.h"

RWStructuredBuffer<UncompactedDrawArguments> uncompactedDrawArgs[NUM_CULLING_VIEWPORTS];
RWStructuredBuffer<uint> indirectDrawArgsBufferAlpha[NUM_CULLING_VIEWPORTS];
RWStructuredBuffer<uint> indirectDrawArgsBufferNoAlpha[NUM_CULLING_VIEWPORTS];

[numthreads(CLEAR_THREAD_COUNT, 1, 1)]
void CSMain(uint3 threadID : SV_DispatchThreadID)
{
    if (threadID.x >= MAX_DRAWS_INDIRECT - 1)
        return;

	[unroll(NUM_CULLING_VIEWPORTS)]
	for (uint i = 0; i < NUM_CULLING_VIEWPORTS; ++i)
	{
		uncompactedDrawArgs[i][threadID.x].numIndices = 0;
	}

    if (threadID.x == 0)
    {
		[unroll(NUM_CULLING_VIEWPORTS)]
		for (uint i = 0; i < NUM_CULLING_VIEWPORTS; ++i)
		{
			indirectDrawArgsBufferAlpha[i][DRAW_COUNTER_SLOT_POS] = 0;
			indirectDrawArgsBufferNoAlpha[i][DRAW_COUNTER_SLOT_POS] = 0;
		}
    }
}
