#include <stdlib.h>
#include <string.h>

#include "allocator.h"

typedef struct {
  void *prev_block;
  void *next_block;
  char *file;
  size_t line;
} AllocHeader;

typedef struct {
  AllocHeader header;
  char lead_padding[ALLOC_PADDING_LEN];
  void *data;
  char end_padding[ALLOC_PADDING_LEN];
} AllocBlock;

Allocator *const DEFAULT_ALLOCATOR = &(Allocator){
  Allocator_default_alloc,
  Allocator_default_free,
  Allocator_default_realloc,
  NULL
};

__thread unsigned int debug_indent_level = 0;
__thread void *debug_malloc_start = NULL;
__thread void *debug_malloc_end = NULL;

// #ifndef NDEBUG
__thread Allocator *THREAD_CURRENT_ALLOCATOR = DEFAULT_ALLOCATOR;
// #else
// #endif

// TODO: Implement the debug free and realloc
void *Allocator_debug_alloc(char *file, size_t line, size_t size, void *context)
{
  (void) context;

  size_t block_size = sizeof(AllocHeader) + (strlen(file) * sizeof(char));
  block_size += sizeof(AllocBlock) - sizeof(void *) + size;

  AllocBlock *block = malloc(block_size);
  memset(block, 0, block_size);

  if (debug_malloc_start == NULL) {
    debug_malloc_start = block;
    block->header.prev_block = NULL;
  } else {
    ((AllocBlock *)debug_malloc_end)->header.next_block = block;
    block->header.prev_block = debug_malloc_end;
  }

  debug_malloc_end = block;

  block->header.file = file;
  block->header.line = line;

  memcpy(block->lead_padding, ALLOC_PADDING_BYTES, ALLOC_PADDING_LEN);
  memcpy(block->end_padding, ALLOC_PADDING_BYTES, ALLOC_PADDING_LEN);

  return block->data;
}

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

