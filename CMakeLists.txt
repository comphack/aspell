project(aspell)
cmake_minimum_required(VERSION 2.4.5)

OPTION(USE_STATIC_RUNTIME "Use the static MSVC runtime." OFF)

IF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC" AND USE_STATIC_RUNTIME)
    SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd")
    SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")

    SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT")
    SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
ELSEIF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MDd")
    SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MDd")

    SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MD")
    SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MD")
ENDIF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")

#if(CMAKE_SIZEOF_VOID_P MATCHES "8")
#  set(MY_SUFFIX "64")
#endif(CMAKE_SIZEOF_VOID_P MATCHES "8")

set(LIB_SUFFIX ${MY_SUFFIX} CACHE STRING "Define suffix of directory name (32/64)" )

########################################################################
#
# basic settings
#
set(ASPELL_VERSION_MAJOR   0)
set(ASPELL_VERSION_MINOR  60)
set(ASPELL_VERSION_PATCH   6)
set(PACKAGE               "aspell")
set(PACKAGE_VERSION       "${ASPELL_VERSION_MAJOR}.${ASPELL_VERSION_MINOR}.${ASPELL_VERSION_PATCH}")
set(VERSION		  15.1.4)
set(SOVERSION             15)
set(ASPELL_LINK_LIBRARIES "")
set(ASPELL_PLUGIN_DIR     lib${LIB_SUFFIX}/aspell-${ASPELL_VERSION_MAJOR}.${ASPELL_VERSION_MINOR})

option(BUILD_SHARED "Build shared (ON) or static (OFF) libraries" ON)
if(BUILD_SHARED)
  set(ASPELL_LINK SHARED)
else(BUILD_SHARED)
  set(ASPELL_LINK STATIC)
endif(BUILD_SHARED)

option(COMPILE_IN_FILTERS "Compile filters statically into the aspell library (ON) or as plugin (OFF)" OFF)
option(FILTER_VERSION_CONTROL "Enable filter version control should be used" OFF)

########################################################################
#
# remove NDEBUG from the compiler flags
#
macro(REMOVE_COMPILER_FLAG DEFINITIONS FLAG_TO_REMOVE DESCR)
  string(REPLACE ${FLAG_TO_REMOVE} "" ${DEFINITIONS} ${${DEFINITIONS}})
  string(REGEX REPLACE "[ ]+$" "" ${DEFINITIONS} ${${DEFINITIONS}})
  set(${DEFINITIONS} ${${DEFINITIONS}} CACHE STRING "${DESCR}" FORCE)
endmacro(REMOVE_COMPILER_FLAG)

remove_compiler_flag(CMAKE_C_FLAGS_MINSIZEREL   -DNDEBUG "Flags used by the compiler during release minsize builds.")
remove_compiler_flag(CMAKE_C_FLAGS_RELEASE      -DNDEBUG "Flags used by the compiler during release builds (/MD /Ob1 /Oi /Ot /Oy /Gs will produce slightly less optimized but smaller files).")
remove_compiler_flag(CMAKE_CXX_FLAGS_MINSIZEREL -DNDEBUG "Flags used by the compiler during release minsize builds.")
remove_compiler_flag(CMAKE_CXX_FLAGS_RELEASE    -DNDEBUG "Flags used by the compiler during release builds (/MD /Ob1 /Oi /Ot /Oy /Gs will produce slightly less optimized but smaller files).")

########################################################################
#
# settings.h
#
include(ConfigureChecks.cmake)

########################################################################
#
# dirs.h
#

configure_file(${CMAKE_SOURCE_DIR}/gen/dirs.h.cmake ${CMAKE_BINARY_DIR}/dirs.h)

########################################################################
#
# static_filters.src.cpp
#
set(STATIC_OPTFILES "${CMAKE_SOURCE_DIR}/modules/filter/url-filter.info")
find_package(Perl REQUIRED)
add_custom_command( OUTPUT ${CMAKE_SOURCE_DIR}/gen/static_filters.src.cpp
		    COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/gen/mk-static-filter.pl ${STATIC_OPTFILES}
		    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)
