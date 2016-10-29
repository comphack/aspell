#ifndef ASPELL_SETTINGS__H
#define ASPELL_SETTINGS__H

/* Defined if filters should be compiled in */
#cmakedefine COMPILE_IN_FILTER 1

/* Defined to the term header file */
#cmakedefine TERM_HEADER @TERM_HEADER@

/* Defined to curses header file */
#cmakedefine CURSES_HEADER @CURSES_HEADER@

/* Defined if no special Workarounds are needed for Curses headers */
#define CURSES_INCLUDE_STANDARD @CURSES_INCLUDE_STANDARD@

/* Defined if special Wordaround I is need for Curses headers */
#undef CURSES_INCLUDE_WORKAROUND_1

/* Defined if curses like POSIX Functions should be used */
#cmakedefine CURSES_ONLY 1

/* Defined if _XOPEN_SOURCE_EXTENDED needs to be defined. (Can't define
   globally as that will cause problems with some systems) */
#cmakedefine DEFINE_XOPEN_SOURCE_EXTENDED 1

/* Define to 1 if translation of program messages to the user's native
   language is requested. */
#cmakedefine ENABLE_NLS 1

/* Defined if filter version control should be used */
#cmakedefine FILTER_VERSION_CONTROL 1

/* Define if the GNU dcgettext() function is already present or preinstalled.
   */
#cmakedefine HAVE_DCGETTEXT 1

/* Define to 1 if you have the <dlfcn.h> header file. */
#cmakedefine HAVE_DLFCN_H 1

/* Defined if msdos getch is supported */
#cmakedefine HAVE_GETCH 1

/* Define if the GNU gettext() function is already present or preinstalled. */
#cmakedefine HAVE_GETTEXT 1

/* Define if you have the iconv() function. */
#cmakedefine HAVE_ICONV 1

/* Define to 1 if you have the <inttypes.h> header file. */
#cmakedefine HAVE_INTTYPES_H 1

/* Define if you have <langinfo.h> and nl_langinfo(CODESET). */
#cmakedefine HAVE_LANGINFO_CODESET 1

/* Defined if the curses library is available */
#cmakedefine HAVE_LIBCURSES 1

/* Define to 1 if you have the `dl' library (-ldl). */
#cmakedefine HAVE_LIBDL 1

/* Defined if mblen is supported */
#cmakedefine HAVE_MBLEN 1

/* Define to 1 if you have the <memory.h> header file. */
#cmakedefine HAVE_MEMORY_H 1

/* Defined if mmap and friends is supported */
#cmakedefine HAVE_MMAP 1

/* Define to 1 if you have the <stdint.h> header file. */
#cmakedefine HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#cmakedefine HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#cmakedefine HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#cmakedefine HAVE_STRING_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#cmakedefine HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#cmakedefine HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#cmakedefine HAVE_UNISTD_H 1

/* Defined if curses libraray includes wide character support */
#cmakedefine HAVE_WIDE_CURSES 1

/* Name of package */
#cmakedefine PACKAGE "@PACKAGE@"

/* Define to the version of this package. */
#cmakedefine PACKAGE_VERSION	"@PACKAGE_VERSION@"

/* Defined if Posix Termios is Supported */
#cmakedefine POSIX_TERMIOS 1

/* Defined if STL rel_ops pollute the global namespace */
#cmakedefine REL_OPS_POLLUTION 1

/* Defined if file ino is supported */
#cmakedefine USE_FILE_INO 1

/* Defined if file locking and truncating is supported */
#cmakedefine USE_FILE_LOCKS 1

/* Defined if Posix locales are supported */
#cmakedefine USE_LOCALE 1

/* Defined if Posix mutexes are supported */
#cmakedefine USE_POSIX_MUTEX 1

/* Defined if Posix regex are supported */
#cmakedefine USE_POSIX_REGEX 1

/* Version number of package */
#cmakedefine VERSION "@VERSION@"

#define C_EXPORT extern "C"

#endif /* ASPELL_SETTINGS__H */
