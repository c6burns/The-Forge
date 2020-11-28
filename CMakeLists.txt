cmake_minimum_required(VERSION 3.1.0)
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
set(TF_PLATFORM_LINUX 0)
if (APPLE)
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

message("Building: ${TF_RENDERER} / ${TF_RENDERER_DIR}")


#
# sources

set(TF_SRC_RENDERER_COMMON Common_3/Renderer/IRay.h
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

# OS library - Windows
set(TF_SRC_OS_WIN
	Common_3/OS/Windows/WindowsBase.cpp
	Common_3/OS/Windows/WindowsFileSystem.cpp
	Common_3/OS/Windows/WindowsLog.cpp
	Common_3/OS/Windows/WindowsStackTraceDump.h
	Common_3/OS/Windows/WindowsStackTraceDump.cpp
	Common_3/OS/Windows/WindowsThread.cpp
	Common_3/OS/Windows/WindowsTime.cpp
)

# OS library
set(TF_SRC_OS
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
	
	# OS / Middleware / Animation
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
	
	# OS / Middleware / Text
	Middleware_3/Text/Fontstash.h
	Middleware_3/Text/Fontstash.cpp
	
	# OS / Middleware / imgui
	Common_3/ThirdParty/OpenSource/imgui/imconfig.h
	Common_3/ThirdParty/OpenSource/imgui/imgui.h
	Common_3/ThirdParty/OpenSource/imgui/imgui.cpp
	Common_3/ThirdParty/OpenSource/imgui/imgui_demo.cpp
	Common_3/ThirdParty/OpenSource/imgui/imgui_draw.cpp
	Common_3/ThirdParty/OpenSource/imgui/imgui_internal.h
	Common_3/ThirdParty/OpenSource/imgui/imgui_widgets.cpp
	
	# OS / Middleware / UI
	Middleware_3/UI/AppUI.h
	Middleware_3/UI/AppUI.cpp
	Middleware_3/UI/ImguiGUIDriver.cpp
	
	# OS / Profiler
	Common_3/OS/Profiler/GpuProfiler.h
	Common_3/OS/Profiler/GpuProfiler.cpp
	Common_3/OS/Profiler/ProfilerBase.h
	Common_3/OS/Profiler/ProfilerBase.cpp
	Common_3/OS/Profiler/ProfilerHTML.h
	Common_3/OS/Profiler/ProfilerWidgetsUI.cpp
)

# OS library - Darwin
set(TF_SRC_OS_OSX
	Common_3/OS/FileSystem/UnixFileSystem.cpp
	Common_3/OS/Darwin/CocoaFileSystem.mm
	Common_3/OS/Darwin/DarwinLog.cpp
	Common_3/OS/Darwin/DarwinThread.cpp
	Common_3/OS/Darwin/macOSBase.mm
)

# OS library - iOS
set(TF_SRC_OS_IOS
	Common_3/OS/Darwin/iOSAppDelegate.h
	Common_3/OS/Darwin/iOSAppDelegate.m
	Common_3/OS/Darwin/iOSBase.mm
)

# OS library - Linux
set(TF_SRC_OS_LIN
	Common_3/OS/FileSystem/UnixFileSystem.cpp
	Common_3/OS/Linux/LinuxBase.cpp
	Common_3/OS/Linux/LinuxFileSystem.cpp
	Common_3/OS/Linux/LinuxLog.cpp
	Common_3/OS/Linux/LinuxThread.cpp
	Common_3/OS/Linux/LinuxTime.cpp
)

# main application - resources
set(TF_SRC_MAIN_RES)

# main application - common
set(TF_SRC_MAIN_COMMON
	Examples_3/Visibility_Buffer/src/Geometry.h
	Examples_3/Visibility_Buffer/src/Geometry.cpp
	$<${TF_PLATFORM_OSX}:Middleware_3/ParallelPrimitives/ParallelPrimitives.cpp>
	$<${TF_PLATFORM_OSX}:Common_3/OS/Darwin/macOSAppDelegate.h>
	$<${TF_PLATFORM_OSX}:Common_3/OS/Darwin/macOSAppDelegate.m>
)

# main application
set(TF_SRC_MAIN ${TF_SRC_MAIN_COMMON}
	Examples_3/Visibility_Buffer/src/Visibility_Buffer.cpp
)

# libs common to all windows render systems
set(TF_LIB_EXTRA)
set(TF_BIN_EXTRA)

# rendersystem extra libs
set(TF_LIB_RENDERDEPS
	$<${TF_PLATFORM_WINDOWS}:${TF_LIB_RENDERDEPS_WIN}>
	$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:${TF_LIB_RENDERDEPS_WIN_DX}>
)
set(TF_LIB_RENDERDEPS_WIN
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/ags/ags_lib/lib/amd_ags_x64.lib
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/nvapi/amd64/nvapi64.lib
)
set(TF_LIB_RENDERDEPS_WIN_DX
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/DirectXShaderCompiler/lib/x64/dxcompiler.lib
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/winpixeventruntime/bin/WinPixEventRuntime.lib
	dxgi.lib
	d3dcompiler.lib
)

# rendersystem extra dlls
set(TF_DLL_RENDERDEPS
	
)
set(TF_DLL_RENDERDEPS_WIN
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/ags/ags_lib/lib/amd_ags_x64.dll
)
set(TF_DLL_RENDERDEPS_WIN_DX
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/DirectXShaderCompiler/bin/x64/dxcompiler.dll
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/winpixeventruntime/bin/WinPixEventRuntime.dll
)

#
# runtime

# Visibility_Buffer
if (TF_PLATFORM_OSX)
	set(TF_SRC_MAIN_RES
		"Examples_3/Visibility_Buffer/macOS Xcode/Visibility_Buffer/Base.lproj/MainMenu.xib"
	)
	add_executable(${TF_TARGET_NAME} MACOSX_BUNDLE ${TF_SRC_MAIN} ${TF_SRC_MAIN_RES})
	target_link_libraries(${TF_TARGET_NAME}
		"-framework Foundation"
		"-framework AVFoundation"
		"-framework MetalPerformanceShaders"
		"-framework ModelIO"
		"-framework Metal"
		"-framework QuartzCore"
		"-framework IOKit"
		"-framework CoreGraphics"
		"-framework AppKit"
		"-framework MetalKit"
	)
	set_target_properties(${TF_TARGET_NAME} 
		PROPERTIES
		MACOSX_BUNDLE_INFO_PLIST 
			"${CMAKE_CURRENT_SOURCE_DIR}/Examples_3/Visibility_Buffer/macOS Xcode/Visibility_Buffer/Info.plist"
		RESOURCE 
			${TF_SRC_MAIN_RES}
	)
else()
	add_executable(${TF_TARGET_NAME} ${TF_SRC_MAIN})
endif()
# properties for this target are resolved after all other dependencies

#
# tools

# gainputstatic
set(GAINPUT_BUILD_STATIC ON CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_BUILD_SHARED OFF CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_SAMPLES OFF CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_TESTS OFF CACHE INTERNAL "gainput: forced subdirectory option")
mark_as_advanced(GAINPUT_BUILD_STATIC GAINPUT_BUILD_SHARED GAINPUT_SAMPLES GAINPUT_TESTS)
add_subdirectory(Common_3/ThirdParty/OpenSource/gainput)
target_compile_options(gainputstatic PUBLIC ${TF_OBJC_FLAGS})
target_compile_definitions(gainputstatic PUBLIC ${TF_RENDERER})
target_link_libraries(gainputstatic ${TF_LIB_XINPUT})
list(APPEND TF_LINK_LIBS gainputstatic)

# SpirvTools
add_library(SpirvTools ${TF_SRC_SPIRVTOOLS})
target_compile_definitions(SpirvTools PUBLIC ${TF_RENDERER})
list(APPEND TF_LINK_LIBS SpirvTools)

#
# OS (platform library)

if (TF_PLATFORM_OSX)
	list(APPEND TF_SRC_OS ${TF_SRC_OS_OSX})
elseif (TF_PLATFORM_LINUX)
	list(APPEND TF_SRC_OS ${TF_SRC_OS_LIN})
elseif (TF_PLATFORM_WINDOWS)
	list(APPEND TF_SRC_OS ${TF_SRC_OS_WIN})
endif()

add_library(OS ${TF_SRC_OS})
target_compile_options(OS PUBLIC ${TF_ARC_FLAGS} ${TF_OBJC_FLAGS})
target_compile_definitions(OS PUBLIC ${TF_RENDERER})
message(WARNING ${TF_LINK_LIBS})
target_link_libraries(OS
	${TF_LINK_LIBS}
	$<${TF_PLATFORM_LINUX}:pthread>
	$<${TF_PLATFORM_LINUX}:X11>
	$<${TF_PLATFORM_LINUX}:Xrandr>
)
list(APPEND TF_LINK_LIBS OS)

foreach(tf_source IN ITEMS ${TF_SRC_OS})
    get_filename_component(tf_path "${tf_source}" PATH)
	string(REGEX REPLACE "^.*\/([^\/]+)$" "\\1" tf_group_path "${tf_path}")
    source_group("${tf_group_path}" FILES "${tf_source}")
	#message("GROUP: ${tf_group_path} - ${tf_path}")
endforeach()

#
# renderers

source_group(Renderer FILES ${TF_SRC_RENDERER_COMMON})

if (TF_PLATFORM_OSX)
	# metal renderer - apple
	add_library(RendererMetal ${TF_SRC_RENDERER_COMMON} ${TF_SRC_RENDERER_METAL})
	target_compile_options(RendererMetal PUBLIC ${TF_OBJC_FLAGS})
	target_compile_definitions(RendererMetal PUBLIC METAL)
	target_link_libraries(RendererMetal OS)
elseif (TF_RENDERER_VULKAN)
	# vulkan renderer - everyone but apple
	find_package(Vulkan)
	if (NOT Vulkan_FOUND)
		message(FATAL_ERROR "Vulkan SDK was not found")
	endif()

	add_library(RendererVulkan ${TF_SRC_RENDERER_COMMON} ${TF_SRC_RENDERER_VULKAN})
	target_compile_definitions(RendererVulkan PUBLIC VULKAN)
	target_link_libraries(RendererVulkan
		OS
		Vulkan::Vulkan
		SpirvTools
		$<${TF_PLATFORM_WINDOWS}:${TF_LIB_RENDERDEPS_WIN}>
		$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:${TF_LIB_RENDERDEPS_WIN_DX}>
		$<${TF_PLATFORM_LINUX}:dl>
	)
endif()

if (TF_PLATFORM_WINDOWS)
	# dx11 renderer
	add_library(RendererDX11 ${TF_SRC_RENDERER_COMMON} ${TF_SRC_RENDERER_D3D11})
	target_compile_definitions(RendererDX11 PUBLIC DIRECT3D11)
	target_link_libraries(RendererDX11 d3d11.lib
		$<${TF_PLATFORM_WINDOWS}:${TF_LIB_RENDERDEPS_WIN}>
		$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:${TF_LIB_RENDERDEPS_WIN_DX}>
	)
	
	# dx12 renderer
	add_library(RendererDX12 ${TF_SRC_RENDERER_COMMON} ${TF_SRC_RENDERER_D3D12})
	target_compile_definitions(RendererDX12 PUBLIC DIRECT3D12)
	target_link_libraries(RendererDX12 d3d12.lib
		$<${TF_PLATFORM_WINDOWS}:${TF_LIB_RENDERDEPS_WIN}>
		$<$<OR:${TF_RENDERER_DX11},${TF_RENDERER_DX12}>:${TF_LIB_RENDERDEPS_WIN_DX}>
	)
	
	# postbuild dll copy
	foreach(tf_bin IN ITEMS ${TF_BIN_WIN32_EXTRA})
		add_custom_command(TARGET ${TF_TARGET_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${tf_bin} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>)
	endforeach()
endif()

if (TF_RENDERER STREQUAL "VULKAN")
	list(APPEND TF_LINK_LIBS RendererVulkan)
elseif (TF_RENDERER STREQUAL "DIRECT3D12")
	list(APPEND TF_LINK_LIBS RendererDX12)
elseif (TF_RENDERER STREQUAL "DIRECT3D11")
	list(APPEND TF_LINK_LIBS RendererDX11)
elseif (TF_RENDERER STREQUAL "METAL")
	list(APPEND TF_LINK_LIBS RendererMetal)
endif()


#
# runtime target properties

target_compile_definitions(${TF_TARGET_NAME} PUBLIC ${TF_RENDERER})
target_link_libraries(${TF_TARGET_NAME} OS ${TF_LINK_LIBS})

#
# postbuild copy

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

add_custom_command(
	TARGET ${TF_TARGET_NAME}
	POST_BUILD
	
	COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Meshes
	COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Textures
	COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Fonts
	COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Fonts/TitilliumText
	COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Shaders
	COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/GPUCfg
	
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_MESHES} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Meshes
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_TEXTURES} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Textures
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_FONTS} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Fonts/TitilliumText
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_GPUCFGS} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/GPUCfg
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_SHADERS} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Shaders
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_UI_SHADERS} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Shaders
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_TEXT_SHADERS} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Shaders
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_DIR_PROJ}/Resources/cameraPath.bin $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/cameraPath.bin
)

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
add_executable(${TF_TARGET_NAME}
	${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
)
target_compile_definitions(${TF_TARGET_NAME} PUBLIC ${TF_RENDERER})
target_link_libraries(${TF_TARGET_NAME} OS ${TF_LINK_LIBS})
add_custom_command(
	TARGET ${TF_TARGET_NAME}
	POST_BUILD
	
	COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Textures
	COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Fonts
	COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Shaders
	COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/GPUCfg
	
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_TEXTURES} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Textures
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_GPUCFGS} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/GPUCfg
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_SRC_SHADERS} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Shaders
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_UI_SHADERS} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Shaders
	COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_TEXT_SHADERS} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Shaders
)
set(TF_FONT_DIRS)
file(GLOB tf_tmp_dirs ${TF_DIR_ART}/Fonts/*)
foreach(tf_tmp_dir IN ITEMS ${tf_tmp_dirs})
	if (IS_DIRECTORY ${tf_tmp_dir})
		file(GLOB tf_tmp_glob ${tf_tmp_dir}/*)
		get_filename_component(tf_out_dir ${tf_tmp_dir} NAME)
		add_custom_command(TARGET ${TF_TARGET_NAME} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Fonts/${tf_out_dir}
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${tf_tmp_glob} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>/Fonts/${tf_out_dir}
		)
	endif()
endforeach()