set_source_files_properties(lib/new_filter.cpp PROPERTIES OBJECT_DEPENDS ${CMAKE_SOURCE_DIR}/gen/static_filters.src.cpp)

########################################################################
#
# Aspell library
#

set(libaspell_sources
  common/cache.cpp
  common/can_have_error.cpp
  common/config.cpp
  common/convert.cpp
  common/document_checker.cpp
  common/error.cpp
  common/errors.cpp
  common/file_data_util.cpp
  common/file_util.cpp
  common/filter.cpp
  common/fstream.cpp
  common/getdata.cpp
  common/gettext_init.cpp
  common/info.cpp
  common/iostream.cpp
  common/itemize.cpp
  common/objstack.cpp
  common/posib_err.cpp
  common/speller.cpp
  common/string.cpp
  common/string_list.cpp
  common/string_map.cpp
  common/strtonum.cpp
  common/tokenizer.cpp

  modules/speller/default/affix.cpp
  modules/speller/default/data.cpp
  modules/speller/default/editdist.cpp
  modules/speller/default/language.cpp
  modules/speller/default/leditdist.cpp
  modules/speller/default/multi_ws.cpp
  modules/speller/default/phonet.cpp
  modules/speller/default/phonetic.cpp
  modules/speller/default/primes.cpp
  modules/speller/default/readonly_ws.cpp
  modules/speller/default/speller_impl.cpp
  modules/speller/default/suggest.cpp
  modules/speller/default/typo_editdist.cpp
  modules/speller/default/writable.cpp

  modules/tokenizer/basic.cpp

  lib/can_have_error-c.cpp
  lib/config-c.cpp
  lib/document_checker-c.cpp
  lib/error-c.cpp
  lib/filter-c.cpp
  lib/find_speller.cpp
  lib/info-c.cpp
  lib/mutable_container-c.cpp
  lib/new_checker.cpp
  lib/new_config.cpp
  lib/new_filter.cpp
  lib/new_fmode.cpp
  lib/speller-c.cpp
  lib/string_enumeration-c.cpp
  lib/string_list-c.cpp
  lib/string_map-c.cpp
  lib/string_pair_enumeration-c.cpp
  lib/word_list-c.cpp
  
# This is for filters which are ALWAYS static.  
# The url filter is always usefull and fairly simple.
# The genconv filter is mostly defined in the main aspell libarary
#   since it is used by other filters.  The actual genconv filter
#   is just a small wrapper.

  modules/filter/url.cpp
)

