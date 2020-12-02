#
# source and resource file definitions for The-Forge

#
# sources

set(TF_SRC_RENDERER
	${TF_DIR_RENDERER}/IRay.h
	${TF_DIR_RENDERER}/IRenderer.h
	${TF_DIR_RENDERER}/IResourceLoader.h
	${TF_DIR_RENDERER}/IShaderReflection.h
	${TF_DIR_RENDERER}/CommonShaderReflection.cpp
	${TF_DIR_RENDERER}/ResourceLoader.cpp

	# D3D12
	$<${TF_RENDERER_DX12}:${TF_DIR_RENDERER}/Direct3D12/Direct3D12CapBuilder.h>
	$<${TF_RENDERER_DX12}:${TF_DIR_RENDERER}/Direct3D12/Direct3D12Hooks.h>
	$<${TF_RENDERER_DX12}:${TF_DIR_RENDERER}/Direct3D12/Direct3D12.cpp>
	$<${TF_RENDERER_DX12}:${TF_DIR_RENDERER}/Direct3D12/Direct3D12Hooks.cpp>
	$<${TF_RENDERER_DX12}:${TF_DIR_RENDERER}/Direct3D12/Direct3D12Raytracing.cpp>
	$<${TF_RENDERER_DX12}:${TF_DIR_RENDERER}/Direct3D12/Direct3D12ShaderReflection.cpp>

	# Vulkan
	$<${TF_RENDERER_VULKAN}:${TF_DIR_RENDERER}/Vulkan/VulkanCapsBuilder.h>
	$<${TF_RENDERER_VULKAN}:${TF_DIR_RENDERER}/Vulkan/Vulkan.cpp>
	$<${TF_RENDERER_VULKAN}:${TF_DIR_RENDERER}/Vulkan/VulkanRaytracing.cpp>
	$<${TF_RENDERER_VULKAN}:${TF_DIR_RENDERER}/Vulkan/VulkanShaderReflection.cpp>

	# Metal
	$<${TF_RENDERER_METAL}:${TF_DIR_RENDERER}/Metal/MetalAvailabilityMacros.h>
	$<${TF_RENDERER_METAL}:${TF_DIR_RENDERER}/Metal/MetalCapBuilder.h>
	$<${TF_RENDERER_METAL}:${TF_DIR_RENDERER}/Metal/MetalMemoryAllocator.h>
	$<${TF_RENDERER_METAL}:${TF_DIR_RENDERER}/Metal/MetalMemoryAllocatorImpl.h>
	$<${TF_RENDERER_METAL}:${TF_DIR_RENDERER}/Metal/MetalRaytracing.mm>
	$<${TF_RENDERER_METAL}:${TF_DIR_RENDERER}/Metal/MetalRenderer.mm>
	$<${TF_RENDERER_METAL}:${TF_DIR_RENDERER}/Metal/MetalShaderReflection.mm>
)

# SpirvTools - dependency
set(TF_SRC_SPIRVTOOLS
	${TF_DIR_OSS}/SPIRV_Cross/spirv_cfg
	${TF_DIR_OSS}/SPIRV_Cross/spirv_cpp
	${TF_DIR_OSS}/SPIRV_Cross/spirv_cross.cpp
	${TF_DIR_OSS}/SPIRV_Cross/spirv_cross_parsed_ir.cpp
	${TF_DIR_OSS}/SPIRV_Cross/spirv_cross_util.cpp
	${TF_DIR_OSS}/SPIRV_Cross/spirv_glsl.cpp
	${TF_DIR_OSS}/SPIRV_Cross/spirv_hlsl.cpp
	${TF_DIR_OSS}/SPIRV_Cross/spirv_msl.cpp
	${TF_DIR_OSS}/SPIRV_Cross/spirv_parser.cpp
	${TF_DIR_OSS}/SPIRV_Cross/spirv_reflect.cpp
	Common_3/Tools/SpirvTools/SpirvTools.h
	Common_3/Tools/SpirvTools/SpirvTools.cpp
)

