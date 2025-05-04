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
set(PACKAGE_FILE "${PACKAGE_NAME}.${PACKAGE_VERSION}.nupkg")

# Add targets
add_custom_target(pack
    COMMAND ${CHOCO_EXECUTABLE} pack
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Building the Chocolatey package"
    VERBATIM
)

# Verify no errors/warnings in build
add_custom_target(verify
    COMMAND ${CMAKE_COMMAND} -E echo "Verifying package has no errors or warnings"
    COMMAND ${CMAKE_COMMAND}
            -DCHOCO_EXECUTABLE=${CHOCO_EXECUTABLE}
            -DPACKAGE_FILE=${PACKAGE_FILE}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/VerifyPackage.cmake
    DEPENDS pack
    COMMENT "Verifying package validity"
    VERBATIM
)

# Install package
add_custom_target(install_package
    COMMAND ${CHOCO_EXECUTABLE} install ${PACKAGE_NAME} -dv -s .
    DEPENDS verify
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Installing the package locally"
    VERBATIM
)

# Uninstall package
add_custom_target(uninstall_package
    COMMAND ${CHOCO_EXECUTABLE} uninstall ${PACKAGE_NAME} -dv
    DEPENDS install_package
    COMMENT "Uninstalling the package"
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
    DEPENDS uninstall_package
    COMMENT "Pushing package to Chocolatey.org"
    VERBATIM
)

# Default target
add_custom_target(all_steps DEPENDS push)

# All done message
message(STATUS "CMake configuration complete. Run 'cmake --build . --target all_steps' to build, verify, install, uninstall, and push the package.") 