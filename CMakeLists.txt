cmake_minimum_required(VERSION 3.15)
cmake_policy(SET CMP0079 NEW)
set(CMAKE_CXX_STANDARD 14)

if (NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Debug)
endif()

#
# setup

set(TF_TARGET_NAME TheForge)
project(${TF_TARGET_NAME} LANGUAGES C CXX)

set(TF_PLATFORM_WINDOWS 0)
set(TF_PLATFORM_OSX 0)
set(TF_PLATFORM_IOS 0)
set(TF_PLATFORM_LINUX 0)
if (IOS)
	set(TF_PLATFORM "IOS")
	set(TF_PLATFORM_IOS 1)
elseif (APPLE)
	set(TF_PLATFORM "OSX")
	set(TF_PLATFORM_OSX 1)
elseif (UNIX)
	set(TF_PLATFORM "LINUX")
	set(TF_PLATFORM_LINUX 1)
elseif (WIN32)
	set(TF_PLATFORM "WINDOWS")
	set(TF_PLATFORM_WINDOWS 1)
else()
	message(FATAL_ERROR "Unsupported platform")
endif()

set(TF_LINK_LIBS)
set(TF_OBJC_FLAGS $<${TF_PLATFORM_OSX}:-x objective-c++>)
set(TF_ARC_FLAGS $<${TF_PLATFORM_OSX}:-fobjc-arc>)
set(TF_LIB_XINPUT $<${TF_PLATFORM_WINDOWS}:xinput.lib>)

set(TF_RENDERER_DIR_VALID)
set(TF_RENDERER_DIR)
set(TF_RENDERER_VALID)
set(TF_RENDERER)
set(TF_RENDERER_VULKAN 0)
set(TF_RENDERER_METAL 0)
set(TF_RENDERER_DX12 0)
set(TF_RENDERER_DX11 0)
if (TF_PLATFORM_OSX)
	set(TF_RENDERER "METAL")
	set(TF_RENDERER_METAL 1)
	set(TF_RENDERER_VALID "METAL" "VULKAN")
	set(TF_RENDERER_DIR_VALID "Metal" "Vulkan")
elseif (TF_PLATFORM_WINDOWS)
	set(TF_RENDERER "VULKAN")
	set(TF_RENDERER_VULKAN 1)
	set(TF_RENDERER_VALID "VULKAN" "DIRECT3D12" "DIRECT3D11")
	set(TF_RENDERER_DIR_VALID "Vulkan" "D3D12" "D3D11")
elseif (TF_PLATFORM_LINUX)
	set(TF_RENDERER "VULKAN")
	set(TF_RENDERER_VULKAN 1)
	set(TF_RENDERER_VALID "VULKAN")
	set(TF_RENDERER_DIR_VALID "Vulkan")
else()
	message(FATAL_ERROR "Unsupported build platform")
endif()

list(FIND TF_RENDERER_VALID ${TF_RENDERER} tf_valid_idx)
if (tf_valid_idx LESS 0)
	message(FATAL_ERROR "Invalid renderer: '${TF_RENDERER}'")
endif()
list(GET TF_RENDERER_DIR_VALID ${tf_valid_idx} TF_RENDERER_DIR)

message("Building: ${TF_PLATFORM} / ${TF_RENDERER}")

set(TF_DIR_COMMON ${CMAKE_CURRENT_SOURCE_DIR}/Common_3)
set(TF_DIR_RENDER ${TF_DIR_COMMON}/Renderer)
set(TF_DIR_OS ${TF_DIR_COMMON}/OS)
set(TF_DIR_TOOLS ${TF_DIR_COMMON}/Tools)
set(TF_DIR_OSS ${TF_DIR_COMMON}/ThirdParty/OpenSource)
set(TF_DIR_MW ${CMAKE_CURRENT_SOURCE_DIR}/Middleware_3)

find_package(Vulkan)

#
# sources

set(TF_SRC_RENDERER_COMMON
	Common_3/Renderer/IRay.h
	Common_3/Renderer/IRenderer
	Common_3/Renderer/IResourceLoader
	Common_3/Renderer/IShaderReflection
	Common_3/Renderer/CommonShaderReflection.cpp
	Common_3/Renderer/ResourceLoader.cpp
)

