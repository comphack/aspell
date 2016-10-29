########################################################################
#
# settings.h
#

find_package(Curses)
if(CURSES_FOUND)
  set(HAVE_LIBCURSES 1)
  set(TERM_HEADER "<term.h>")
  set(CURSES_HEADER "<ncurses.h>")
  set(ASPELL_LINK_LIBRARIES ${CURSES_LIBRARY})
endif(CURSES_FOUND)

include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CheckCSourceCompiles)
include(CheckCXXSourceCompiles)
include(CheckCSourceRuns)

#################
# 'normal' checks
check_include_files(dlfcn.h     HAVE_DLFCN_H)
check_include_files(fcntl.h     HAVE_FCNTL_H)
check_include_files(inttypes.h  HAVE_INTTYPES_H)
check_include_files(langinfo.h  HAVE_LANGINFO_H)
check_include_files(locale.h    HAVE_LOCALE_H)
check_include_files(memory.h    HAVE_MEMORY_H)
check_include_files(pthread.h   HAVE_PTHREAD_H)
check_include_files(regex.h     HAVE_REGEX_H)
check_include_files(stdint.h    HAVE_STDINT_H)
check_include_files(stdlib.h    HAVE_STDLIB_H)
check_include_files(strings.h   HAVE_STRINGS_H)
check_include_files(string.h    HAVE_STRING_H)
check_include_files(sys/stat.h  HAVE_SYS_STAT_H)
check_include_files(sys/types.h HAVE_SYS_TYPES_H)
check_include_files(unistd.h    HAVE_UNISTD_H)
check_include_files(term.h      HAVE_TERM_H)
check_include_files(termios.h   POSIX_TERMIOS)
check_include_files(wchar.h     HAVE_WCHAR_H)

check_function_exists(dcgettext HAVE_DCGETTEXT)
check_function_exists(getch     HAVE_GETCH)
check_function_exists(gettext   HAVE_GETTEXT)
check_function_exists(iconv     HAVE_ICONV)
check_function_exists(mmap      HAVE_MMAP)
if(HAVE_WCHAR_H)
  set(CMAKE_REQUIRED_INCLUDES wchar.h)
  check_function_exists(mblen   HAVE_MBLEN)
endif(HAVE_WCHAR_H)

if(WIN32 AND NOT HAVE_GETCH)
  MESSAGE(FATAL_ERROR "Could not find getch() function which is mandatory for windows compilation!")
endif(WIN32 AND NOT HAVE_GETCH)

if(WIN32)
  set(CURSES_ONLY 1)
endif(WIN32)

if(HAVE_DLFCN_H)
  set(HAVE_LIBDL 1)
endif(HAVE_DLFCN_H)

set(CURSES_INCLUDE_STANDARD 0)
if(HAVE_TERM_H)
  # TODO: Check for solaris and do not set it there!
  #       also don't forget to set CURSES_INCLUDE_WORKAROUND_1 then
  set(CURSES_INCLUDE_STANDARD 1)
endif(HAVE_TERM_H)


############
# ENABLE_NLS
check_include_files(libintl.h HAVE_LIBINTL_H)
if(HAVE_LIBINTL_H)
  option(ENABLE_NLS        "Enable if translation of program messages to the user's native language is requested" ON)
endif(HAVE_LIBINTL_H)

