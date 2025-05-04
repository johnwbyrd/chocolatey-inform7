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

# Check if package file exists
if(NOT EXISTS "${PACKAGE_FILE}")
    message(FATAL_ERROR "Package file not found: ${PACKAGE_FILE}")
endif()

# Register the API key with Chocolatey
message(STATUS "Registering Chocolatey API key...")
execute_process(
    COMMAND ${CHOCO_EXECUTABLE} apikey --key=${API_KEY} --source=https://push.chocolatey.org/
    RESULT_VARIABLE APIKEY_RESULT
    OUTPUT_VARIABLE APIKEY_OUTPUT
    ERROR_VARIABLE APIKEY_ERROR
)

if(APIKEY_RESULT)
    message(FATAL_ERROR "Failed to register API key: ${APIKEY_ERROR}")
endif()

# Now push the package to Chocolatey.org
message(STATUS "Pushing package to Chocolatey.org...")
message(STATUS "Using package file: ${PACKAGE_FILE}")
execute_process(
    COMMAND ${CHOCO_EXECUTABLE} push "${PACKAGE_FILE}" --source=https://push.chocolatey.org/
    RESULT_VARIABLE PUSH_RESULT
    OUTPUT_VARIABLE PUSH_OUTPUT
    ERROR_VARIABLE PUSH_ERROR
)

if(PUSH_RESULT)
    message(FATAL_ERROR "Failed to push package: ${PUSH_ERROR}")
endif()

message(STATUS "Successfully pushed package to Chocolatey.org") 