#ifndef UTIL_H_
#define UTIL_H_

#include <stddef.h>

#ifndef CONFIGURED
#include "configure/configure.h"
#endif

#if __STDC_VERSION__ < 202002L
#  define NORETURN _Noreturn
#else
#  define NORETURN [[ noreturn ]]
#endif

#define COUNT_OF(x) ((sizeof(x)/sizeof(0[x])) / ((size_t)(!(sizeof(x) % sizeof(0[x])))))
#define STRINGIFY(X) #X
#define QUOTE(X) STRINGIFY(X)

size_t next_power_of_two(size_t n);
NORETURN void error_exit(char *message);

size_t digits_int(int value);
size_t digits_double(double value);
#define digits(X) _Generic((X), \
                           double: digits_double, \
                              int: digits_int     \
                           )(X)

#if LIBC == LIBC_WIN32
#  include "windows/util.h"
#  define canonical_path(P) canonical_path_windows((P))
#  define is_directory(P)   is_directory_windows((P))
#  define is_file(P)        is_file_windows((P))
#  define is_symlink(P)     is_symlink_windows((P))
#else
#  include "posix/util.h"
#  define canonical_path(P)      canonical_path_posix((P))
#  define is_directory(P)        is_directory_posix((P))
#  define is_file(P)             is_file_posix((P))
#  define is_symlink(P)          is_symlink_posix((P))
#endif

#endif // UTIL_H_