set(TF_SRC_RENDERER_D3D11 
	Common_3/Renderer/Direct3D11/Direct3D11CapBuilder.h
	Common_3/Renderer/Direct3D11/Direct3D11Commands.h
	Common_3/Renderer/Direct3D11/Direct3D11.cpp
	Common_3/Renderer/Direct3D11/Direct3D11Raytracing.cpp
	Common_3/Renderer/Direct3D11/Direct3D11ShaderReflection.cpp
)

set(TF_SRC_RENDERER_D3D12 
	Common_3/Renderer/Direct3D12/Direct3D12CapBuilder.h
	Common_3/Renderer/Direct3D12/Direct3D12Hooks.h
	Common_3/Renderer/Direct3D12/Direct3D12.cpp
	Common_3/Renderer/Direct3D12/Direct3D12Hooks.cpp
	Common_3/Renderer/Direct3D12/Direct3D12Raytracing.cpp
	Common_3/Renderer/Direct3D12/Direct3D12ShaderReflection.cpp
)

set(TF_SRC_RENDERER_VULKAN 
	Common_3/Renderer/Vulkan/VulkanCapsBuilder.h
	Common_3/Renderer/Vulkan/Vulkan.cpp
	Common_3/Renderer/Vulkan/VulkanRaytracing.cpp
	Common_3/Renderer/Vulkan/VulkanShaderReflection.cpp
)

set(TF_SRC_RENDERER_METAL 
	Common_3/Renderer/Metal/MetalAvailabilityMacros.h
	Common_3/Renderer/Metal/MetalCapBuilder.h
	Common_3/Renderer/Metal/MetalMemoryAllocator.h
	Common_3/Renderer/Metal/MetalMemoryAllocatorImpl.h
	Common_3/Renderer/Metal/MetalRaytracing.mm
	Common_3/Renderer/Metal/MetalRenderer.mm
	Common_3/Renderer/Metal/MetalShaderReflection.mm
)

set (TF_SRC_RENDERER
	${TF_SRC_RENDERER_COMMON}
	$<${TF_RENDERER_DX11}:${TF_SRC_RENDERER_D3D11}>
	$<${TF_RENDERER_DX12}:${TF_SRC_RENDERER_D3D12}>
	$<${TF_RENDERER_VULKAN}:${TF_SRC_RENDERER_VULKAN}>
	$<${TF_RENDERER_METAL}:${TF_SRC_RENDERER_METAL}>
)

# SpirvTools - dependency
set(TF_SRC_SPIRVTOOLS
	Common_3/ThirdParty/OpenSource/SPIRV_Cross/spirv_cfg
	Common_3/ThirdParty/OpenSource/SPIRV_Cross/spirv_cpp
	Common_3/ThirdParty/OpenSource/SPIRV_Cross/spirv_cross.cpp
	Common_3/ThirdParty/OpenSource/SPIRV_Cross/spirv_cross_parsed_ir.cpp
	Common_3/ThirdParty/OpenSource/SPIRV_Cross/spirv_cross_util.cpp
	Common_3/ThirdParty/OpenSource/SPIRV_Cross/spirv_glsl.cpp
	Common_3/ThirdParty/OpenSource/SPIRV_Cross/spirv_hlsl.cpp
	Common_3/ThirdParty/OpenSource/SPIRV_Cross/spirv_msl.cpp
	Common_3/ThirdParty/OpenSource/SPIRV_Cross/spirv_parser.cpp
	Common_3/ThirdParty/OpenSource/SPIRV_Cross/spirv_reflect.cpp
	Common_3/Tools/SpirvTools/SpirvTools.h
	Common_3/Tools/SpirvTools/SpirvTools.cpp
)

