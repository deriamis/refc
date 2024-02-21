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
