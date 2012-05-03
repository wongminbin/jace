#############
# FUNCTIONS #
#############

# Returns all header files in the current directory, recursing into sub-directories.
function (get_headers DIRECTORY RESULT)
  file (GLOB_RECURSE HEADER_FILES_TMP "${DIRECTORY}/*.h" "${DIRECTORY}/*.hpp" "${DIRECTORY}/*.inl" "${DIRECTORY}/*.pch" "${DIRECTORY}/*.tsd" "${DIRECTORY}/*.tsp")
  set (${RESULT} ${HEADER_FILES_TMP} PARENT_SCOPE)
endfunction ()

# Returns all source files in the current directory, recursing into sub-directories
function (get_sources DIRECTORY RESULT)
  file (GLOB_RECURSE SOURCE_FILES_TMP "${DIRECTORY}/*.c" "${DIRECTORY}/*.cpp")
  set (${RESULT} ${SOURCE_FILES_TMP} PARENT_SCOPE)
endfunction ()

# Converts all elements of a list to native paths
function (to_cmake_path collection result)
	LIST (LENGTH collection count)
	set (previous_index 0)
	set (index 0)
	WHILE (index LESS count)
		LIST (GET collection ${index} element)
		LIST (REMOVE_AT collection ${index})
		file (TO_CMAKE_PATH ${element} element)
		LIST (INSERT collection ${previous_index} ${element})
		MATH (EXPR previous_index "${index}")
		MATH (EXPR index "0 + ${index} + 1")
	ENDWHILE ()
  set (${result} ${collection} PARENT_SCOPE)
endfunction ()

################
# Build script #
################

cmake_minimum_required (VERSION 2.8)
project (singleton)

set (singleton_VERSION_MAJOR 1)
set (singleton_VERSION_MINOR 2)
add_definitions (-DJACE_EXPORTS -DBOOST_AUTO_LINK_NOMANGLE)

set (CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MP")
IF(CMAKE_COMPILER_IS_GNUCXX)
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror")
ENDIF(CMAKE_COMPILER_IS_GNUCXX)

file (TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/../proxies" PROXIES_PATH)
file (TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/../../../../java/target/peers" PEERS_PATH)
if (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  include_directories (include $ENV{JAVA_HOME}/include $ENV{JAVA_HOME}/include/win32 $ENV{BOOST_HOME} $ENV{JACE_HOME}/include ${PROXIES_PATH}/include ${PEERS_PATH}/include)
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  include_directories (include $ENV{JAVA_HOME}/include $ENV{JAVA_HOME}/include/linux $ENV{BOOST_HOME} $ENV{JACE_HOME}/include ${PROXIES_PATH}/include ${PEERS_PATH}/include)
endif ()

get_headers ("${PROXIES_PATH}/include" HEADER_FILES)
LIST (APPEND HEADER_FILES ${temp})
get_headers ("${PEERS_PATH}/include" HEADER_FILES)
LIST (APPEND HEADER_FILES ${temp})
to_cmake_path("${HEADER_FILES}" HEADER_FILES)

get_sources ("${CMAKE_CURRENT_SOURCE_DIR}/source" temp)
LIST (APPEND SOURCE_FILES ${temp})
get_sources ("${PROXIES_PATH}/source" temp)
LIST (APPEND SOURCE_FILES ${temp})
get_sources ("${PEERS_PATH}/source" temp)
LIST (APPEND SOURCE_FILES ${temp})
to_cmake_path("${SOURCE_FILES}" SOURCE_FILES)

file (TO_CMAKE_PATH "$ENV{JACE_HOME}/lib" JACE_LIBRARY)
file (TO_CMAKE_PATH "$ENV{JAVA_HOME}/lib" JAVA_LIBRARY)
link_directories (${JAVA_LIBRARY} ${JACE_LIBRARY})

add_library (singleton SHARED ${SOURCE_FILES} ${HEADER_FILES})

target_link_libraries (singleton jvm)
target_link_libraries (singleton jace)

file (TO_NATIVE_PATH ${PROJECT_BINARY_DIR} NATIVE_PROJECT_BINARY_DIR)
file (TO_NATIVE_PATH "$ENV{JACE_HOME}" JACE_HOME)
if (${CMAKE_GENERATOR} MATCHES "Visual Studio")
  add_custom_command (TARGET singleton POST_BUILD COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/post-build.bat \"${CMAKE_CFG_INTDIR}\" \"${JACE_HOME}\" \"${NATIVE_PROJECT_BINARY_DIR}\")
elseif (${CMAKE_GENERATOR} MATCHES "Unix Makefiles")
  add_custom_command (TARGET singleton POST_BUILD COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/post-build.sh \"${JACE_HOME}\" \"${NATIVE_PROJECT_BINARY_DIR}\")
endif ()