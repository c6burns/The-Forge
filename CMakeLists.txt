cmake_minimum_required(VERSION 3.15)
set(TF_PROJ_NAME TheForge)
project(${TF_PROJ_NAME} LANGUAGES C CXX)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/CMake)
include(tf_functions)

#
# dependencies

# gtest/gmock
set(BUILD_GMOCK ON CACHE INTERNAL "gtest: forced subdirectory option")
set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "gtest: forced subdirectory option")
set(INSTALL_GTEST OFF CACHE INTERNAL "gtest: forced subdirectory option")
mark_as_advanced(GAINPUT_BUILD_STATIC GAINPUT_BUILD_SHARED GAINPUT_SAMPLES GAINPUT_TESTS APPKIT FOUNDATION GAME_CONTROLLER IOKIT)
add_subdirectory(${TF_DIR_OSS}/googletest)

# gainput
set(GAINPUT_BUILD_STATIC ON CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_BUILD_SHARED OFF CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_SAMPLES OFF CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_TESTS OFF CACHE INTERNAL "gainput: forced subdirectory option")
mark_as_advanced(GAINPUT_BUILD_STATIC GAINPUT_BUILD_SHARED GAINPUT_SAMPLES GAINPUT_TESTS APPKIT FOUNDATION GAME_CONTROLLER IOKIT)
add_subdirectory(${TF_DIR_OSS}/gainput)
target_compile_options(gainputstatic PUBLIC ${TF_OBJC_FLAGS})
target_link_libraries(gainputstatic $<${TF_PLATFORM_WINDOWS}:xinput.lib>)

