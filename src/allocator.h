#ifndef ALLOCATOR_H_
#define ALLOCATOR_H_

#include <stddef.h>

typedef struct {
  void *(*alloc)(size_t bytes, void *context);
  void (*free)(void *ptr, void *context);
  void *(*realloc)(void *ptr, size_t size, void* context);
  void *context;
} Allocator;

void *Allocator_default_alloc(size_t bytes, void *context);
void Allocator_default_free(void *ptr, void *context);
void *Allocator_default_realloc(void *ptr, size_t size, void *context);

extern Allocator *const DEFAULT_ALLOCATOR;
extern __thread Allocator *THREAD_CURRENT_ALLOCATOR;

#endif // ALLOCATOR_H_
