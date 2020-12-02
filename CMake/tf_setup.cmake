#
# setup for The-Forge

mark_as_advanced(CMAKE_AR CMAKE_CONFIGURATION_TYPES CMAKE_INSTALL_PREFIX)
include(tf_functions) # function definitions

# find packages and libraries
find_package(Vulkan)
if (NOT Vulkan_FOUND)
	message(WARNING "Vulkan SDK not found")
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
# setup variables

set(TF_LINK_LIBS) # everything a runtime would need to link
set(TF_DIR_COMMON ${CMAKE_CURRENT_SOURCE_DIR}/Common_3)
set(TF_DIR_OS ${TF_DIR_COMMON}/OS)
set(TF_DIR_RENDERER ${TF_DIR_COMMON}/Renderer)
set(TF_DIR_TOOLS ${TF_DIR_COMMON}/Tools)
set(TF_DIR_OSS ${TF_DIR_COMMON}/ThirdParty/OpenSource)
set(TF_DIR_MW ${CMAKE_CURRENT_SOURCE_DIR}/Middleware_3)
set(TF_DIR_TESTS ${CMAKE_CURRENT_SOURCE_DIR}/Tests)
set(TF_DIR_ART ${CMAKE_CURRENT_SOURCE_DIR}/Art)
set(TF_DIR_EX ${CMAKE_CURRENT_SOURCE_DIR}/Examples_3)

 # sets TF_PLATFORM*
tf_set_platform()

set(TF_RENDERER_OPTIONS)
set(TF_RENDERER_NAME_OPTIONS)
if (Vulkan_FOUND)
	list(APPEND TF_RENDERER_OPTIONS "VULKAN")
	list(APPEND TF_RENDERER_NAME_OPTIONS "Vulkan")
endif()

if (TF_PLATFORM_OSX)
	list(APPEND TF_RENDERER_OPTIONS "METAL")
	list(APPEND TF_RENDERER_NAME_OPTIONS "Metal")
elseif (TF_PLATFORM_WINDOWS)
	list(APPEND TF_RENDERER_OPTIONS "DIRECT3D12")
	list(APPEND TF_RENDERER_NAME_OPTIONS "D3D12")
endif()

 # set TF_RENDERER and friends
set(TF_RENDERER "" CACHE STRING "Renderer chosen at CMake configure")
set_property(CACHE TF_RENDERER PROPERTY STRINGS ${TF_RENDERER_OPTIONS})
tf_set_renderer(${TF_RENDERER})

 # include target source definitions
include(tf_sources)
mark_as_advanced(TF_RENDERER_NAME)

# code gen
set(CMAKE_CXX_STANDARD 14)
set(TF_OBJC_FLAGS $<${TF_PLATFORM_OSX}:-x objective-c++>)
set(TF_ARC_FLAGS $<${TF_PLATFORM_OSX}:-fobjc-arc>)

# output
if (NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Debug)
endif()
