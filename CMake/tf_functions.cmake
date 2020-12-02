#
# functions for The-Forge

#
# sets the current platform
function(tf_set_platform)
	set(TF_PLATFORM "" PARENT_SCOPE)
	set(TF_PLATFORM_WINDOWS 0 PARENT_SCOPE)
	set(TF_PLATFORM_OSX 0 PARENT_SCOPE)
	set(TF_PLATFORM_IOS 0 PARENT_SCOPE)
	set(TF_PLATFORM_LINUX 0 PARENT_SCOPE)
	if (IOS)
		set(TF_PLATFORM "IOS" PARENT_SCOPE)
		set(TF_PLATFORM_IOS 1 PARENT_SCOPE)
	elseif (APPLE)
		set(TF_PLATFORM "OSX" PARENT_SCOPE)
		set(TF_PLATFORM_OSX 1 PARENT_SCOPE)
	elseif (UNIX)
		set(TF_PLATFORM "LINUX" PARENT_SCOPE)
		set(TF_PLATFORM_LINUX 1 PARENT_SCOPE)
	elseif (WIN32)
		set(TF_PLATFORM "WINDOWS" PARENT_SCOPE)
		set(TF_PLATFORM_WINDOWS 1 PARENT_SCOPE)
	else()
		message(FATAL_ERROR "Unsupported platform")
	endif()
endfunction()

#
# set the renderer that ships with the main library
function(tf_set_renderer)
	set(TF_SR_NAME)
	if (${ARGC})
		set(TF_SR_NAME ${ARGN})
	endif()

	set(TF_RENDERER_NAME "" PARENT_SCOPE)
	set(TF_RENDERER_VULKAN 0 PARENT_SCOPE)
	set(TF_RENDERER_METAL 0 PARENT_SCOPE)
	set(TF_RENDERER_DX12 0 PARENT_SCOPE)

	set(TF_RENDERER_NAME_DEFAULT "VULKAN")
	if (TF_PLATFORM_OSX)
		set(TF_RENDERER_NAME_DEFAULT "METAL")
	endif()

	if (NOT TF_SR_NAME)
		set(TF_SR_NAME ${TF_RENDERER_NAME_DEFAULT})
	endif()

	list(FIND TF_RENDERER_OPTIONS ${TF_SR_NAME} tf_valid_idx)
	if (tf_valid_idx LESS 0)
		message(FATAL_ERROR "Invalid renderer name: '${TF_SR_NAME}'")
	endif()

	list(GET TF_RENDERER_OPTIONS ${tf_valid_idx} tf_renderer_local)
	list(GET TF_RENDERER_NAME_OPTIONS ${tf_valid_idx} tf_renderer_name_local)
	if (NOT tf_renderer_local OR NOT tf_renderer_name_local)
		message(FATAL_ERROR "Unable to find directory for renderer: ${TF_SR_NAME}")
	endif()

	if (TF_SR_NAME STREQUAL tf_renderer_local)
		#message("setting renderer: ${tf_renderer_local} / ${tf_renderer_name_local}")
	else()
		message(FATAL_ERROR "setting renderer failed: ${TF_SR_NAME} != ${tf_renderer_local}")
	endif()
	
	set(TF_RENDERER ${tf_renderer_local} CACHE STRING "Renderer chosen at CMake configure" FORCE)
	set(TF_RENDERER_NAME ${tf_renderer_name_local} PARENT_SCOPE)
	if (tf_renderer_local STREQUAL "VULKAN")
		set(TF_RENDERER_VULKAN 1 PARENT_SCOPE)
	elseif (tf_renderer_local STREQUAL "METAL")
		set(TF_RENDERER_METAL 1 PARENT_SCOPE)
	elseif (tf_renderer_local STREQUAL "DIRECT3D12")
		set(TF_RENDERER_DX12 1 PARENT_SCOPE)
	endif()
endfunction()

