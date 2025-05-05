cmake_minimum_required(VERSION 3.14)
project(chocolatey-inform7 LANGUAGES NONE)

# Options
option(USE_ENV_API_KEY "Use CHOCOLATEY_API_KEY from environment variable" ON)
set(CHOCOLATEY_API_KEY "" CACHE STRING "Chocolatey API key for pushing packages")

# Find choco executable
find_program(CHOCO_EXECUTABLE choco REQUIRED)
message(STATUS "Found Chocolatey: ${CHOCO_EXECUTABLE}")

# Define package version from nuspec
file(STRINGS "inform7.nuspec" nuspec_version_line REGEX "<version>.*</version>")
string(REGEX REPLACE ".*<version>(.*)</version>.*" "\\1" PACKAGE_VERSION ${nuspec_version_line})
message(STATUS "Package version: ${PACKAGE_VERSION}")

# Set package name, files, etc.
set(PACKAGE_NAME "inform7")
set(PACKAGE_FILE "${CMAKE_BINARY_DIR}/${PACKAGE_NAME}.${PACKAGE_VERSION}.nupkg")

# Add targets
add_custom_target(pack
    COMMAND ${CHOCO_EXECUTABLE} pack --fail-on-stderr --outputdirectory="${CMAKE_BINARY_DIR}"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Build the Chocolatey package"
    VERBATIM
)

# Install package
add_custom_target(choco_install
    COMMAND ${CHOCO_EXECUTABLE} install ${PACKAGE_NAME} -dv -s "${CMAKE_BINARY_DIR}"
    DEPENDS pack
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Build and install the package locally"
    VERBATIM
)

# Uninstall package
add_custom_target(choco_uninstall
    COMMAND ${CHOCO_EXECUTABLE} uninstall ${PACKAGE_NAME} -dv
    DEPENDS choco_install
    COMMENT "Build, install, and uninstall the package"
    VERBATIM
)

# Uninstall package without building dependencies  
add_custom_target(choco_uninstall_no_dependencies
    COMMAND ${CHOCO_EXECUTABLE} uninstall ${PACKAGE_NAME} -dv
    COMMENT "Uninstall the package without building or installing it first"
    VERBATIM
)

# Testing target for CI - executes the full test cycle without pushing
add_custom_target(test_package
    DEPENDS choco_install choco_uninstall
    COMMENT "Test the package (build→install→uninstall)"
    VERBATIM
)

# Push to chocolatey.org
add_custom_target(push
    COMMAND ${CMAKE_COMMAND}
            -DCHOCO_EXECUTABLE=${CHOCO_EXECUTABLE}
            -DPACKAGE_FILE=${PACKAGE_FILE}
            -DUSE_ENV_API_KEY=${USE_ENV_API_KEY}
            -DCHOCOLATEY_API_KEY=${CHOCOLATEY_API_KEY}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/PushPackage.cmake
    DEPENDS test_package
    COMMENT "Push package to Chocolatey.org"
    VERBATIM
)

# Default target
add_custom_target(all_steps DEPENDS push test_package)

# All done message
message(STATUS "CMake configuration complete.")
message(STATUS "- Run 'cmake --build build --target test_package' to build, install, and uninstall the package")
message(STATUS "- Run 'cmake --build build --target all_steps' to test and publish the package") 