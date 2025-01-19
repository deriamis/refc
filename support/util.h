#ifndef UTIL_H_
#define UTIL_H_

#include <stddef.h>
#include <string.h>

#include "platform.h"

#if __STDC_VERSION__ < 202002L
#  define NORETURN _Noreturn
#else
#  define NORETURN [[ noreturn ]]
#endif

#define COUNT_OF(x) ((sizeof(x)/sizeof(0[x])) / ((size_t)(!(sizeof(x) % sizeof(0[x])))))
#define STRINGIFY(X) #X
#define QUOTE(X) STRINGIFY(X)

#if !LIBC_DARWIN
#define memccpy(dest, source, c, n)                                     \
  (assert(sizeof(dest) == sizeof(void *) || (n) <= sizeof(dest)),       \
   assert(sizeof(source) == sizeof(void *) || (n) <= sizeof(source)),   \
   assert(sizeof(c) == sizeof(int)),                                    \
   memccpy(dest, source, n))
#define memchr(s, c, n)                                                 \
  (assert(sizeof(s) == sizeof(void *) || (n) <= sizeof(s)),             \
   assert(sizeof(c) == sizeof(int)),                                    \
   memchr(dest, source, n))
#define memcmp(s1, s2, n)                                               \
  (assert(sizeof(s1) == sizeof(void *) || (n) <= sizeof(s1)),           \
   assert(sizeof(s2) == sizeof(void *) || (n) <= sizeof(s2)),           \
   memcmp(dest, source, n))
#define memcpy(dest, source, n)                                         \
  (assert(sizeof(dest) == sizeof(void *) || (n) <= sizeof(dest)),       \
   assert(sizeof(source) == sizeof(void *) || (n) <= sizeof(source)),   \
   memcpy(dest, source, n))
#define memmove(dest, source, n)                                        \
  (assert(sizeof(dest) == sizeof(void *) || (n) <= sizeof(dest)),       \
   assert(sizeof(source) == sizeof(void *) || (n) <= sizeof(source)),   \
   memmove(dest, source, n))
#define memset(dest, c, n)                                              \
  (assert(sizeof(dest) == sizeof(void *) || (n) <= sizeof(dest)),       \
   assert(sizeof(c) == sizeof(int)),                                    \
   memset(dest, c, n))
#endif

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