# gainput - dependency
# file(GLOB_RECURSE TF_SRC_GAINPUT ${TF_DIR_OSS}/gainput/lib/source/*.cpp ${TF_DIR_OSS}/gainput/lib/source/*.h ${TF_DIR_OSS}/gainput/lib/include/*.h)
# if(APPLE)
# 	file(GLOB_RECURSE TF_MMSRC_GAINPUT ${TF_DIR_OSS}/gainput/lib/source/*.mm)
# 	set(TF_SRC_GAINPUT ${TF_SRC_GAINPUT} ${TF_MMSRC_GAINPUT})
# endif()
# add_library(gainputstatic ${TF_SRC_GAINPUT})
# target_compile_definitions(gainputstatic PUBLIC -x -objective-c++ -fobjc-arc)
# gainputstatic
set(GAINPUT_BUILD_STATIC ON CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_BUILD_SHARED OFF CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_SAMPLES OFF CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_TESTS OFF CACHE INTERNAL "gainput: forced subdirectory option")
mark_as_advanced(GAINPUT_BUILD_STATIC GAINPUT_BUILD_SHARED GAINPUT_SAMPLES GAINPUT_TESTS APPKIT FOUNDATION GAME_CONTROLLER IOKIT)
add_subdirectory(Common_3/ThirdParty/OpenSource/gainput)
target_compile_options(gainputstatic PUBLIC ${TF_OBJC_FLAGS})

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
	Common_3/ThirdParty/OpenSource/zip/zip.cpp

	# basisu
	Common_3/ThirdParty/OpenSource/basis_universal/transcoder/basisu_transcoder.cpp
	
	# EAStdC
	Common_3/ThirdParty/OpenSource/EASTL/EAStdC/EAMemory.cpp
	Common_3/ThirdParty/OpenSource/EASTL/EAStdC/EASprintf.cpp
	
	# EASTL
	Common_3/ThirdParty/OpenSource/EASTL/allocator_forge.cpp
	Common_3/ThirdParty/OpenSource/EASTL/assert.cpp
	Common_3/ThirdParty/OpenSource/EASTL/fixed_pool.cpp
	Common_3/ThirdParty/OpenSource/EASTL/hashtable.cpp
	Common_3/ThirdParty/OpenSource/EASTL/intrusive_list.cpp
	Common_3/ThirdParty/OpenSource/EASTL/numeric_limits.cpp
	Common_3/ThirdParty/OpenSource/EASTL/red_black_tree.cpp
	Common_3/ThirdParty/OpenSource/EASTL/string.cpp
	Common_3/ThirdParty/OpenSource/EASTL/thread_support.cpp
	
	# rmem
	Common_3/ThirdParty/OpenSource/rmem/src/rmem_get_module_info.cpp
	Common_3/ThirdParty/OpenSource/rmem/src/rmem_hook.cpp
	Common_3/ThirdParty/OpenSource/rmem/src/rmem_lib.cpp

	# TinyEXR
	Common_3/ThirdParty/OpenSource/TinyEXR/tinyexr.h
	Common_3/ThirdParty/OpenSource/TinyEXR/tinyexr.cpp
	
	# OS / Camera
	Common_3/OS/Camera/CameraController.cpp
	
	# OS / Core
	Common_3/OS/Core/Atomics.h
	Common_3/OS/Core/Compiler.h
	Common_3/OS/Core/GPUConfig.h
	Common_3/OS/Core/RingBuffer.h
	Common_3/OS/Core/ThreadSystem.h
	Common_3/OS/Core/ThreadSystem.cpp
	Common_3/OS/Core/Timer.cpp
	
	# OS / FileSystem
	Common_3/OS/FileSystem/FileSystem.cpp
	Common_3/OS/FileSystem/SystemRun.cpp
	
	# OS / Input
	Common_3/OS/Input/InputSystem.cpp
	
	# OS / Interfaces
	Common_3/OS/Interfaces/IApp.h
	Common_3/OS/Interfaces/ICameraController.h
	Common_3/OS/Interfaces/IFileSystem.h
	Common_3/OS/Interfaces/IInput.h
	Common_3/OS/Interfaces/ILog.h
	Common_3/OS/Interfaces/IMemory.h
	Common_3/OS/Interfaces/IMiddleware.h
	Common_3/OS/Interfaces/IOperatingSystem.h
	Common_3/OS/Interfaces/IProfiler.h
	Common_3/OS/Interfaces/IThread.h
	Common_3/OS/Interfaces/ITime.h
	
	# OS / Logging
	Common_3/OS/Logging/Log.h
	Common_3/OS/Logging/Log.cpp
	
	# OS / Math
	Common_3/OS/Math/MathTypes.h
	
	# OS / MemoryTracking
	Common_3/OS/MemoryTracking/MemoryTracking.cpp
	
	# Middleware / Animation
	# Middleware_3/Animation/AnimatedObject.h
	# Middleware_3/Animation/AnimatedObject.cpp
	# Middleware_3/Animation/Animation.h
	# Middleware_3/Animation/Animation.cpp
	# Middleware_3/Animation/Clip.h
	# Middleware_3/Animation/Clip.cpp
	# Middleware_3/Animation/ClipController.h
	# Middleware_3/Animation/ClipController.cpp
	# Middleware_3/Animation/ClipMask.h
	# Middleware_3/Animation/ClipMask.cpp
	# Middleware_3/Animation/Rig.h
	# Middleware_3/Animation/Rig.cpp
	# Middleware_3/Animation/SkeletonBatcher.h
	# Middleware_3/Animation/SkeletonBatcher.cpp
	
	# Middleware / ParallelPrimitives
	$<${TF_PLATFORM_OSX}:Middleware_3/ParallelPrimitives/ParallelPrimitives.h>
	$<${TF_PLATFORM_OSX}:Middleware_3/ParallelPrimitives/ParallelPrimitives.cpp>

	# Middleware / ECS
	Middleware_3/ECS/BaseComponent.h
	Middleware_3/ECS/BaseComponent.cpp
	Middleware_3/ECS/ComponentRepresentation.h
	Middleware_3/ECS/ComponentRepresentation.cpp
	Middleware_3/ECS/EntityManager.h
	Middleware_3/ECS/EntityManager.cpp

	# Middleware / Text
	Middleware_3/Text/Fontstash.h
	Middleware_3/Text/Fontstash.cpp
	
	# OS / Middleware / UI
	Middleware_3/UI/AppUI.h
	Middleware_3/UI/AppUI.cpp
	Middleware_3/UI/ImguiGUIDriver.cpp
	
	# OpenSource / imgui
	Common_3/ThirdParty/OpenSource/imgui/imconfig.h
	Common_3/ThirdParty/OpenSource/imgui/imgui.h
	Common_3/ThirdParty/OpenSource/imgui/imgui.cpp
	Common_3/ThirdParty/OpenSource/imgui/imgui_demo.cpp
	Common_3/ThirdParty/OpenSource/imgui/imgui_draw.cpp
	Common_3/ThirdParty/OpenSource/imgui/imgui_internal.h
	Common_3/ThirdParty/OpenSource/imgui/imgui_widgets.cpp
	
	# OS / Profiler
	Common_3/OS/Profiler/GpuProfiler.h
	Common_3/OS/Profiler/GpuProfiler.cpp
	Common_3/OS/Profiler/ProfilerBase.h
	Common_3/OS/Profiler/ProfilerBase.cpp
	Common_3/OS/Profiler/ProfilerHTML.h
	Common_3/OS/Profiler/ProfilerWidgetsUI.cpp

	# OS / Windows
	$<${TF_PLATFORM_WINDOWS}:Common_3/OS/Windows/WindowsBase.cpp>
	$<${TF_PLATFORM_WINDOWS}:Common_3/OS/Windows/WindowsFileSystem.cpp>
	$<${TF_PLATFORM_WINDOWS}:Common_3/OS/Windows/WindowsLog.cpp>
	$<${TF_PLATFORM_WINDOWS}:Common_3/OS/Windows/WindowsStackTraceDump.h>
	$<${TF_PLATFORM_WINDOWS}:Common_3/OS/Windows/WindowsStackTraceDump.cpp>
	$<${TF_PLATFORM_WINDOWS}:Common_3/OS/Windows/WindowsThread.cpp>
	$<${TF_PLATFORM_WINDOWS}:Common_3/OS/Windows/WindowsTime.cpp>

	# OS / OSX
	$<${TF_PLATFORM_OSX}:Common_3/OS/FileSystem/UnixFileSystem.cpp>
	$<${TF_PLATFORM_OSX}:Common_3/OS/Darwin/CocoaFileSystem.mm>
	$<${TF_PLATFORM_OSX}:Common_3/OS/Darwin/DarwinLog.cpp>
	$<${TF_PLATFORM_OSX}:Common_3/OS/Darwin/DarwinThread.cpp>
	$<${TF_PLATFORM_OSX}:Common_3/OS/Darwin/macOSBase.mm>

	# OS / iOS
	$<${TF_PLATFORM_IOS}:Common_3/OS/Darwin/iOSBase.mm>

	# OS / Linux
	$<${TF_PLATFORM_LINUX}:Common_3/OS/FileSystem/UnixFileSystem.cpp>
	$<${TF_PLATFORM_LINUX}:Common_3/OS/Linux/LinuxBase.cpp>
	$<${TF_PLATFORM_LINUX}:Common_3/OS/Linux/LinuxFileSystem.cpp>
	$<${TF_PLATFORM_LINUX}:Common_3/OS/Linux/LinuxLog.cpp>
	$<${TF_PLATFORM_LINUX}:Common_3/OS/Linux/LinuxThread.cpp>
	$<${TF_PLATFORM_LINUX}:Common_3/OS/Linux/LinuxTime.cpp>
)

