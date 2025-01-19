#ifndef PLATFORM_H_
#define PLATFORM_H_

/*
 * Detect the compiler currently in use.
 */
#define COMPILER_UNKNOWN 0
#define COMPILER_MSVC    1
#define COMPILER_MINGW   2
#define COMPILER_GCC     3
#define COMPILER_CLANG   4

#if defined(_MSC_VER) && !defined(__INTEL_COMPILER)
#  define COMPILER         COMPILER_MSVC
#  define COMPILER_NAME    "MSVC"
#  define COMPILER_VERSION _MSC_FULL_VER
#elif (defined(__GNUC__) || defined(__GNUG__)) && !defined(__clang__)
#  if defined(__MINGW64__) || defined(__MINGW32__)
#    define COMPILER         COMPILER_MINGW
#    define COMPILER_NAME    "MinGW"
#    if defined(__MINGW64__)
#      define COMPILER_VERSION COMPILER_VERSION##/##__MINGW64__VERSION_MAJOR##.##__MINGW64_VERSION_MINOR
#    else
#      define COMPILER_VERSION __GNUC_VERSION__##/##__MINGW32__MAJOR_VERSION##.##__MINGW32_MINOR_VERSION
#    endif
#  else
#    define COMPILER         COMPILER_GCC
#    define COMPILER_NAME    "GCC"
#    define COMPILER_VERSION __GNUC_VERSION__
#  endif
#elif defined(__clang__)
#  define COMPILER         COMPILER_CLANG
#  define COMPILER_NAME    "Clang"
#  define COMPILER_VERSION __clang_version__
#else
#define COMPILER         COMPILER_UNKNOWN
#define COMPILER_NAME    "Unknown"
#define COMPILER_VERSION "Unknown"
#endif

/*
 * Detect the libc currently in use
 */
#define LIBC_UNKNOWN 0
#define LIBC_WIN32   1
#define LIBC_ANDROID 2
#define LIBC_NEWLIB  3
#define LIBC_GLIBC   4
#define LIBC_LLVM    5
#define LIBC_DARWIN  6
#define LIBC_BSD     7
#define LIBC_MUSL    8

#if defined(_MSC_VER) && !defined(__INTEL_COMPILER)
#  define LIBC       LIBC_WIN32
#  define LIBC_NAME  "Win32"
#elif defined(__MSYS__) || defined(__CYGWIN__) || defined(__MINGW64__) || defined(__MINGW32__)
#  define LIBC       LIBC_WIN32
#  define LIBC_NAME  "Win32"
#elif defined(__ANDROID__)
#  define LIBC       LIBC_ANDROID
#  define LIBC_NAME "Android"
#elif defined(__NEWLIB__)
#  define LIBC       LIBC_NEWLIB
#  define LIBC_NAME "Newlib"
#elif defined(__GLIBC__)
#  define LIBC       LIBC_GNU
#  define LIBC_NAME "GNU"
#elif defined(__LLVM_LIBC__)
#  define LIBC       LIBC_LLVM
#  define LIBC_NAME "LLVM"
#elif defined(__APPLE__) && defined(__MACH__)
#  define LIBC       LIBC_DARWIN
#  define LIBC_NAME "Darwin"
#else
#  include <sys/param.h>
#  include <stdarg.h>
#  if defined(BSD)
#    define LIBC       LIBC_BSD
#    define LIBC_NAME "BSD"
/* First heuristic to detect musl libc.  */
#  elif defined(__DEFINED_va_list)
#    define LIBC       LIBC_MUSL
#    define LIBC_NAME "MUSL"
#  else
#    define LIBC       LIBC_UNKNOWN
#    define LIBC_NAME "Unknown"
#  endif
#endif

/*
 * Detect the host bit width
 */
#if defined(__LP64__) || defined(_WIN64)
#  define HOST_BITS 64
#else
#  define HOST_BITS 32
#endif

#if LIBC == LIBC_WIN32
#  define WIN32_LEAN_AND_MEAN
#  define WIN64_LEAN_AND_MEAN
#  if defined(UNICODE)
#    define _UNICODE
#  endif
#  include <windows.h>
#  include <tchar.h>
#  define ARGV_TYPE _TCHAR
#  define STRING_TYPE _TCHAR
#else
#  define _tmain main
// TODO: Newlib is not a complete standard implementation,
// so we need libicu installed for it.
#  if LIBC_NEWLIB
#    include <unicode/uchar.h>
#  else
#    include <uchar.h>
#  endif
#  define ARGV_TYPE char
#  if defined(UNICODE)
#    define STRING_TYPE char32_t
#  else
#    define STRING_TYPE char
#  endif
#endif

#endif /* PLATFORM_H_ */