if(HAVE_SYS_STAT_H)
  ##############
  # USE_FILE_INO
  file(WRITE ${CMAKE_BINARY_DIR}/conftest-f1 "")
  file(WRITE ${CMAKE_BINARY_DIR}/conftest-f2 "")
  set(USE_FILE_INO_SOURCE "
  #include <sys/stat.h>
  int main() {
    struct stat s1,s2;
    if (stat(\"conftest-f1\",&s1) != 0) exit(2);
    if (stat(\"conftest-f2\",&s2) != 0) exit(2);
    exit (s1.st_ino != s2.st_ino ? 0 : 1);
  }
  ")
  check_c_source_runs("${USE_FILE_INO_SOURCE}" USE_FILE_INO)
endif(HAVE_SYS_STAT_H)

###################
# REL_OPS_POLLUTION
# TODO: Is this logic correct?
set(NO_REL_OPS_POLLUTION_SOURCE "
#include <utility>

template <typename T>
class C {};
template <typename T>
bool operator== (C<T>, C<T>) {return true;}
template <typename T>
bool operator!= (C<T>, C<T>) {return false;}

int main ()
{
  C<int> c1, c2;
  bool v = c1 != c2;
  return 0;
}
")
check_cxx_source_compiles("${NO_REL_OPS_POLLUTION_SOURCE}" NO_REL_OPS_POLLUTION)
if(NO_REL_OPS_POLLUTION)
  set(REL_OPS_POLLUTION FALSE)
else(NO_REL_OPS_POLLUTION)
  set(REL_OPS_POLLUTION TRUE)
endif(NO_REL_OPS_POLLUTION)


if(HAVE_LANGINFO_H)
  #######################
  # HAVE_LANGINFO_CODESET
  set(HAVE_LANGINFO_CODESET_SOURCE "
  #include <langinfo.h>
  int main ()
  {
    char* cs = nl_langinfo(CODESET); return !cs;
    return 0;
  }
  ")
  check_c_source_compiles("${HAVE_LANGINFO_CODESET_SOURCE}" HAVE_LANGINFO_CODESET)
endif(HAVE_LANGINFO_H)


if(HAVE_LOCALE_H)
  #######################
  # USE_LOCALE
  set(USE_LOCALE_SOURCE "
  #include <locale.h>
  int main ()
  {
    setlocale (LC_ALL, NULL);
    setlocale (LC_MESSAGES, NULL);
    return 0;
  }
  ")
  check_c_source_compiles("${USE_LOCALE_SOURCE}" USE_LOCALE)
endif(HAVE_LOCALE_H)


if(HAVE_PTHREAD_H)
  #######################
  # USE_POSIX_MUTEX
  set(USE_POSIX_MUTEX_SOURCE "
  #include <pthread.h>
  int main ()
  {
    pthread_mutex_t lck;
    pthread_mutex_init(&lck, 0);
    pthread_mutex_lock(&lck);
    pthread_mutex_unlock(&lck);
    pthread_mutex_destroy(&lck);
    return 0;
  }
  ")
  check_c_source_compiles("${USE_POSIX_MUTEX_SOURCE}" USE_POSIX_MUTEX)
endif(HAVE_PTHREAD_H)


if(HAVE_SYS_TYPES_H AND HAVE_REGEX_H)
  #######################
  # USE_POSIX_REGEX
  set(USE_POSIX_REGEX_SOURCE "
  #include <sys/types.h>
  #include <regex.h>
  int main ()
  {
    regex_t r;
    regcomp(&r, \"\", REG_EXTENDED);
    regexec(&r, \"\", 0, 0, 0);
    return 0;
  }
  ")
  check_c_source_compiles("${USE_POSIX_REGEX_SOURCE}" USE_POSIX_REGEX)
endif(HAVE_SYS_TYPES_H AND HAVE_REGEX_H)
  

if(CURSES_FOUND AND HAVE_WCHAR_H)
  ##############################
  # DEFINE_XOPEN_SOURCE_EXTENDED
  # TODO: Looks like this doesn't work...

  set(DEFINE_XOPEN_SOURCE_EXTENDED_SOURCE "
  #define _XOPEN_SOURCE_EXTENDED 1
  #include <wchar.h>
  #include <${CURSES_HEADER}>
  int main ()
  {
    wchar_t wch = 0;
    addnwstr(&wch, 1);
    return 0;
  }
  ")
  check_c_source_compiles("${DEFINE_XOPEN_SOURCE_EXTENDED_SOURCE}" DEFINE_XOPEN_SOURCE_EXTENDED)
  
  ##################
  # HAVE_WIDE_CURSES
  set(HAVE_WIDE_CURSES_SOURCE "
  #include <wchar.h>
  #include <${CURSES_HEADER}>
  int main ()
  {
    wchar_t wch = 0;
    addnwstr(&wch, 1);
    return 0;
  }
  ")
  check_c_source_compiles("${HAVE_WIDE_CURSES_SOURCE}" HAVE_WIDE_CURSES)
endif(CURSES_FOUND AND HAVE_WCHAR_H)


if(HAVE_FCNTL_H AND HAVE_UNISTD_H)
  ################
  # USE_FILE_LOCKS
  set(USE_FILE_LOCKS_SOURCE "
  #include <fcntl.h>
  #include <unistd.h>
  int main ()
  {
    int fd;
    struct flock fl;
    fcntl(fd, F_SETLKW, &fl);
    ftruncate(fd,0);
    return 0;
  }
  ")
  check_c_source_compiles("${USE_FILE_LOCKS_SOURCE}" USE_FILE_LOCKS)
endif(HAVE_FCNTL_H AND HAVE_UNISTD_H)


configure_file(${CMAKE_SOURCE_DIR}/gen/settings.h.cmake ${CMAKE_BINARY_DIR}/settings.h)