# the unified source of everything outside of the main application
set(TF_SRC_UNITY_BUILD
	${TF_SRC_SPIRVTOOLS}
	${TF_SRC_OS}
	${TF_SRC_RENDERER}
)
add_library(TheForge ${TF_SRC_UNITY_BUILD})
target_compile_definitions(TheForge PUBLIC ${TF_RENDERER})
target_compile_options(TheForge PUBLIC ${TF_ARC_FLAGS})
set_target_properties(TheForge
	PROPERTIES
		XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
		XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_WEAK YES
)
target_link_libraries(TheForge
	gainputstatic
	$<${TF_PLATFORM_LINUX}:dl>
)

# mark certain files as objective-c / objective-c++
set(TF_SRC_OBJC
	${TF_DIR_OSS}/gainput/lib/source/gainput/mouse/GainputInputDeviceMouse.cpp
	Common_3/OS/Input/InputSystem.cpp
	Common_3/OS/Profiler/GpuProfiler.cpp
	Common_3/OS/Profiler/ProfilerBase.cpp
	Common_3/OS/Profiler/ProfilerWidgetsUI.cpp
	Common_3/Renderer/CommonShaderReflection.cpp
	Common_3/Renderer/ResourceLoader.cpp
	Middleware_3/Animation/SkeletonBatcher.cpp
	Middleware_3/Text/Fontstash.cpp
	Middleware_3/UI/AppUI.cpp
	Middleware_3/UI/ImguiGUIDriver.cpp
)
set(TF_SRC_ARC
	Common_3/OS/Darwin/macOSBase.mm
)
if (TF_PLATFORM_OSX)
	set_source_files_properties(${TF_SRC_OBJC} PROPERTIES COMPILE_FLAGS "-x objective-c++")
	# set_source_files_properties(${TF_SRC_ARC} PROPERTIES COMPILE_FLAGS "-fobjc-arc")
