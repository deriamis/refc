#ifndef DEBUG_H_
#define DEBUG_H_

#include <stddef.h>
#include <stdio.h>

#ifndef NDEBUG
#define debug_f stderr
// TODO: Make the debug allocator selectable
//#include "allocator.h"
//#define malloc(size) Allocator_debug_alloc(__FILE__, __LINE__, size, NULL)

#ifdef TRACE
#define EXPR(t, q) (fprintf(debug_f, "[TRACE]: %s:%d:%s(): %s --> " t "\n", __FILE__, __LINE__, __func__, ##q, q))
#define TRACE_PRINTF(fmt, ...) fprintf(debug_f, "[TRACE]: %s:%d:%s(): ", fmt, __FILE__, __LINE__, __func__ __VA_OPT__(,) ##__VA_ARGS__)
#define TRACE_CALL_VOID(func, ...)                      \
  (TRACE_PRINTF("%*s> %s()", #func))
#else
#define EXPR(t, q) (q)
#define TRACE_PRINTF(fmt, ...)

#endif // TRACE
#endif // NDEBUG

#endif // DEBUG_H_
