project(gainput)
message(STATUS "GAINPUT version ${GAINPUT_VERSION}")

set(CMAKE_MACOSX_RPATH 1)

if(CMAKE_COMPILER_IS_GNUCXX)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++98 -Wall -Wextra -pedantic -Wshadow -Wno-variadic-macros")
endif()

include_directories (include/)

file(GLOB_RECURSE sources source/*.cpp source/*.h include/*.h)

if(APPLE)
	file(GLOB_RECURSE mmsources source/*.mm)
endif()

## build STATIC *or* SHARED
if (GAINPUT_BUILD_SHARED)
  message(STATUS "..Building shared libraries (-DGAINPUT_BUILD_SHARED=OFF to disable)")
  add_library(gainput SHARED ${sources} ${mmsources})
  set_target_properties(gainput PROPERTIES
    OUTPUT_NAME gainput
    DEBUG_POSTFIX -d
    VERSION ${GAINPUT_VERSION}
    SOVERSION ${GAINPUT_MAJOR_VERSION}
    FOLDER gainput
  )
  set(install_libs ${install_libs} gainput)
endif (GAINPUT_BUILD_SHARED)

if (GAINPUT_BUILD_STATIC)
  message(STATUS "..Building static libraries (-DGAINPUT_BUILD_STATIC=OFF to disable)")
  add_library(gainputstatic STATIC ${sources} ${mmsources})
  set_target_properties(gainputstatic PROPERTIES DEBUG_POSTFIX -d FOLDER gainput)
  set(install_libs ${install_libs} gainputstatic)
endif (GAINPUT_BUILD_STATIC)

set(GAIN_LINK_LIBS)

if(WIN32)
  list(APPEND GAIN_LINK_LIBS ${XINPUT} ws2_32)
	if (GAINPUT_BUILD_SHARED)
    add_definitions(-DGAINPUT_LIB_DYNAMIC=1)
	endif()
elseif(ANDROID)
  list(APPEND GAIN_LINK_LIBS native_app_glue log android)
elseif(APPLE)
	find_library(FOUNDATION Foundation)
	find_library(IOKIT IOKit)
  find_library(GAME_CONTROLLER GameController)
  list(APPEND GAIN_LINK_LIBS ${FOUNDATION} ${IOKIT} ${GAME_CONTROLLER})

  if(IOS)
      find_library(UIKIT UIKit)
      find_library(COREMOTION CoreMotion)
      find_library(QUARTZCORE QuartzCore)
      list(APPEND GAIN_LINK_LIBS ${UIKIT} ${COREMOTION})
  else()
      find_library(APPKIT AppKit)
      list(APPEND GAIN_LINK_LIBS ${APPKIT})
  endif()
endif()

if (GAINPUT_BUILD_SHARED)
  target_link_libraries(gainput ${GAIN_LINK_LIBS})
endif()

if (GAINPUT_BUILD_SHARED)
  target_link_libraries(gainputstatic ${GAIN_LINK_LIBS})
endif()


# Library installation directory
if(NOT DEFINED CMAKE_INSTALL_LIBDIR)
    set(CMAKE_INSTALL_LIBDIR lib)
endif(NOT DEFINED CMAKE_INSTALL_LIBDIR)
set(libdir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})

install(
    DIRECTORY "include/gainput"
    DESTINATION "include"
    FILES_MATCHING PATTERN "*.h"
)

install(
    TARGETS ${install_libs}
    LIBRARY DESTINATION "${libdir}"
    ARCHIVE DESTINATION "${libdir}"
    RUNTIME DESTINATION "bin"
)