# ozz-animation - dependency
include_directories(${TF_DIR_OSS}/ozz-animation/src ${TF_DIR_OSS}/ozz-animation/include)
set(TF_SRC_OZZ
	${TF_DIR_OSS}/ozz-animation/src/animation/offline/additive_animation_builder.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/offline/animation_builder.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/offline/animation_optimizer.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/offline/raw_animation.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/offline/raw_animation_archive.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/offline/raw_animation_utils.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/offline/raw_skeleton.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/offline/raw_skeleton_archive.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/offline/raw_track.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/offline/skeleton_builder.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/offline/track_builder.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/offline/track_optimizer.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/runtime/animation.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/runtime/blending_job.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/runtime/ik_aim_job.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/runtime/ik_two_bone_job.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/runtime/local_to_model_job.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/runtime/sampling_job.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/runtime/skeleton.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/runtime/skeleton_utils.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/runtime/track.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/runtime/track_sampling_job.cc
	${TF_DIR_OSS}/ozz-animation/src/animation/runtime/track_triggering_job.cc
	${TF_DIR_OSS}/ozz-animation/src/base/containers/string_archive.cc
	${TF_DIR_OSS}/ozz-animation/src/base/io/archive.cc
	${TF_DIR_OSS}/ozz-animation/src/base/maths/math_archive.cc
	${TF_DIR_OSS}/ozz-animation/src/base/maths/simd_math_archive.cc
	${TF_DIR_OSS}/ozz-animation/src/base/maths/soa_math_archive.cc
	${TF_DIR_OSS}/ozz-animation/src/base/memory/allocator.cc
	${TF_DIR_OSS}/ozz-animation/src/base/platform.cc
)

