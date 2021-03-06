#
# functions and setup file for The-Forge

ADD_DEFINITIONS(-DUNICODE)
ADD_DEFINITIONS(-D_UNICODE)

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
	set(TF_RENDERER "DIRECT3D11")
	set(TF_RENDERER_DX11 1)
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

message(NOTICE "Building The Forge: ${TF_PLATFORM} / ${TF_RENDERER}")
set(TF_RENDERER ${TF_RENDERER} PARENT_SCOPE)
set(TF_RENDERER_DIR ${TF_RENDERER_DIR} PARENT_SCOPE)

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
set(TF_DIR_TESTS ${CMAKE_CURRENT_SOURCE_DIR}/Tests)
set(TF_DIR_CMAKE ${CMAKE_CURRENT_SOURCE_DIR}/CMake)

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
	cmake_parse_arguments(TF_PB "TEST" "TARGET;DESTINATION;SOURCEDIR" "SOURCES;RESOURCES" ${ARGN})

	if (NOT TF_PB_SOURCEDIR)
		set(TF_PB_SOURCEDIR ${CMAKE_CURRENT_SOURCE_DIR})
	endif()
	set(TF_PB_DIR_FONT ${TF_PB_SOURCEDIR}/Examples_3/Unit_Tests/UnitTestResources/Fonts)

	set(tf_outdir ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${TF_PB_TARGET})
	set(TF_SRC_TARGET ${TF_PB_SOURCES})
	set(TF_RESDIR_TARGET ${TF_PB_DESTINATION})
	set(TF_PLIST ${TF_PB_SOURCEDIR}/CMake/templates/Info.plist)
	set(TF_XIB_IN ${TF_PB_SOURCEDIR}/CMake/templates/MainMenu.xib)
	set(TF_XIB ${CMAKE_CURRENT_BINARY_DIR}/xib/${TF_PB_TARGET}/MainMenu.xib)
	configure_file(${TF_XIB_IN} ${TF_XIB})

	if (APPLE)
		set(TF_RESDIR_TARGET ${TF_RESDIR_TARGET}/../Resources)
		set(TF_SRC_TARGET ${TF_SRC_TARGET}
			${TF_PB_SOURCEDIR}/Common_3/OS/Darwin/macOSAppDelegate.h
			${TF_PB_SOURCEDIR}/Common_3/OS/Darwin/macOSAppDelegate.m
			${TF_PB_SOURCEDIR}/Common_3/OS/Darwin/iOSAppDelegate.h
			${TF_PB_SOURCEDIR}/Common_3/OS/Darwin/iOSAppDelegate.m
			${TF_PLIST}
			${TF_XIB}
		)
	endif()

	add_executable(${TF_PB_TARGET} ${TF_SRC_TARGET})
	if (NOT TF_PB_TEST)
		set_target_properties(${TF_PB_TARGET}
			PROPERTIES
				MACOSX_BUNDLE TRUE
				MACOSX_BUNDLE_INFO_PLIST ${TF_PLIST}
				RESOURCE ${TF_XIB}
				RUNTIME_OUTPUT_DIRECTORY ${tf_outdir}
		)
	endif()
	
	target_compile_options(${TF_PB_TARGET} PRIVATE ${TF_OBJC_FLAGS} ${TF_ARC_FLAGS})
	target_compile_definitions(${TF_PB_TARGET} PUBLIC ${TF_RENDERER})
	target_link_libraries(${TF_PB_TARGET} ${TF_LINK_LIBS})
	target_include_directories(${TF_PB_TARGET} PRIVATE
		${TF_PB_SOURCEDIR}
		${TF_PB_SOURCEDIR}/Common_3
		${TF_PB_SOURCEDIR}/Middleware_3
	)

	# copy fonts
	if (NOT TF_PB_TEST)
		add_custom_command(TARGET ${TF_PB_TARGET} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_directory ${TF_PB_DIR_FONT} ${TF_RESDIR_TARGET}/Fonts/
			COMMAND ${CMAKE_COMMAND} -E copy_directory ${TF_PB_DIR_FONT} ${tf_outdir}/Fonts/
		)
	endif()

	foreach(tf_res IN LISTS TF_PB_RESOURCES)
		string(REPLACE "${TF_RENDERER_DIR}/" "" tf_res_tmp ${tf_res})
		get_filename_component(tf_res_dir_tmp ${tf_res_tmp} DIRECTORY)
		get_filename_component(tf_res_dir ${tf_res_dir_tmp} NAME)
		file(GLOB tf_res_glob ${tf_res})
		
		if (NOT tf_res_glob)
			message(WARNING "Empty GLOB from pattern: ${tf_res}")
		else()
			add_custom_command(TARGET ${TF_PB_TARGET} POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/${tf_res_dir}
				COMMAND ${CMAKE_COMMAND} -E copy ${tf_res_glob} ${TF_RESDIR_TARGET}/${tf_res_dir}
			)
		endif()
	endforeach()

	# copy windows binaries
	if (TF_PLATFORM_WINDOWS)
		add_custom_command(TARGET ${TF_PB_TARGET} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy ${TF_DIR_OSS}/ags/ags_lib/lib/amd_ags_x64.dll ${TF_RESDIR_TARGET}/
		)
	endif()

	# copy directx binaries
	if (TF_RENDERER_DX11 OR TF_RENDERER_DX12)
		add_custom_command(TARGET ${TF_PB_TARGET} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy ${TF_DIR_OSS}/DirectXShaderCompiler/bin/x64/dxcompiler.dll ${TF_RESDIR_TARGET}/
			COMMAND ${CMAKE_COMMAND} -E copy ${TF_DIR_OSS}/winpixeventruntime/bin/WinPixEventRuntime.dll ${TF_RESDIR_TARGET}/
		)
	endif()
endfunction()

# create target and add postbuild copy
function(tf_add_resource tf_ar_target tf_ar_globpattern tf_ar_destination)
	if (IS_DIRECTORY ${tf_ar_globpattern})
		set(tf_outdir ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${TF_PB_TARGET})
		add_custom_command(TARGET ${tf_ar_target} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_directory ${tf_ar_globpattern} ${tf_ar_destination}
		)
	else()
		file(GLOB tf_ar_glob ${tf_ar_globpattern})
		if (NOT tf_ar_glob)
			message(WARNING "nothing found for GLOB: ${tf_ar_globpattern}")
		endif()
		add_custom_command(TARGET ${tf_ar_target} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory ${tf_ar_destination}
			COMMAND ${CMAKE_COMMAND} -E copy ${tf_ar_glob} ${tf_ar_destination}/
		)
	endif()
endfunction()