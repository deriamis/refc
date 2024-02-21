#ifndef DEBUG_H_
#define DEBUG_H_

#include <stddef.h>
#include <stdio.h>

extern __thread char *debug_malloc_start;
extern __thread char *debug_malloc_end;
extern __thread unsigned int debug_indent_level;

void *debug_malloc(char *file, size_t line, size_t size);

#ifndef NDEBUG
#define debug_f stderr

#ifdef TRACE
#define EXPR(t, q) (fprintf(debug_f, "[TRACE]: %s:%d:%s(): %s --> " t "\n", __FILE__, __LINE__, __func__, ##q, q))
#define TRACE_PRINTF(fmt, ...) fprintf(debug_f, "[TRACE]: %s:%d:%s(): ", fmt, __FILE__, __LINE__, __func__ __VA_OPT__(,) ##__VA_ARGS__)
#define TRACE_CALL_VOID(func, ...)                      \
  (TRACE_PRINTF("%*s> %s()", #func))
#define malloc(size) debug_malloc(__FILE__, __LINE__, size)
#define memccpy(dest, source, c, n)                                     \
  (assert(sizeof(dest) == sizeof(void *) || (n) <= sizeof(dest)),       \
   assert(sizeof(source) == sizeof(void *) || (n) <= sizeof(source)),   \
   assert(sizeof(c) == sizeof(int))                                     \
   memccpy(dest, source, n))
#define memchr(s, c, n)                                                 \
  (assert(sizeof(s) == sizeof(void *) || (n) <= sizeof(s)),             \
   assert(sizeof(c) == sizeof(int))                                     \
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
   assert(sizeof(c) == sizeof(int))                                     \
   memset(dest, c, n))
#else
#define EXPR(t, q) (q)
#define TRACE_PRINTF(fmt, ...)

#endif // TRACE
#endif // NDEBUG

#endif // DEBUG_H_