# OS library
set(TF_SRC_OS
	# zip
	${TF_DIR_OSS}/zip/zip.cpp

	# basisu
	${TF_DIR_OSS}/basis_universal/transcoder/basisu_transcoder.cpp
	
	# EAStdC
	${TF_DIR_OSS}/EASTL/EAStdC/EAMemory.cpp
	${TF_DIR_OSS}/EASTL/EAStdC/EASprintf.cpp
	
	# EASTL
	${TF_DIR_OSS}/EASTL/allocator_forge.cpp
	${TF_DIR_OSS}/EASTL/assert.cpp
	${TF_DIR_OSS}/EASTL/fixed_pool.cpp
	${TF_DIR_OSS}/EASTL/hashtable.cpp
	${TF_DIR_OSS}/EASTL/intrusive_list.cpp
	${TF_DIR_OSS}/EASTL/numeric_limits.cpp
	${TF_DIR_OSS}/EASTL/red_black_tree.cpp
	${TF_DIR_OSS}/EASTL/string.cpp
	${TF_DIR_OSS}/EASTL/thread_support.cpp
	
	# rmem
	${TF_DIR_OSS}/rmem/src/rmem_get_module_info.cpp
	${TF_DIR_OSS}/rmem/src/rmem_hook.cpp
	${TF_DIR_OSS}/rmem/src/rmem_lib.cpp

	# OS / Camera
	${TF_DIR_OS}/Camera/CameraController.cpp
	
	# OS / Core
	${TF_DIR_OS}/Core/Atomics.h
	${TF_DIR_OS}/Core/Compiler.h
	${TF_DIR_OS}/Core/GPUConfig.h
	${TF_DIR_OS}/Core/RingBuffer.h
	${TF_DIR_OS}/Core/ThreadSystem.h
	${TF_DIR_OS}/Core/ThreadSystem.cpp
	${TF_DIR_OS}/Core/Timer.cpp
	
	# OS / FileSystem
	${TF_DIR_OS}/FileSystem/FileSystem.cpp
	${TF_DIR_OS}/FileSystem/SystemRun.cpp
	
	# OS / Input
	${TF_DIR_OS}/Input/InputSystem.cpp
	
	# OS / Interfaces
	${TF_DIR_OS}/Interfaces/IApp.h
	${TF_DIR_OS}/Interfaces/ICameraController.h
	${TF_DIR_OS}/Interfaces/IFileSystem.h
	${TF_DIR_OS}/Interfaces/IInput.h
	${TF_DIR_OS}/Interfaces/ILog.h
	${TF_DIR_OS}/Interfaces/IMemory.h
	${TF_DIR_OS}/Interfaces/IMiddleware.h
	${TF_DIR_OS}/Interfaces/IOperatingSystem.h
	${TF_DIR_OS}/Interfaces/IProfiler.h
	${TF_DIR_OS}/Interfaces/IThread.h
	${TF_DIR_OS}/Interfaces/ITime.h
	
	# OS / Logging
	${TF_DIR_OS}/Logging/Log.h
	${TF_DIR_OS}/Logging/Log.cpp
	
	# OS / Math
	${TF_DIR_OS}/Math/MathTypes.h
	
	# OS / MemoryTracking
	${TF_DIR_OS}/MemoryTracking/MemoryTracking.cpp
	
	# Middleware / Animation
	# ${TF_DIR_MW}/Animation/AnimatedObject.h
	# ${TF_DIR_MW}/Animation/AnimatedObject.cpp
	# ${TF_DIR_MW}/Animation/Animation.h
	# ${TF_DIR_MW}/Animation/Animation.cpp
	# ${TF_DIR_MW}/Animation/Clip.h
	# ${TF_DIR_MW}/Animation/Clip.cpp
	# ${TF_DIR_MW}/Animation/ClipController.h
	# ${TF_DIR_MW}/Animation/ClipController.cpp
	# ${TF_DIR_MW}/Animation/ClipMask.h
	# ${TF_DIR_MW}/Animation/ClipMask.cpp
	# ${TF_DIR_MW}/Animation/Rig.h
	# ${TF_DIR_MW}/Animation/Rig.cpp
	# ${TF_DIR_MW}/Animation/SkeletonBatcher.h
	# Middleware_3/Animation/SkeletonBatcher.cpp
	
	# Middleware / ParallelPrimitives
	$<${TF_PLATFORM_OSX}:${TF_DIR_MW}/ParallelPrimitives/ParallelPrimitives.h>
	$<${TF_PLATFORM_OSX}:${TF_DIR_MW}/ParallelPrimitives/ParallelPrimitives.cpp>

	# Middleware / ECS
	${TF_DIR_MW}/ECS/BaseComponent.h
	${TF_DIR_MW}/ECS/BaseComponent.cpp
	${TF_DIR_MW}/ECS/ComponentRepresentation.h
	${TF_DIR_MW}/ECS/ComponentRepresentation.cpp
	${TF_DIR_MW}/ECS/EntityManager.h
	${TF_DIR_MW}/ECS/EntityManager.cpp

	# Middleware / Text
	${TF_DIR_MW}/Text/Fontstash.h
	${TF_DIR_MW}/Text/Fontstash.cpp
	
	# OS / Middleware / UI
	${TF_DIR_MW}/UI/AppUI.h
	${TF_DIR_MW}/UI/AppUI.cpp
	${TF_DIR_MW}/UI/ImguiGUIDriver.cpp
	
	# OpenSource / imgui
	${TF_DIR_OSS}/imgui/imconfig.h
	${TF_DIR_OSS}/imgui/imgui.h
	${TF_DIR_OSS}/imgui/imgui.cpp
	${TF_DIR_OSS}/imgui/imgui_demo.cpp
	${TF_DIR_OSS}/imgui/imgui_draw.cpp
	${TF_DIR_OSS}/imgui/imgui_internal.h
	${TF_DIR_OSS}/imgui/imgui_widgets.cpp
	
	# OS / Profiler
	${TF_DIR_OS}/Profiler/GpuProfiler.h
	${TF_DIR_OS}/Profiler/GpuProfiler.cpp
	${TF_DIR_OS}/Profiler/ProfilerBase.h
	${TF_DIR_OS}/Profiler/ProfilerBase.cpp
	${TF_DIR_OS}/Profiler/ProfilerHTML.h
	${TF_DIR_OS}/Profiler/ProfilerWidgetsUI.cpp

	# OS / Windows
	$<${TF_PLATFORM_WINDOWS}:${TF_DIR_OS}/Windows/WindowsBase.cpp>
	$<${TF_PLATFORM_WINDOWS}:${TF_DIR_OS}/Windows/WindowsFileSystem.cpp>
	$<${TF_PLATFORM_WINDOWS}:${TF_DIR_OS}/Windows/WindowsLog.cpp>
	$<${TF_PLATFORM_WINDOWS}:${TF_DIR_OS}/Windows/WindowsStackTraceDump.h>
	$<${TF_PLATFORM_WINDOWS}:${TF_DIR_OS}/Windows/WindowsStackTraceDump.cpp>
	$<${TF_PLATFORM_WINDOWS}:${TF_DIR_OS}/Windows/WindowsThread.cpp>
	$<${TF_PLATFORM_WINDOWS}:${TF_DIR_OS}/Windows/WindowsTime.cpp>

	# OS / OSX
	$<${TF_PLATFORM_OSX}:${TF_DIR_OS}/FileSystem/UnixFileSystem.cpp>
	$<${TF_PLATFORM_OSX}:${TF_DIR_OS}/Darwin/CocoaFileSystem.mm>
	$<${TF_PLATFORM_OSX}:${TF_DIR_OS}/Darwin/DarwinLog.cpp>
	$<${TF_PLATFORM_OSX}:${TF_DIR_OS}/Darwin/DarwinThread.cpp>
	$<${TF_PLATFORM_OSX}:${TF_DIR_OS}/Darwin/macOSBase.mm>

	# OS / iOS
	$<${TF_PLATFORM_IOS}:${TF_DIR_OS}/Darwin/iOSBase.mm>

	# OS / Linux
	$<${TF_PLATFORM_LINUX}:${TF_DIR_OS}/FileSystem/UnixFileSystem.cpp>
	$<${TF_PLATFORM_LINUX}:${TF_DIR_OS}/Linux/LinuxBase.cpp>
	$<${TF_PLATFORM_LINUX}:${TF_DIR_OS}/Linux/LinuxFileSystem.cpp>
	$<${TF_PLATFORM_LINUX}:${TF_DIR_OS}/Linux/LinuxLog.cpp>
	$<${TF_PLATFORM_LINUX}:${TF_DIR_OS}/Linux/LinuxThread.cpp>
	$<${TF_PLATFORM_LINUX}:${TF_DIR_OS}/Linux/LinuxTime.cpp>
)

