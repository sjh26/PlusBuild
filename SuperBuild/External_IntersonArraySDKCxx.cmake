# Check for path to IntersonArraySDK and raise an error during configure step
FIND_PATH(IntersonArraySDK_DIR 
  NAMES Libraries/IntersonArray.dll
  PATHS C:/IntersonArraySDK )
IF(NOT IntersonArraySDK_DIR)
  MESSAGE(FATAL_ERROR "Please specify the path to the IntersonArraySDK in IntersonArraySDK_DIR")
ENDIF()

IF(IntersonArraySDKCxx_DIR)
  # IntersonArraySDKCxx has been built already
  FIND_PACKAGE(IntersonArraySDKCxx REQUIRED PATHS ${IntersonArraySDKCxx_DIR} NO_DEFAULT_PATH)
  
  MESSAGE(STATUS "Using IntersonArraySDKCxx available at: ${IntersonArraySDKCxx_DIR}")

  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ${IntersonArraySDKCxx_LIBRARIES})

  SET(PLUS_IntersonArraySDKCxx_DIR "${IntersonArraySDKCxx_DIR}" CACHE INTERNAL "Path to store IntersonArraySDKCxx binaries")
ELSE()
  # IntersonArraySDKCxx has not been built yet, so download and build it as an external project
  SetGitRepositoryTag(
    IntersonArraySDKCxx
    "${GIT_PROTOCOL}://github.com/KitwareMedical/IntersonArraySDKCxx.git"
    "d4c85f0be20db55124570558a23692f19dcb1c10"
    )

  SET (PLUS_IntersonArraySDKCxx_SRC_DIR "${CMAKE_BINARY_DIR}/Deps/IntersonArraySDKCxx")
  SET (PLUS_IntersonArraySDKCxx_DIR "${CMAKE_BINARY_DIR}/Deps/IntersonArraySDKCxx-bin" CACHE INTERNAL "Path to store IntersonArraySDKCxx binaries")
  ExternalProject_Add( IntersonArraySDKCxx
    PREFIX "${CMAKE_BINARY_DIR}/Deps/IntersonArraySDKCxx-prefix"
    SOURCE_DIR "${PLUS_IntersonArraySDKCxx_SRC_DIR}"
    BINARY_DIR "${PLUS_IntersonArraySDKCxx_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${IntersonArraySDKCxx_GIT_REPOSITORY}
    GIT_TAG ${IntersonArraySDKCxx_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS 
      ${ep_common_args}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS} 
      -DBUILD_TESTING:BOOL=OFF
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DIntersonArraySDK_DIR:PATH=${IntersonArraySDK_DIR}
    #--Build step-----------------
    BUILD_ALWAYS 1    
    #--Install step-----------------
    INSTALL_COMMAND ""
    DEPENDS ${IntersonArraySDKCxx_DEPENDENCIES}
    )
ENDIF()