endif()

# drop each source file into its own folder in the IDE
foreach(tf_source IN ITEMS ${TF_SRC_UNITY_BUILD})
    get_filename_component(tf_path "${tf_source}" PATH)
	string(REGEX REPLACE "^.*\/([^\/]+)$" "\\1" tf_group_path "${tf_path}")
    source_group("${tf_group_path}" FILES "${tf_source}")
endforeach()

# main application - resources
set(TF_SRC_MAIN_RES)

# main application - common
set(TF_SRC_MAIN
	${TF_SRC_UNITY_BUILD}

	Examples_3/Visibility_Buffer/src/Geometry.h
	Examples_3/Visibility_Buffer/src/Geometry.cpp

	Examples_3/Visibility_Buffer/src/Visibility_Buffer.cpp
)

if (TF_PLATFORM_OSX)
	find_library(TF_LIB_METAL Metal)
	find_library(TF_LIB_METALKIT MetalKit)
	find_library(TF_LIB_METALPS MetalPerformanceShaders)
	find_library(TF_LIB_GRAPHICS CoreGraphics)
	find_library(TF_LIB_IOKIT IOKit)
	find_library(TF_LIB_APPKIT AppKit)
	find_library(TF_LIB_QUARTZ QuartzCore)
	find_library(TF_LIB_CONTROLLER GameController)
