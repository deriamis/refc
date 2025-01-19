#include <stdio.h>
#include <stdlib.h>

#include "util.h"

size_t next_power_of_two(size_t n)
{
  n--;
  for (unsigned int shift_factor = 1; shift_factor < sizeof(size_t); ++shift_factor) {
    n |= n >> shift_factor;
  }
  n++;

  return n;
}

size_t digits_int(int value)
{
  return (size_t) snprintf(NULL, 0, "%d", value);
}

size_t digits_double(double value)
{
  return (size_t) snprintf(NULL, 0, "%lf", value);
}

#if LIBC == LIBC_WIN32

#else
#endif

NORETURN void error_exit(char *message)
{
  if (message != NULL) {
    fprintf(stderr, "%s\n\n", message);
  }
  exit(1);
}