# lua
file(GLOB TF_SRC_LUA Common_3/ThirdParty/OpenSource/lua-5.3.5/src/*)
add_library(lua ${TF_SRC_LUA})

#
# sources

# renderer
set(TF_SRC_RENDERER_COMMON
	Common_3/Renderer/IRay.h
	Common_3/Renderer/IRenderer
	Common_3/Renderer/IResourceLoader
	Common_3/Renderer/IShaderReflection
	Common_3/Renderer/CommonShaderReflection.cpp
	Common_3/Renderer/ResourceLoader.cpp
)
source_group("RendererCommon" FILES ${TF_SRC_RENDERER_METAL})
set(TF_SRC_RENDERER_D3D12 
	Common_3/Renderer/Direct3D12/Direct3D12CapBuilder.h
	Common_3/Renderer/Direct3D12/Direct3D12Hooks.h
	Common_3/Renderer/Direct3D12/Direct3D12.cpp
	Common_3/Renderer/Direct3D12/Direct3D12Hooks.cpp
	Common_3/Renderer/Direct3D12/Direct3D12Raytracing.cpp
	Common_3/Renderer/Direct3D12/Direct3D12ShaderReflection.cpp
)
source_group("RendererVulkan" FILES ${TF_SRC_RENDERER_METAL})
set(TF_SRC_RENDERER_VULKAN 
	Common_3/Renderer/Vulkan/VulkanCapsBuilder.h
	Common_3/Renderer/Vulkan/Vulkan.cpp
	Common_3/Renderer/Vulkan/VulkanRaytracing.cpp
	Common_3/Renderer/Vulkan/VulkanShaderReflection.cpp
)
source_group("RendererMetal" FILES ${TF_SRC_RENDERER_METAL})
set(TF_SRC_RENDERER_METAL 
	Common_3/Renderer/Metal/MetalAvailabilityMacros.h
	Common_3/Renderer/Metal/MetalCapBuilder.h
	Common_3/Renderer/Metal/MetalMemoryAllocator.h
	Common_3/Renderer/Metal/MetalMemoryAllocatorImpl.h
	Common_3/Renderer/Metal/MetalRaytracing.mm
	Common_3/Renderer/Metal/MetalRenderer.mm
	Common_3/Renderer/Metal/MetalShaderReflection.mm
)
source_group("RendererDX12" FILES ${TF_SRC_RENDERER_METAL})
set (TF_SRC_RENDERER
	${TF_SRC_RENDERER_COMMON}
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
source_group("SpirvTools" FILES ${TF_SRC_SPIRVTOOLS})

# ozzanimation - dependency
include_directories(${TF_DIR_OSS}/ozz-animation/src ${TF_DIR_OSS}/ozz-animation/include)
set(TF_SRC_OZZ_OFFLINE
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
)
set(TF_SRC_OZZ_RUNTIME
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
)
set(TF_SRC_OZZ_BASE
	${TF_DIR_OSS}/ozz-animation/src/base/containers/string_archive.cc
	${TF_DIR_OSS}/ozz-animation/src/base/io/archive.cc
	${TF_DIR_OSS}/ozz-animation/src/base/maths/math_archive.cc
	${TF_DIR_OSS}/ozz-animation/src/base/maths/simd_math_archive.cc
	${TF_DIR_OSS}/ozz-animation/src/base/maths/soa_math_archive.cc
	${TF_DIR_OSS}/ozz-animation/src/base/memory/allocator.cc
	${TF_DIR_OSS}/ozz-animation/src/base/platform.cc
)
set(TF_SRC_OZZ
	${TF_SRC_OZZ_OFFLINE}
	${TF_SRC_OZZ_RUNTIME}
	${TF_SRC_OZZ_BASE}
)
source_group("offline" FILES ${TF_SRC_OZZ_OFFLINE})
source_group("runtime" FILES ${TF_SRC_OZZ_RUNTIME})
source_group("base" FILES ${TF_SRC_OZZ_BASE})
add_library(ozzanimation ${TF_SRC_OZZ})

# rmem - dependency
set(TF_SRC_RMEM
	Common_3/ThirdParty/OpenSource/rmem/src/rmem_get_module_info.cpp
	Common_3/ThirdParty/OpenSource/rmem/src/rmem_hook.cpp
	Common_3/ThirdParty/OpenSource/rmem/src/rmem_lib.cpp
)
add_library(rmem ${TF_SRC_RMEM})

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
	Middleware_3/Animation/AnimatedObject.h
	Middleware_3/Animation/AnimatedObject.cpp
	Middleware_3/Animation/Animation.h
	Middleware_3/Animation/Animation.cpp
	Middleware_3/Animation/Clip.h
	Middleware_3/Animation/Clip.cpp
	Middleware_3/Animation/ClipController.h
	Middleware_3/Animation/ClipController.cpp
	Middleware_3/Animation/ClipMask.h
	Middleware_3/Animation/ClipMask.cpp
	Middleware_3/Animation/Rig.h
	Middleware_3/Animation/Rig.cpp
	Middleware_3/Animation/SkeletonBatcher.h
	Middleware_3/Animation/SkeletonBatcher.cpp
	
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

	# OS / Middleware / LUA
	Middleware_3/LUA/LuaManager.h
	Middleware_3/LUA/LuaManagerCommon.h
	Middleware_3/LUA/LuaManagerImpl.h
	Middleware_3/LUA/LuaManager.cpp
	Middleware_3/LUA/LuaManagerImpl.cpp
	
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
# drop each OS source file into its own folder in the IDE
foreach(tf_source IN ITEMS ${TF_SRC_OS})
    get_filename_component(tf_path "${tf_source}" PATH)
	string(REGEX REPLACE "^.*\/([^\/]+)$" "\\1" tf_group_path "${tf_path}")
    source_group("${tf_group_path}" FILES "${tf_source}")
endforeach()

# unified source of everything outside executables
set(TF_SRC_COMBINED
	${TF_SRC_SPIRVTOOLS}
	${TF_SRC_OZZ}
	${TF_SRC_OS}
	${TF_SRC_RENDERER}
)

# add the main library target
add_library(${TF_PROJ_NAME} ${TF_SRC_COMBINED})
target_compile_definitions(${TF_PROJ_NAME} PUBLIC ${TF_RENDERER})
target_compile_options(${TF_PROJ_NAME} PUBLIC ${TF_ARC_FLAGS})
set_target_properties(${TF_PROJ_NAME}
	PROPERTIES
		XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
		XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_WEAK YES
)
target_link_libraries(${TF_PROJ_NAME}
	gainputstatic
	lua
	ozzanimation
	rmem
	$<${TF_RENDERER_VULKAN}:Vulkan::Vulkan>
	$<${TF_PLATFORM_LINUX}:dl>
)

# mark certain files as objective-c++
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
	$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:${TF_DIR_OSS}/DirectXShaderCompiler/lib/x64/dxcompiler.lib>
	$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:${TF_DIR_OSS}/winpixeventruntime/bin/WinPixEventRuntime.lib>
	#$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:dxgi.lib>
	#$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:d3dcompiler.lib>
)

set(TF_LINK_BINS
	$<${TF_PLATFORM_WINDOWS}:${TF_DIR_OSS}/ags/ags_lib/lib/amd_ags_x64.dll>
	$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:${TF_DIR_OSS}/DirectXShaderCompiler/bin/x64/dxcompiler.dll>
	$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:${TF_DIR_OSS}/winpixeventruntime/bin/WinPixEventRuntime.dll>
)

#
# runtimes

# Visibility_Buffer
set(TF_SRC_VBUF
	Examples_3/Visibility_Buffer/src/Geometry.h
	Examples_3/Visibility_Buffer/src/Geometry.cpp
	Examples_3/Visibility_Buffer/src/Visibility_Buffer.cpp
)
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

# var setup
set(TF_DIR_ART ${CMAKE_CURRENT_SOURCE_DIR}/Art)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Visibility_Buffer)
set(TF_DIR_MW ${CMAKE_CURRENT_SOURCE_DIR}/Middleware_3)
set(TF_DIR_FONT ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/UnitTestResources/Fonts)

# Visibility_Buffer
#set(TF_TARGET_NAME Visibility_Buffer)
#set(TF_DIR_RES ${CMAKE_CURRENT_SOURCE_DIR}/Art/SanMiguel_3)
#set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Visibility_Buffer)
#tf_add_executable(
#	TARGET ${TF_TARGET_NAME}
#	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
#	SOURCES ${TF_SRC_VBUF}
#	RESOURCES
#		${TF_DIR_RES}/Meshes/*
#		${TF_DIR_RES}/Textures/*.dds
#		${TF_DIR_PROJ}/Resources/Fonts/*
#		${TF_DIR_PROJ}/src/GPUCfg/*
#		${TF_DIR_PROJ}/src/Shaders/${TF_RENDERER_DIR}/*
#		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*
#		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*
#)
#tf_add_resource(${TF_TARGET_NAME} ${TF_DIR_PROJ}/Resources/cameraPath.bin $<TARGET_FILE_DIR:${TF_TARGET_NAME}>)

#
# Tests

set(TF_TARGET_NAME 01_Transformations)
set(TF_DIR_RES ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/src/${TF_TARGET_NAME})
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES ${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_DIR_RES}/Meshes/*
		${TF_DIR_RES}/Textures/Skybox_*.dds
		${TF_DIR_RES}/Textures/circlepad.dds
		${TF_DIR_PROJ}/GPUCfg/*
		${TF_DIR_PROJ}/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*
)

set(TF_TARGET_NAME 02_Compute)
set(TF_DIR_RES ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/src/${TF_TARGET_NAME})
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES ${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_DIR_PROJ}/GPUCfg/*
		${TF_DIR_PROJ}/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*
)

set(TF_TARGET_NAME 03_MultiThread)
set(TF_DIR_RES ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/src/${TF_TARGET_NAME})
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES ${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_DIR_RES}/Textures/Skybox_*.dds
		${TF_DIR_RES}/Textures/Palette_*.dds
		${TF_DIR_RES}/Textures/circlepad.dds
		${TF_DIR_PROJ}/GPUCfg/*
		${TF_DIR_PROJ}/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*
)

set(TF_TARGET_NAME 04_ExecuteIndirect)
set(TF_DIR_RES ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/src/${TF_TARGET_NAME})
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES
		${TF_DIR_MW}/PaniniProjection/Panini.cpp
		${TF_DIR_PROJ}/Random.h
		${TF_DIR_PROJ}/AsteroidSim.cpp
		${TF_DIR_PROJ}/simplexnoise1234.cpp
		${TF_DIR_PROJ}/TextureGen.cpp
		${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_DIR_RES}/Textures/Skybox_*.dds
		${TF_DIR_RES}/Textures/circlepad.dds
		${TF_DIR_PROJ}/GPUCfg/*
		${TF_DIR_PROJ}/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/PaniniProjection/Shaders/${TF_RENDERER_DIR}/*
)

set(TF_TARGET_NAME 05_FontRendering)
set(TF_DIR_RES ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/src/${TF_TARGET_NAME})
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES ${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_DIR_PROJ}/GPUCfg/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*
)

set(TF_TARGET_NAME 06_MaterialPlayground)
set(TF_DIR_RES ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/src/${TF_TARGET_NAME})
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES ${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_DIR_RES}/Meshes/*.gltf
		${TF_DIR_RES}/Meshes/*.bin
		${TF_DIR_RES}/Textures/Skybox_*.dds
		${TF_DIR_RES}/Textures/circlepad.dds
		${TF_DIR_RES}/Textures/LA_Helipad.dds
		${TF_DIR_PROJ}/GPUCfg/*
		${TF_DIR_PROJ}/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*
)
tf_add_resource(${TF_TARGET_NAME} ${TF_DIR_ART}/Hair $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Meshes/Hair)
tf_add_resource(${TF_TARGET_NAME} ${TF_DIR_PROJ}/*.lua $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Scripts)
tf_add_resource(${TF_TARGET_NAME} ${TF_DIR_ART}/PBR $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Textures/PBR/)

set(TF_TARGET_NAME 07_Tessellation)
set(TF_DIR_RES ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/src/${TF_TARGET_NAME})
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES
		${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_DIR_RES}/Textures/Skybox_*.dds
		${TF_DIR_RES}/Textures/circlepad.dds
		${TF_DIR_PROJ}/GPUCfg/*
		${TF_DIR_PROJ}/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*
)

set(TF_TARGET_NAME 08_GltfViewer)
set(TF_DIR_RES ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/src/${TF_TARGET_NAME})
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES
		${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_DIR_RES}/Meshes/*.gltf
		${TF_DIR_RES}/Meshes/*.bin
		${TF_DIR_RES}/Textures/*.basis
		${TF_DIR_RES}/Textures/Skybox_*.dds
		${TF_DIR_RES}/Textures/circlepad.dds
		${TF_DIR_PROJ}/GPUCfg/*
		${TF_DIR_PROJ}/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*
)

set(TF_TARGET_NAME 09_LightShadowPlayground)
set(TF_DIR_RES ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/src/${TF_TARGET_NAME})
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES
		${TF_DIR_PROJ}/Geometry.cpp
		${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_ART_DIR}/SanMiguel_3/Meshes/*
		${TF_ART_DIR}/SanMiguel_3/Textures/*.dds
		${TF_DIR_PROJ}/GPUCfg/*
		${TF_DIR_PROJ}/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*
)

if (0) # skip this one for now
set(TF_TARGET_NAME 10_ScreenSpaceReflections)
set(TF_DIR_RES ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Unit_Tests/src/${TF_TARGET_NAME})
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES
		${TF_DIR_PROJ}/Geometry.cpp
		${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_ART_DIR}/Sponza/Meshes/*
		${TF_DIR_RES}/Textures/LA_Helipad.dds
		${TF_DIR_PROJ}/GPUCfg/*
		${TF_DIR_PROJ}/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_DIR}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_DIR}/*
)
endif()

# playground
set(TF_TARGET_NAME playground)
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	TEST YES
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES ${TF_DIR_TESTS}/${TF_TARGET_NAME}.cpp
)
target_link_libraries(${TF_TARGET_NAME} gtest gtest_main gmock gmock_main)
