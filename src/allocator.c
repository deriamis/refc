#include <stdlib.h>

#include "allocator.h"

void *Allocator_default_alloc(size_t bytes, void *context) {
    (void)context;
    return malloc(bytes);
}

void Allocator_default_free(void *ptr, void *context) {
    (void)context;
    free(ptr);
}

void *Allocator_default_realloc(void *ptr, size_t size, void *context)
{
  (void)context;
  return realloc(ptr, size);
}

Allocator *const DEFAULT_ALLOCATOR = &(Allocator){
  Allocator_default_alloc,
  Allocator_default_free,
  Allocator_default_realloc,
  NULL
};

__thread Allocator *THREAD_CURRENT_ALLOCATOR = DEFAULT_ALLOCATOR;
