#include <stdlib.h>
#include <string.h>

#include "debug.h"

__thread unsigned int debug_indent_level = 0;
__thread char *debug_malloc_start = NULL;
__thread char *debug_malloc_end = NULL;

void *debug_malloc(char *file, size_t line, size_t size)
{
  size_t header_len = sizeof(void *) + strlen(file) + 1 + sizeof(size_t);
  size += header_len + 4;
  char *ptr = malloc(size);

  if (debug_malloc_end == NULL) {
    debug_malloc_end = (char *)&debug_malloc_start;
  }

  *(char **)debug_malloc_end = ptr;
  debug_malloc_end = ptr;
  *(char **)ptr = NULL;

  sprintf((ptr + sizeof(void *)), "%s%zu", file, line);
  ptr[header_len + 1] = ptr[size - 2] = 0xde;
  ptr[header_len + 2] = ptr[size - 1] = 0xad;

  return (void *)(ptr + sizeof(void *) + header_len);
}
