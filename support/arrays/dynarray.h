#ifndef DYNARRAY_H_
#define DYNARRAY_H_

#include <stddef.h>

#include "../util.h"
#include "../allocator.h"

#define DYNARRAY_INIT_CAPACITY 4 * 1024

typedef struct {
  size_t length;
  size_t capacity;
  size_t item_size;
  Allocator *allocator;
} DynArray_Header;

typedef struct DynArray_Header *DynArray;

DynArray *DynArray_init(size_t item_size, size_t capacity, Allocator *allocator);
void DynArray_free(DynArray *da);
size_t DynArray_length(DynArray *da);
size_t DynArray_capacity(DynArray *da);
void *DynArray_items(DynArray *da);
DynArray *DynArray_extend(DynArray *da, size_t n);
DynArray *DynArray_append_items(DynArray *da, size_t n_items, void *item);

#define Array(T, a) DynArray_init(sizeof(T), DYNARRAY_INIT_CAPACITY, (a))
#define Array_items(T, a) = (T)DynArray_items((a))
#define Array_append(a, v) (                                              \
                            (a) = DynArray_extend((a), 1),                \
                            (a)[DynArray_get_header(a)->length] = (v),    \
                            &(a)[DynArray_get_header(a)->length++],       \
                            (a))
#define Array_append_all(a, i) DynArray_append_items((a), COUNT_OF(i), i)

#endif // DYNARRAY_H_