endif()
set(TF_LINK_LIBS
	TheForge

	# Windows
	$<${TF_PLATFORM_WINDOWS}:Common_3/ThirdParty/OpenSource/ags/ags_lib/lib/amd_ags_x64.lib>
	$<${TF_PLATFORM_WINDOWS}:Common_3/ThirdParty/OpenSource/nvapi/amd64/nvapi64.lib>

	# Linux
	$<${TF_PLATFORM_LINUX}:pthread>
	$<${TF_PLATFORM_LINUX}:X11>
	$<${TF_PLATFORM_LINUX}:Xrandr>
	#$<${TF_PLATFORM_LINUX}:dl>

	# OSX
	$<${TF_PLATFORM_OSX}:${TF_LIB_METAL}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_METALKIT}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_METALPS}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_IOKIT}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_GRAPHICS}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_QUARTZ}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_APPKIT}>
	$<${TF_PLATFORM_OSX}:${TF_LIB_CONTROLLER}>

	# Vulkan
	$<${TF_RENDERER_VULKAN}:Vulkan::Vulkan>

	# DX - Common
	$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:Common_3/ThirdParty/OpenSource/DirectXShaderCompiler/lib/x64/dxcompiler.lib>
	$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:Common_3/ThirdParty/OpenSource/winpixeventruntime/bin/WinPixEventRuntime.lib>
	#$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:dxgi.lib>
	#$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:d3dcompiler.lib>
)

set(TF_COPY_DLLS
	$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:Common_3/ThirdParty/OpenSource/DirectXShaderCompiler/bin/x64/dxcompiler.dll>
	$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:Common_3/ThirdParty/OpenSource/winpixeventruntime/bin/WinPixEventRuntime.dll>
)

#
# runtime

# Visibility_Buffer
set(TF_RESDIR_TARGET $<TARGET_FILE_DIR:${TF_TARGET_NAME}>)
#if (TF_PLATFORM_OSX)
#	set(TF_RESDIR_TARGET ${TF_RESDIR_TARGET}/../Resources)
#	set(TF_SRC_MAIN_RES
#		"Examples_3/Visibility_Buffer/macOS Xcode/Visibility_Buffer/Base.lproj/MainMenu.xib"
#	)
#	add_executable(${TF_TARGET_NAME} MACOSX_BUNDLE ${TF_SRC_MAIN} ${TF_SRC_MAIN_RES})
#	target_link_libraries(${TF_TARGET_NAME} ${TF_OSX_FRAMEWORKS})
#	set(TF_BUNDLE_IDENTIFIER com.confetti.Examples.VisibilityBuffer)
#	set_target_properties(${TF_TARGET_NAME} 
#		PROPERTIES
#		MACOSX_BUNDLE_INFO_PLIST 
#			"${CMAKE_CURRENT_SOURCE_DIR}/CMake/Info.plist.in"
#		RESOURCE 
#			${TF_SRC_MAIN_RES}
#	)
#else()
#	add_executable(${TF_TARGET_NAME} ${TF_SRC_MAIN})
#endif()
#target_compile_definitions(${TF_TARGET_NAME} PUBLIC ${TF_RENDERER})
#target_link_libraries(${TF_TARGET_NAME} OS ${TF_LINK_LIBS})

#
# handle Art.zip

