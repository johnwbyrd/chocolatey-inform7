# Pushes the package to Chocolatey.org
if(${USE_ENV_API_KEY})
    # Get API key from environment variable
    set(API_KEY $ENV{CHOCOLATEY_API_KEY})
    if("${API_KEY}" STREQUAL "")
        message(FATAL_ERROR "CHOCOLATEY_API_KEY environment variable not set")
    endif()
else()
    # Use API key provided via CMake variable
    set(API_KEY ${CHOCOLATEY_API_KEY})
    if("${API_KEY}" STREQUAL "")
        message(FATAL_ERROR "CHOCOLATEY_API_KEY not provided")
    endif()
endif()

execute_process(
    COMMAND ${CHOCO_EXECUTABLE} push ${PACKAGE_FILE} --source=https://push.chocolatey.org/ --api-key=${API_KEY}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    RESULT_VARIABLE PUSH_RESULT
    OUTPUT_VARIABLE PUSH_OUTPUT
    ERROR_VARIABLE PUSH_ERROR
)

if(PUSH_RESULT)
    message(FATAL_ERROR "Failed to push package: ${PUSH_ERROR}")
endif()

message(STATUS "Successfully pushed package to Chocolatey.org") 