file(GLOB commons_headers ../common/*.hpp)

set(ASPELL_FILTERS
  context
  email
#  html		# no .cpp, only html-filter.info !?
  nroff
  sgml
  tex
  texinfo
#  url		# linked statically every time!
)

if(COMPILE_IN_FILTERS OR NOT BUILD_SHARED)
  foreach(filter ${ASPELL_FILTERS})
    LIST(APPEND libaspell_sources modules/filter/${filter}.cpp)
  endforeach(filter)
endif(COMPILE_IN_FILTERS OR NOT BUILD_SHARED)

include_directories(
  ${CMAKE_BINARY_DIR}
  ${CMAKE_SOURCE_DIR}
  ${CMAKE_SOURCE_DIR}/gen
  ${CMAKE_SOURCE_DIR}/lib
  ${CMAKE_SOURCE_DIR}/common
  ${CMAKE_SOURCE_DIR}/modules
  ${CMAKE_SOURCE_DIR}/modules/filter
  ${CMAKE_SOURCE_DIR}/modules/speller
  ${CMAKE_SOURCE_DIR}/modules/speller/default
  ${CMAKE_SOURCE_DIR}/interfaces/cc
)

if(WIN32)
  # debug   library name: aspelld.lib
  # release library name: aspell.lib
  set(CMAKE_DEBUG_POSTFIX "d")
  # ADD_DEFINITIONS(-DWIN32PORT)
endif(WIN32)

add_library(aspell ${ASPELL_LINK} ${libaspell_sources} ${commons_headers})
target_link_libraries(aspell ${ASPELL_LINK_LIBRARIES})
set_target_properties(aspell PROPERTIES
		      SOVERSION ${SOVERSION}
		      VERSION ${VERSION}
)
if(WIN32)
	target_link_libraries(aspell ole32)
endif(WIN32)

add_library(pspell ${ASPELL_LINK} lib/dummy.cpp)
target_link_libraries(pspell aspell)
set_target_properties(pspell PROPERTIES
		      SOVERSION ${SOVERSION}
		      VERSION ${VERSION}
)

########################################################################
#
# Aspell filters
#

if(BUILD_SHARED AND NOT COMPILE_IN_FILTERS)
  foreach(filter ${ASPELL_FILTERS})
    add_library(${filter}-filter SHARED modules/filter/${filter}.cpp)
    target_link_libraries(${filter}-filter aspell)
    set_target_properties(${filter}-filter PROPERTIES PREFIX "")
  endforeach(filter)
endif(BUILD_SHARED AND NOT COMPILE_IN_FILTERS)

########################################################################
#
# Aspell program
#

set(aspell_SOURCES 
  prog/aspell.cpp 
  prog/check_funs.cpp 
  prog/checker_string.cpp
)
  
add_executable(aspellexe ${aspell_SOURCES})
set_target_properties(aspellexe PROPERTIES OUTPUT_NAME aspell)
target_link_libraries(aspellexe aspell)

########################################################################
#
# word-list-compress program
#
add_executable(word-list-compress prog/compress.c)

########################################################################
#
# prezip program
#
add_executable(prezip-bin prog/prezip.c)

########################################################################
#
# Install
#

set(ASPELL_SCRIPTS
  scripts/aspell-import
  scripts/precat
  scripts/preunzip
  scripts/prezip
)
file(GLOB MANPAGES_1 manual/*.1)

install(TARGETS aspellexe aspell pspell word-list-compress prezip-bin
	RUNTIME DESTINATION bin
	LIBRARY DESTINATION lib${LIB_SUFFIX}
	ARCHIVE DESTINATION lib${LIB_SUFFIX})
install(FILES ${ASPELL_SCRIPTS} DESTINATION bin
				PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
                                            GROUP_EXECUTE WORLD_EXECUTE)
install(FILES interfaces/cc/aspell.h 
	DESTINATION include)
install(FILES interfaces/cc/pspell.h 
	DESTINATION include/pspell)

if(BUILD_SHARED AND NOT COMPILE_IN_FILTERS)
  foreach(filter ${ASPELL_FILTERS})
    install(TARGETS ${filter}-filter
	DESTINATION ${ASPELL_PLUGIN_DIR}
    )
  endforeach(filter)
  file(GLOB ASPELL_AMF  modules/filters/modes/*.amf)
  file(GLOB ASPELL_DATA data/*.cset data/*.cmap data/*.kbd)
  file(GLOB ASPELL_INFO modules/filter/*.info)

  install(FILES ${ASPELL_AMF}  DESTINATION  ${ASPELL_PLUGIN_DIR})
  install(FILES ${ASPELL_DATA} DESTINATION  ${ASPELL_PLUGIN_DIR})
  install(FILES ${ASPELL_INFO} DESTINATION  ${ASPELL_PLUGIN_DIR})
endif(BUILD_SHARED AND NOT COMPILE_IN_FILTERS)

install(FILES manual/aspell-dev.info manual/aspell.info
	DESTINATION share/info)
install(FILES ${MANPAGES_1}
	DESTINATION share/man1)

# TODO: install locales
