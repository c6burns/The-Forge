cmake_minimum_required(VERSION 3.1.0)

project(TheForge LANGUAGES CXX)

set(TF_RENDERER "DIRECT3D12")
set(TF_LINK_LIBS)
set(TF_TARGET_NAME Visibility_Buffer)

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
)

# OS library
set(TF_SRC_OS_LIBRARY
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
	
	# OS / Windows
	Common_3/OS/Windows/WindowsBase.cpp
	Common_3/OS/Windows/WindowsFileSystem.cpp
	Common_3/OS/Windows/WindowsLog.cpp
	Common_3/OS/Windows/WindowsStackTraceDump.h
	Common_3/OS/Windows/WindowsStackTraceDump.cpp
	Common_3/OS/Windows/WindowsThread.cpp
	Common_3/OS/Windows/WindowsTime.cpp
)

set(TF_LIB_WIN32_EXTRA
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/ags/ags_lib/lib/amd_ags_x64.lib
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/DirectXShaderCompiler/lib/x64/dxcompiler.lib
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/nvapi/amd64/nvapi64.lib
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/winpixeventruntime/bin/WinPixEventRuntime.lib
)

set(TF_BIN_WIN32_EXTRA
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/ags/ags_lib/lib/amd_ags_x64.dll
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/DirectXShaderCompiler/bin/x64/dxcompiler.dll
	${CMAKE_SOURCE_DIR}/Common_3/ThirdParty/OpenSource/winpixeventruntime/bin/WinPixEventRuntime.dll
)

#
# runtime

# Visibility_Buffer
add_executable(${TF_TARGET_NAME}
	Examples_3/Visibility_Buffer/src/Geometry.h
	Examples_3/Visibility_Buffer/src/Geometry.cpp
	Examples_3/Visibility_Buffer/src/Visibility_Buffer.cpp
)
# properties for this target are resolved after all other dependencies

#
# renderers

source_group(Renderer FILES ${TF_SRC_RENDERER_COMMON})

if (NOT APPLE)
	# vulkan
	find_package(Vulkan)
	if (NOT Vulkan_FOUND)
		if (TF_RENDERER STREQUAL "VULKAN")
			message(ERROR "Vulkan SDK was not found")
		else()
			message(WARNING "Vulkan SDK was not found")
		endif()
	else()
		add_library(RendererVulkan ${TF_SRC_RENDERER_COMMON} ${TF_SRC_RENDERER_VULKAN})
		target_compile_definitions(RendererVulkan PUBLIC VULKAN)
		target_link_libraries(RendererVulkan Vulkan::Vulkan)
	endif()
endif()

if (APPLE)
	# metal
	add_library(RendererMetal ${TF_SRC_RENDERER_COMMON} ${TF_SRC_RENDERER_METAL})
	target_compile_definitions(RendererMetal PUBLIC METAL)
elseif (WIN32)
	# dx11
	add_library(RendererDX11 ${TF_SRC_RENDERER_COMMON} ${TF_SRC_RENDERER_D3D11})
	target_compile_definitions(RendererDX11 PUBLIC DIRECT3D11)
	target_link_libraries(RendererDX11 ${TF_LIB_WIN32_EXTRA})
	
	# dx12
	add_library(RendererDX12 ${TF_SRC_RENDERER_COMMON} ${TF_SRC_RENDERER_D3D12})
	target_compile_definitions(RendererDX12 PUBLIC DIRECT3D12)
	target_link_libraries(RendererDX12 ${TF_LIB_WIN32_EXTRA})
	
	add_custom_target(genexdebug COMMAND ${CMAKE_COMMAND} -E echo "$<TARGET_FILE_DIR:${TF_TARGET_NAME}>")
	foreach(tf_bin IN ITEMS ${TF_BIN_WIN32_EXTRA})
		add_custom_command(TARGET ${TF_TARGET_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${tf_bin} $<TARGET_FILE_DIR:${TF_TARGET_NAME}>)
		#add_custom_command(TARGET ${TF_TARGET_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE_DIR:${TF_TARGET_NAME}>../ ${tf_bin})
	endforeach()
elseif (UNIX)
else()
	message(ERROR "Unsupported platform")
endif()

if (TF_RENDERER STREQUAL "VULKAN")
	list(APPEND TF_LINK_LIBS RendererVulkan Vulkan::Vulkan)
elseif (TF_RENDERER STREQUAL "DIRECT3D12")
	list(APPEND TF_LINK_LIBS RendererDX12 d3d12.lib dxgi.lib d3dcompiler.lib)
elseif (TF_RENDERER STREQUAL "DIRECT3D11")
	list(APPEND TF_LINK_LIBS RendererDX11 d3d12.lib dxgi.lib d3dcompiler.lib)
elseif (TF_RENDERER STREQUAL "METAL")
	list(APPEND TF_LINK_LIBS RendererMetal)
endif()

#
# OS (platform library)

add_library(OS ${TF_SRC_OS_LIBRARY})
target_compile_definitions(OS PUBLIC ${TF_RENDERER})
target_link_libraries(OS ${TF_LINK_LIBS})

foreach(tf_source IN ITEMS ${TF_SRC_OS_LIBRARY})
    get_filename_component(tf_path "${tf_source}" PATH)
	string(REGEX REPLACE "^.*\/([^\/]+)$" "\\1" tf_group_path "${tf_path}")
    source_group("${tf_group_path}" FILES "${tf_source}")
	#message("GROUP: ${tf_group_path} - ${tf_path}")
endforeach()

#
# tools

# gainputstatic
set(GAINPUT_BUILD_STATIC ON CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_BUILD_SHARED OFF CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_SAMPLES OFF CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_TESTS OFF CACHE INTERNAL "gainput: forced subdirectory option")
mark_as_advanced(GAINPUT_BUILD_STATIC GAINPUT_BUILD_SHARED GAINPUT_SAMPLES GAINPUT_TESTS)
add_subdirectory(Common_3/ThirdParty/OpenSource/gainput)
target_compile_definitions(gainputstatic PUBLIC ${TF_RENDERER})
list(APPEND TF_LINK_LIBS gainputstatic)

# SpirvTools
add_library(SpirvTools ${TF_SRC_SPIRVTOOLS})
target_compile_definitions(SpirvTools PUBLIC ${TF_RENDERER})
list(APPEND TF_LINK_LIBS SpirvTools)

#
# runtime target properties

target_compile_definitions(${TF_TARGET_NAME} PUBLIC ${TF_RENDERER})
target_link_libraries(${TF_TARGET_NAME} OS ${TF_LINK_LIBS})