# main library sources
set(TF_SRC_MAINLIB
	${TF_SRC_SPIRVTOOLS}
	${TF_SRC_OS}
	${TF_SRC_RENDERER}
)

# mark certain files as objective-c++
set(TF_SRC_OBJC
	${TF_DIR_OSS}/gainput/lib/source/gainput/mouse/GainputInputDeviceMouse.cpp
	${TF_DIR_OS}/Input/InputSystem.cpp
	${TF_DIR_OS}/Profiler/GpuProfiler.cpp
	${TF_DIR_OS}/Profiler/ProfilerBase.cpp
	${TF_DIR_OS}/Profiler/ProfilerWidgetsUI.cpp
	${TF_DIR_RENDERERER}/CommonShaderReflection.cpp
	${TF_DIR_RENDERERER}/ResourceLoader.cpp
	${TF_DIR_MW}/Animation/SkeletonBatcher.cpp
	${TF_DIR_MW}/Text/Fontstash.cpp
	${TF_DIR_MW}/UI/AppUI.cpp
	${TF_DIR_MW}/UI/ImguiGUIDriver.cpp
)
if (TF_PLATFORM_OSX)
	set_source_files_properties(${TF_SRC_OBJC} PROPERTIES COMPILE_FLAGS "-x objective-c++")
endif()

# link libraries - anything that runs will link these
set(TF_LINK_LIBS
	${TF_PROJ_NAME}

	# Windows
	$<${TF_PLATFORM_WINDOWS}:${TF_DIR_OSS}/ags/ags_lib/lib/amd_ags_x64.lib>
	$<${TF_PLATFORM_WINDOWS}:${TF_DIR_OSS}/nvapi/amd64/nvapi64.lib>

	# Linux
	$<${TF_PLATFORM_LINUX}:pthread>
	$<${TF_PLATFORM_LINUX}:X11>
	$<${TF_PLATFORM_LINUX}:Xrandr>

	# OSX
	$<${TF_PLATFORM_OSX}:${TF_LIB_METAL}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_METALKIT}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_METALPS}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_IOKIT}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_GRAPHICS}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_QUARTZ}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_APPKIT}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_CONTROLLER}>

	# DX - Common
	$<${TF_RENDERER_DX12}:${TF_DIR_OSS}/winpixeventruntime/bin/WinPixEventRuntime.lib>
	$<${TF_RENDERER_DX12}:d3d12.lib>
	$<${TF_RENDERER_DX12}:dxgi.lib>
	$<${TF_RENDERER_DX12}:dxcompiler.lib>
)