#
# create target and add postbuild copy
function(tf_add_executable)
	cmake_parse_arguments(TF_AE "TEST" "TARGET;DESTINATION" "SOURCES;RESOURCES" ${ARGN})

	set(TF_SRC_TARGET
		${TF_AE_SOURCES}
		$<${TF_PLATFORM_OSX}:Common_3/OS/Darwin/macOSAppDelegate.h>
		$<${TF_PLATFORM_OSX}:Common_3/OS/Darwin/macOSAppDelegate.m>
		$<${TF_PLATFORM_IOS}:Common_3/OS/Darwin/iOSAppDelegate.h>
		$<${TF_PLATFORM_IOS}:Common_3/OS/Darwin/iOSAppDelegate.m>
	)
	set(TF_RESDIR_TARGET ${TF_AE_DESTINATION}$<${TF_PLATFORM_OSX}:/../Resources>)
	set(TF_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/CMake/templates/Info.plist)
	set(TF_XIB_IN ${CMAKE_CURRENT_SOURCE_DIR}/CMake/templates/MainMenu.xib)
	set(TF_XIB ${CMAKE_CURRENT_BINARY_DIR}/xib/${TF_AE_TARGET}/MainMenu.xib)
	configure_file(${TF_XIB_IN} ${TF_XIB})
	add_executable(${TF_AE_TARGET} ${TF_SRC_TARGET} $<${TF_PLATFORM_OSX}:${TF_PLIST} ${TF_XIB}>)
	if (TF_AE_TEST)
		target_link_libraries(${TF_AE_TARGET} gtest gtest_main gmock gmock_main)
	else()
		set_target_properties(${TF_AE_TARGET}
			PROPERTIES
				MACOSX_BUNDLE TRUE
				MACOSX_BUNDLE_INFO_PLIST ${TF_PLIST}
				RESOURCE ${TF_XIB}
		)
	endif()
	target_compile_options(${TF_AE_TARGET} PRIVATE ${TF_OBJC_FLAGS} ${TF_ARC_FLAGS})
	target_compile_definitions(${TF_AE_TARGET} PUBLIC ${TF_RENDERER})
	target_link_libraries(${TF_AE_TARGET} ${TF_LINK_LIBS})
	if (Vulkan_FOUND)
		target_include_directories(${TF_AE_TARGET} PRIVATE ${Vulkan_INCLUDE_DIRS})
		target_link_libraries(${TF_AE_TARGET} ${Vulkan_LIBRARIES})
	endif()

	foreach(tf_res IN LISTS TF_AE_RESOURCES)
		string(REPLACE "${TF_RENDERER_NAME}/" "" tf_res_tmp ${tf_res})
		get_filename_component(tf_res_dir_tmp ${tf_res_tmp} DIRECTORY)
		get_filename_component(tf_res_dir ${tf_res_dir_tmp} NAME)
		file(GLOB tf_res_glob ${tf_res})
		message("${tf_res} - ${tf_res_dir} - ${tf_res_tmp} - ${tf_res_dir_tmp}")
		
		if (tf_res_dir STREQUAL Fonts)
			add_custom_command(TARGET ${TF_AE_TARGET} POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Fonts
			)
			file(GLOB tf_tmp_dirs ${TF_DIR_ART}/Fonts/*)
			foreach(tf_tmp_dir IN ITEMS ${tf_tmp_dirs})
				if (IS_DIRECTORY ${tf_tmp_dir})
					file(GLOB tf_tmp_glob ${tf_tmp_dir}/*)
					get_filename_component(tf_out_dir ${tf_tmp_dir} NAME)
					add_custom_command(TARGET ${TF_AE_TARGET} POST_BUILD
						COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/Fonts/${tf_out_dir}
						COMMAND ${CMAKE_COMMAND} -E copy_if_different ${tf_tmp_glob} ${TF_RESDIR_TARGET}/Fonts/${tf_out_dir}
					)
				endif()
			endforeach()
		else()
			add_custom_command(TARGET ${TF_AE_TARGET} POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E make_directory ${TF_RESDIR_TARGET}/${tf_res_dir}
				COMMAND ${CMAKE_COMMAND} -E copy_if_different ${tf_res_glob} ${TF_RESDIR_TARGET}/${tf_res_dir}
			)
		endif()
	endforeach()

	# copy windows binaries
	if (TF_PLATFORM_WINDOWS)
		add_custom_command(TARGET ${TF_AE_TARGET} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_DIR_OSS}/ags/ags_lib/lib/amd_ags_x64.dll ${TF_RESDIR_TARGET}/
		)
	endif()

	# copy directx binaries
	if (TF_RENDERER_DX12)
		add_custom_command(TARGET ${TF_AE_TARGET} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_DIR_OSS}/DirectXShaderCompiler/bin/x64/dxcompiler.dll ${TF_RESDIR_TARGET}/
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${TF_DIR_OSS}/winpixeventruntime/bin/WinPixEventRuntime.dll ${TF_RESDIR_TARGET}/
		)
	endif()
endfunction()
