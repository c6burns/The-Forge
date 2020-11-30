#
# functions and setup file for The-Forge

#
# platform discovery

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

# policies
cmake_policy(SET CMP0079 NEW)

# code gen
set(CMAKE_CXX_STANDARD 14)
set(TF_OBJC_FLAGS $<${TF_PLATFORM_OSX}:-x objective-c++>)
set(TF_ARC_FLAGS $<${TF_PLATFORM_OSX}:-fobjc-arc>)

# output
if (NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Debug)
endif()

#
# renderer determination

set(TF_RENDERER_DIR)
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
	message(FATAL_ERROR "Unsupported build platform. Supported: Windows, OSX, Linux")
endif()

list(FIND TF_RENDERER_VALID ${TF_RENDERER} tf_valid_idx)
if (tf_valid_idx LESS 0)
	message(FATAL_ERROR "Invalid renderer: '${TF_RENDERER}'")
endif()
list(GET TF_RENDERER_DIR_VALID ${tf_valid_idx} TF_RENDERER_DIR)
if (NOT TF_RENDERER_DIR)
	message(FATAL_ERROR "Unable to find directory for renderer: ${TF_RENDERER}")
endif()

message(NOTICE "Building: ${TF_PLATFORM} / ${TF_RENDERER}")

#
# setup variables

set(TF_LINK_LIBS) # everything a runtime would need to link
set(TF_LINK_BINS) # associated binaries a runtime must copy

set(TF_DIR_COMMON ${CMAKE_CURRENT_SOURCE_DIR}/Common_3)
set(TF_DIR_RENDER ${TF_DIR_COMMON}/Renderer)
set(TF_DIR_OS ${TF_DIR_COMMON}/OS)
set(TF_DIR_TOOLS ${TF_DIR_COMMON}/Tools)
set(TF_DIR_OSS ${TF_DIR_COMMON}/ThirdParty/OpenSource)
set(TF_DIR_MW ${CMAKE_CURRENT_SOURCE_DIR}/Middleware_3)

#
# find packages and libraries

if (TF_RENDERER_VULKAN)
	find_package(Vulkan)
	if (NOT Vulkan_FOUND)
		message(FATAL_ERROR "Vulkan SDK not found, but Vulkan is the chosen renderer")
	endif()
endif()

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

#
# functions

# create target and add postbuild copy
function(tf_add_executable)
	cmake_parse_arguments(TF_PB "" "TARGET;DESTINATION" "SOURCES;RESOURCES" ${ARGN})

	set(TF_SRC_TARGET
		${TF_PB_SOURCES}
		$<${TF_PLATFORM_OSX}:Common_3/OS/Darwin/macOSAppDelegate.h>
		$<${TF_PLATFORM_OSX}:Common_3/OS/Darwin/macOSAppDelegate.m>
		$<${TF_PLATFORM_IOS}:Common_3/OS/Darwin/iOSAppDelegate.h>
		$<${TF_PLATFORM_IOS}:Common_3/OS/Darwin/iOSAppDelegate.m>
	)
	set(TF_RESDIR_TARGET ${TF_PB_DESTINATION}$<${TF_PLATFORM_OSX}:/../Resources>)
	set(TF_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/CMake/templates/Info.plist)
	set(TF_XIB_IN ${CMAKE_CURRENT_SOURCE_DIR}/CMake/templates/MainMenu.xib)
	set(TF_XIB ${CMAKE_CURRENT_BINARY_DIR}/${TF_PB_TARGET}/MainMenu.xib)
	configure_file(${TF_XIB_IN} ${TF_XIB})
	add_executable(${TF_PB_TARGET} ${TF_SRC_TARGET} $<${TF_PLATFORM_OSX}:${TF_PLIST} ${TF_XIB}>)
	set_target_properties(${TF_PB_TARGET}
		PROPERTIES
			MACOSX_BUNDLE TRUE
			MACOSX_BUNDLE_INFO_PLIST ${TF_PLIST}
			RESOURCE ${TF_XIB}
	)
	target_compile_options(${TF_PB_TARGET} PRIVATE ${TF_OBJC_FLAGS} ${TF_ARC_FLAGS})
	target_compile_definitions(${TF_PB_TARGET} PUBLIC ${TF_RENDERER})
	target_link_libraries(${TF_PB_TARGET} ${TF_LINK_LIBS})

	foreach(tf_res IN LISTS TF_PB_RESOURCES)
		string(REPLACE "${TF_RENDERER_DIR}/" "" tf_res_tmp ${tf_res})
		get_filename_component(tf_res_dir_tmp ${tf_res_tmp} DIRECTORY)
		get_filename_component(tf_res_dir ${tf_res_dir_tmp} NAME)
		file(GLOB tf_res_glob ${tf_res})
		
		if (tf_res_dir STREQUAL Fonts)
			add_custom_command(TARGET ${TF_PB_TARGET} POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Fonts
			)
			file(GLOB tf_tmp_dirs ${TF_DIR_ART}/Fonts/*)
			foreach(tf_tmp_dir IN ITEMS ${tf_tmp_dirs})
				if (IS_DIRECTORY ${tf_tmp_dir})
					file(GLOB tf_tmp_glob ${tf_tmp_dir}/*)
					get_filename_component(tf_out_dir ${tf_tmp_dir} NAME)
					add_custom_command(TARGET ${TF_PB_TARGET} POST_BUILD
						COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Fonts/${tf_out_dir}
						COMMAND ${CMAKE_COMMAND} -E copy_if_different ${tf_tmp_glob} ${TF_RESDIR_TARGET}/Fonts/${tf_out_dir}
					)
				endif()
			endforeach()
		else()
			add_custom_command(TARGET ${TF_PB_TARGET} POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/${tf_res_dir}
				COMMAND ${CMAKE_COMMAND} -E copy_if_different ${tf_res_glob} ${TF_RESDIR_TARGET}/${tf_res_dir}
			)
		endif()
	endforeach()

	# copy windows binaries
	if (TF_PLATFORM_WINDOWS)
		add_custom_command(TARGET ${TF_PB_TARGET} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_DIR_OSS}/ags/ags_lib/lib/amd_ags_x64.dll ${TF_RESDIR_TARGET}/
		)
	endif()

	# copy directx binaries
	if (TF_RENDERER_DX11 OR TF_RENDERER_DX12)
		add_custom_command(TARGET ${TF_PB_TARGET} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_DIR_OSS}/DirectXShaderCompiler/bin/x64/dxcompiler.dll ${TF_RESDIR_TARGET}/
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_DIR_OSS}/winpixeventruntime/bin/WinPixEventRuntime.dll ${TF_RESDIR_TARGET}/
		)
	endif()
endfunction()