set(TF_ART_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Art)
set(TF_ART_FILE ${TF_ART_DIR}.zip)
if (NOT EXISTS ${TF_ART_FILE})
	file(DOWNLOAD http://www.conffx.com/Art.zip ${TF_ART_FILE} SHOW_PROGRESS TLS_VERIFY ON)
endif()

if (NOT IS_DIRECTORY ${TF_ART_DIR})
	if (TF_PLATFORM_WINDOWS)
		execute_process(
			COMMAND
				${CMAKE_CURRENT_SOURCE_DIR}/Tools/7z x Art.zip -y
			WORKING_DIRECTORY
				${CMAKE_CURRENT_SOURCE_DIR}
		)
	else()
		execute_process(
			COMMAND
				unzip Art.zip
			WORKING_DIRECTORY
				${CMAKE_CURRENT_SOURCE_DIR}
		)
	endif()
endif()

#
# postbuild copy

# postbuild dll copy
if (0)
foreach(tf_bin IN ITEMS ${TF_COPY_DLLS})
	add_custom_command(TARGET ${TF_TARGET_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${tf_bin} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>)
endforeach()
endif()
# var setup
set(TF_DIR_ART ${CMAKE_CURRENT_SOURCE_DIR}/Art/SanMiguel_3)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Visibility_Buffer)
set(TF_DIR_MW ${CMAKE_CURRENT_SOURCE_DIR}/Middleware_3)
file(GLOB TF_SRC_MESHES ${TF_DIR_ART}/Meshes/*)
file(GLOB TF_SRC_TEXTURES ${TF_DIR_ART}/Textures/*.dds)
file(GLOB TF_SRC_FONTS ${TF_DIR_PROJ}/Resources/Fonts/TitilliumText/*)
file(GLOB TF_SRC_GPUCFGS ${TF_DIR_PROJ}/src/GPUCfg/*)
file(GLOB TF_SRC_SHADERS ${TF_DIR_PROJ}/src/Shaders/${TF_RENDERER_DIR}/*)
file(GLOB TF_UI_SHADERS ${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*)
file(GLOB TF_TEXT_SHADERS ${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*)
if (0)
# main copy
add_custom_command(
	TARGET ${TF_TARGET_NAME}
	POST_BUILD
	
	COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Meshes
	COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Textures
	COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Fonts
	COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Fonts/TitilliumText
	COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Shaders
	COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/GPUCfg
	
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_MESHES} ${TF_RESDIR_TARGET}/Meshes
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_TEXTURES} ${TF_RESDIR_TARGET}/Textures
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_FONTS} ${TF_RESDIR_TARGET}/Fonts/TitilliumText
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_GPUCFGS} ${TF_RESDIR_TARGET}/GPUCfg
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_SHADERS} ${TF_RESDIR_TARGET}/Shaders
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_UI_SHADERS} ${TF_RESDIR_TARGET}/Shaders
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_TEXT_SHADERS} ${TF_RESDIR_TARGET}/Shaders
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_DIR_PROJ}/Resources/cameraPath.bin ${TF_RESDIR_TARGET}/cameraPath.bin
)
endif()
#
# Unit Tests

# 01_Transformations
set(TF_TARGET_NAME 01_Transformations)
set(TF_DIR_ART ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/src/${TF_TARGET_NAME})
set(TF_DIR_MW ${CMAKE_CURRENT_SOURCE_DIR}/Middleware_3)
file(GLOB TF_SRC_MESHES ${TF_DIR_ART}/Meshes/*)
file(GLOB TF_SRC_SKY ${TF_DIR_ART}/Textures/Skybox_*.dds)
file(GLOB TF_SRC_CPAD ${TF_DIR_ART}/Textures/circlepad.dds)
file(GLOB TF_SRC_TEXTURES ${TF_SRC_SKY} ${TF_SRC_CPAD})
file(GLOB TF_SRC_TTF ${TF_DIR_PROJ}/Resources/Fonts/*.ttf)
file(GLOB TF_SRC_OTF ${TF_DIR_PROJ}/Resources/Fonts/*.otf)
file(GLOB TF_SRC_GPUCFGS ${TF_DIR_PROJ}/GPUCfg/*)
file(GLOB TF_SRC_SHADERS ${TF_DIR_PROJ}/Shaders/${TF_RENDERER_DIR}/*)
file(GLOB TF_UI_SHADERS ${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*)
file(GLOB TF_TEXT_SHADERS ${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*)
set(TF_SRC_TARGET
	${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
	$<${TF_PLATFORM_OSX}:Common_3/OS/Darwin/macOSAppDelegate.h>
	$<${TF_PLATFORM_OSX}:Common_3/OS/Darwin/macOSAppDelegate.m>
	$<${TF_PLATFORM_IOS}:Common_3/OS/Darwin/iOSAppDelegate.h>
	$<${TF_PLATFORM_IOS}:Common_3/OS/Darwin/iOSAppDelegate.m>
)
set(TF_RESDIR_TARGET $<TARGET_FILE_DIR:${TF_TARGET_NAME}>)
if (TF_PLATFORM_OSX)
	set(TF_RESDIR_TARGET ${TF_RESDIR_TARGET}/../Resources)
	set(TF_DIR_XCODEPROJ "Examples_3/Unit_Tests/macOS Xcode/${TF_TARGET_NAME}/${TF_TARGET_NAME}")
	set(TF_SRC_RES ${TF_DIR_XCODEPROJ}/Base.lproj/MainMenu.xib)
	add_executable(${TF_TARGET_NAME} MACOSX_BUNDLE ${TF_SRC_TARGET} ${TF_SRC_RES})
	set(TF_BUNDLE_IDENTIFIER com.confetti.Unit-Tests.01-Transformations)
	set_target_properties(${TF_TARGET_NAME} 
		PROPERTIES
		MACOSX_BUNDLE_INFO_PLIST 
			"${CMAKE_CURRENT_SOURCE_DIR}/CMake/Info.plist.in"
		RESOURCE 
			${TF_SRC_RES}
	)
	target_sources(${TF_TARGET_NAME} PRIVATE ${TF_DIR_XCODEPROJ}/Assets.xcassets)
	set_source_files_properties(${TF_DIR_XCODEPROJ}/Assets.xcassets PROPERTIES
		MACOSX_PACKAGE_LOCATION Resources
	)
else()
	add_executable(${TF_TARGET_NAME} ${TF_SRC_TARGET})
endif()
target_compile_options(${TF_TARGET_NAME} PUBLIC ${TF_OBJC_FLAGS} ${TF_ARC_FLAGS})
target_compile_definitions(${TF_TARGET_NAME} PUBLIC ${TF_RENDERER} ZIP_STATIC)
target_link_libraries(${TF_TARGET_NAME} ${TF_LINK_LIBS})
add_custom_command(
	TARGET ${TF_TARGET_NAME}
	POST_BUILD
	
	COMMAND echo "${TF_RESDIR_TARGET}"
	COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Textures
	COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Fonts
	COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Shaders
	COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/GPUCfg
	
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_TEXTURES} ${TF_RESDIR_TARGET}/Textures
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_GPUCFGS} ${TF_RESDIR_TARGET}/GPUCfg
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_SHADERS} ${TF_RESDIR_TARGET}/Shaders
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_UI_SHADERS} ${TF_RESDIR_TARGET}/Shaders
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_TEXT_SHADERS} ${TF_RESDIR_TARGET}/Shaders
)
set(TF_FONT_DIRS)
file(GLOB tf_tmp_dirs ${TF_DIR_ART}/Fonts/*)
foreach(tf_tmp_dir IN ITEMS ${tf_tmp_dirs})
	if (IS_DIRECTORY ${tf_tmp_dir})
		file(GLOB tf_tmp_glob ${tf_tmp_dir}/*)
		get_filename_component(tf_out_dir ${tf_tmp_dir} NAME)
		add_custom_command(TARGET ${TF_TARGET_NAME} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Fonts/${tf_out_dir}
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${tf_tmp_glob} ${TF_RESDIR_TARGET}/Fonts/${tf_out_dir}
		)
	endif()
endforeach()
