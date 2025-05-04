# Verifies the package has no errors or warnings
execute_process(
    COMMAND ${CHOCO_EXECUTABLE} pack --noop
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    RESULT_VARIABLE VERIFY_RESULT
    OUTPUT_VARIABLE VERIFY_OUTPUT
    ERROR_VARIABLE VERIFY_ERROR
)

if(VERIFY_RESULT)
    message(FATAL_ERROR "Package verification failed: ${VERIFY_ERROR}")
endif()

# Check for warnings in output
string(FIND "${VERIFY_OUTPUT}" "WARNING" WARNING_FOUND)
if(NOT WARNING_FOUND EQUAL -1)
    message(FATAL_ERROR "Warnings found in package: ${VERIFY_OUTPUT}")
endif()

# Check for errors in output
string(FIND "${VERIFY_OUTPUT}" "ERROR" ERROR_FOUND)
if(NOT ERROR_FOUND EQUAL -1)
    message(FATAL_ERROR "Errors found in package: ${VERIFY_OUTPUT}")
endif()

message(STATUS "Package verification successful") 