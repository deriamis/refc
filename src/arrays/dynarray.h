#ifndef DYNARRAY_H_
#define DYNARRAY_H_

#include <stddef.h>
#include <stdbool.h>

#include "../util.h"
#include "../allocator.h"

typedef struct {
  size_t length;
  size_t capacity;
  size_t item_size;
  Allocator *allocator;
} DynArray_Header;

void *DynArray_init(size_t item_size, size_t capacity, Allocator *allocator);
size_t DynArray_length(void *dynarray);
size_t DynArray_capacity(void *dynarray);
void *DynArray_extend(void *dynarray, size_t n);
void *DynArray_append_items(void *dynarray, size_t n_items, void *item);

#define DYNARRAY_INIT_CAPACITY 4 * 1024
#define DynArray_get_header(a) ((DynArray_Header *)((a)) - 1)

#define DynArray(T, a) DynArray_init(sizeof(T), DYNARRAY_INIT_CAPACITY, (a))
#define DynArray_append(a, v) (                                              \
                               (a) = DynArray_extend((a), 1),                \
                               (a)[DynArray_get_header(a)->length] = (v),    \
                               &(a)[DynArray_get_header(a)->length++],       \
                               (a))
#define DynArray_append_all(a, i) DynArray_append_items((a), COUNT_OF(i), i)

#endif // DYNARRAY_H_
