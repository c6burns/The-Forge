cmake_minimum_required(VERSION 3.15)
set(TF_PROJ_NAME TheForge)
project(${TF_PROJ_NAME} LANGUAGES C CXX)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/CMake)
include(tf_setup) # include cmake setup file

# display banner about what we build to user .. and make it kinda 80s
include(tf_banner)

#
# targets - dependencies

# drop each source file into its own folder in the IDE
foreach(tf_source IN ITEMS ${TF_SRC_MAINLIB})
    get_filename_component(tf_path "${tf_source}" PATH)
	string(REGEX REPLACE "^.*\/([^\/]+)$" "\\1" tf_group_path "${tf_path}")
    source_group("${tf_group_path}" FILES "${tf_source}")
endforeach()

#
# build targets - dependencies

# gtest/gmock
# targets: gtest gtest_main gmock gmock_main
set(BUILD_GMOCK ON CACHE INTERNAL "gtest: forced subdirectory option")
set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "gtest: forced subdirectory option")
set(INSTALL_GTEST OFF CACHE INTERNAL "gtest: forced subdirectory option")
mark_as_advanced(GAINPUT_BUILD_STATIC GAINPUT_BUILD_SHARED GAINPUT_SAMPLES GAINPUT_TESTS APPKIT FOUNDATION GAME_CONTROLLER IOKIT)
add_subdirectory(${TF_DIR_OSS}/googletest)

# gainput
# targets: gainputstatic
set(GAINPUT_BUILD_STATIC ON CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_BUILD_SHARED OFF CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_SAMPLES OFF CACHE INTERNAL "gainput: forced subdirectory option")
set(GAINPUT_TESTS OFF CACHE INTERNAL "gainput: forced subdirectory option")
mark_as_advanced(GAINPUT_BUILD_STATIC GAINPUT_BUILD_SHARED GAINPUT_SAMPLES GAINPUT_TESTS APPKIT FOUNDATION GAME_CONTROLLER IOKIT)
add_subdirectory(${TF_DIR_OSS}/gainput)
target_compile_options(gainputstatic PUBLIC ${TF_OBJC_FLAGS})
target_link_libraries(gainputstatic $<${TF_PLATFORM_WINDOWS}:xinput.lib>)

# main library target
# targets: TheForge
add_library(${TF_PROJ_NAME} ${TF_SRC_MAINLIB})
target_include_directories(${TF_PROJ_NAME} PRIVATE ${Vulkan_INCLUDE_DIRS})
target_compile_definitions(${TF_PROJ_NAME} PUBLIC ${TF_RENDERER})
target_compile_options(${TF_PROJ_NAME} PUBLIC ${TF_ARC_FLAGS})
set_target_properties(${TF_PROJ_NAME}
	PROPERTIES
		XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
		XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_WEAK YES
)
target_link_libraries(${TF_PROJ_NAME}
	gainputstatic
	$<${TF_RENDERER_VULKAN}:${Vulkan_LIBRARIES}>
	$<${TF_PLATFORM_LINUX}:dl>
)

#
# runtimes

# Visibility_Buffer
set(TF_SRC_VBUF
	${TF_DIR_EX}/Visibility_Buffer/src/Geometry.h
	${TF_DIR_EX}/Visibility_Buffer/src/Geometry.cpp
	${TF_DIR_EX}/Visibility_Buffer/src/Visibility_Buffer.cpp
)
set(TF_RESDIR_TARGET $<TARGET_FILE_DIR:${TF_TARGET_NAME}>)
#if (TF_PLATFORM_OSX)
#	set(TF_RESDIR_TARGET ${TF_RESDIR_TARGET}/../Resources)
#	set(TF_SRC_MAIN_RES
#		"${TF_DIR_EX}/Visibility_Buffer/macOS Xcode/Visibility_Buffer/Base.lproj/MainMenu.xib"
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
# build target - Visibility_Buffer

set(TF_TARGET_NAME Visibility_Buffer)
set(TF_DIR_ART ${TF_DIR_ART}/SanMiguel_3)
set(TF_DIR_PROJ ${TF_DIR_EX}/${TF_TARGET_NAME})
file(GLOB TF_SRC_MESHES ${TF_DIR_ART}/Meshes/*)
file(GLOB TF_SRC_TEXTURES ${TF_DIR_ART}/Textures/*.dds)
file(GLOB TF_SRC_FONTS ${TF_DIR_PROJ}/Resources/Fonts/*)
file(GLOB TF_SRC_GPUCFGS ${TF_DIR_PROJ}/src/GPUCfg/*)
file(GLOB TF_SRC_SHADERS ${TF_DIR_PROJ}/src/Shaders/${TF_RENDERER_NAME}/*)
file(GLOB TF_UI_SHADERS ${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_NAME}/*)
file(GLOB TF_TEXT_SHADERS ${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_NAME}/*)
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES
		${TF_DIR_PROJ}/src/Geometry.h
		${TF_DIR_PROJ}/src/Geometry.cpp
		${TF_DIR_PROJ}/src/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_DIR_ART}/Meshes/*
		${TF_DIR_ART}/Textures/*.dds
		${TF_DIR_PROJ}/Resources/cameraPath.bin
		${TF_DIR_PROJ}/Resources/Fonts/*
		${TF_DIR_PROJ}/src/GPUCfg/*
		${TF_DIR_PROJ}/src/Shaders/${TF_RENDERER_NAME}/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_NAME}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_NAME}/*
)
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
# build targets - integration tests

# 01_Transformations
set(TF_TARGET_NAME 01_Transformations)
set(TF_DIR_ART ${TF_DIR_EX}/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${TF_DIR_EX}/Unit_Tests/src/${TF_TARGET_NAME})
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES ${TF_DIR_PROJ}/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_DIR_ART}/Meshes/*
		${TF_DIR_ART}/Textures/Skybox_*.dds
		${TF_DIR_ART}/Textures/circlepad.dds
		${TF_DIR_PROJ}/Resources/Fonts/*
		${TF_DIR_PROJ}/GPUCfg/*
		${TF_DIR_PROJ}/Shaders/${TF_RENDERER_NAME}/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_NAME}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_NAME}/*
)

# playground
set(TF_TARGET_NAME playground)
set(TF_DIR_ART ${TF_DIR_EX}/Unit_Tests/UnitTestResources)
set(TF_DIR_PROJ ${TF_DIR_EX}/Unit_Tests/src/01_Transformations)
tf_add_executable(
	TARGET ${TF_TARGET_NAME}
	TEST YES
	DESTINATION $<TARGET_FILE_DIR:${TF_TARGET_NAME}>
	SOURCES ${TF_DIR_TESTS}/${TF_TARGET_NAME}.cpp
	RESOURCES
		${TF_DIR_ART}/Meshes/*
		${TF_DIR_ART}/Textures/Skybox_*.dds
		${TF_DIR_ART}/Textures/circlepad.dds
		${TF_DIR_PROJ}/Resources/Fonts/*
		${TF_DIR_PROJ}/GPUCfg/*
		${TF_DIR_PROJ}/Shaders/${TF_RENDERER_NAME}/*
		${TF_DIR_MW}/UI/Shaders/${TF_RENDERER_NAME}/*
		${TF_DIR_MW}/Text/Shaders/${TF_RENDERER_NAME}/*
)
