# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "winhooker")
project(${PROJECT_NAME} LANGUAGES CXX)
# if(NOT CMAKE_CXX_STANDARD)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# endif()
# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "winhooker_plugin")
if(DEFINED ENV{KEYEVENT_DEBUG})
    set(KEYEVENT_DEBUG ON)
endif()
if(DEFINED ENV{KEYEVENT_DEBUG_NONGIT})
    set(KEYEVENT_DEBUG_NONGIT ON)
endif()
message(STATUS "keyboard_event KEYEVENT_DEBUG=" ${KEYEVENT_DEBUG})
if(KEYEVENT_DEBUG)
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /D KEYEVENT_DEBUG")

    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../.git")
        set(KEYEVENT_DEBUG_NONGIT OFF)
    endif()
    if(KEYEVENT_DEBUG_NONGIT)
        # this is in git
        if(NOT EXISTS
                "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/spdlog/CMakeLists.txt")
            # if not download spdlog
            message(
                    STATUS
                    "The submodules were not downloaded! Trying to update submodules ...")
            find_package(Git QUIET)
            if(GIT_FOUND)
                # Update submodules as needed
                option(GIT_SUBMODULE "Check submodules during build" ON)
                if(GIT_SUBMODULE)
                    message(STATUS "Submodule update")
                    execute_process(
                            COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
                            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                            RESULT_VARIABLE GIT_SUBMOD_RESULT)
                    if(NOT GIT_SUBMOD_RESULT EQUAL "0")
                        message(
                                FATAL_ERROR
                                "git submodule update --init --recursive failed with ${GIT_SUBMOD_RESULT}, please checkout submodules"
                        )
                    endif()
                endif()
            else()
                message(
                        FATAL_ERROR
                        "The submodules were not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again."
                )
            endif()
        endif()
        add_subdirectory("../third_party/spdlog" "../third_party/bin")
        include_directories("../third_party/spdlog/include")
    else()
        # this is not git, maybe user is using pub
        set(SPDLOG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/spdlog")
        set(SPDLOG_BUILD_DIR
                "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/build/spdlog")
        set(SPDLOG_INSTALL_DIR
                "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/bin/spdlog")
        include(ExternalProject)
        execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory
                ${SPDLOG_BUILD_DIR})
        ExternalProject_Add(
                spdlog
                TMP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/tmp/spdlog"
                STAMP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/stamp/spdlog"
                BINARY_DIR ${SPDLOG_BUILD_DIR}
                SOURCE_DIR ${SPDLOG_DIR}
                INSTALL_DIR ${SPDLOG_INSTALL_DIR}
                GIT_REPOSITORY git@github.com:gabime/spdlog.git
                GIT_TAG v1.9.1
                PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/spdlog"
                CONFIGURE_COMMAND cmake -S ../../spdlog -B .
                BUILD_COMMAND cmake --build . --config
                "$<IF:$<CONFIG:Debug>,Debug,Release>"
                INSTALL_COMMAND
                cmake --install . --prefix ${SPDLOG_INSTALL_DIR} --config
                "$<IF:$<CONFIG:Debug>,Debug,Release>" WORKING_DIRECTORY ${SPDLOG_DIR}
                LOG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/log/spdlog"
                LOG_CONFIGURE ON
                LOG_BUILD ON
                LOG_INSTALL ON
                LOG_MERGED_STDOUTERR ON)
        find_package(
                spdlog QUIET PATHS
                "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/bin/spdlog/lib/cmake/spdlog"
                NO_DEFAULT_PATH)
        include_directories("../third_party/bin/spdlog/include")
    endif()
endif()

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "winhooker_plugin.cpp"
  "winhooker_plugin.h"
)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
  "include/winhooker/winhooker_plugin_c_api.h"
  "winhooker_plugin_c_api.cpp"
        "map_serializer.cpp"
        "map_serializer.h" "codeconvert.cpp" "timestampp.h."
  ${PLUGIN_SOURCES}
)
set(TIMESTAMP_H timestampp.h)
add_custom_target(
        ${TIMESTAMP_H}
        COMMAND cmd /C echo ${PROJECT_SOURCE_DIR}
        COMMAND cmd /C timestamp.bat .
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
add_dependencies(${PLUGIN_NAME} ${TIMESTAMP_H})
target_compile_options(${PLUGIN_NAME} PRIVATE /utf-8 /std:c++latest /bigobj)
add_definitions(-D_HAS_EXCEPTIONS=1) # error LNK2019: std::bad_cast

apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
        "${CMAKE_CURRENT_SOURCE_DIR}/include")

if(KEYEVENT_DEBUG)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/bin/spdlog/lib")
        target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin
                spdlog::spdlog)
    else()
        target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)
    endif()
else()
    target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)
endif()
# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(winhooker_bundled_libraries
  ""
  PARENT_SCOPE
)
