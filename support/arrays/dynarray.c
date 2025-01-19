#include <stddef.h>
#include <string.h>

#include "dynarray.h"

DynArray *DynArray_init(size_t item_size, size_t capacity, Allocator *allocator)
{
  if (allocator == NULL) allocator = THREAD_CURRENT_ALLOCATOR;
  if (capacity <= 0) {
    capacity = DYNARRAY_INIT_CAPACITY;
  } else {
    capacity = next_power_of_two(capacity);
  }

  size_t size = (item_size * capacity) + sizeof(DynArray_Header);
  DynArray_Header *header = allocator->alloc(size, allocator->context);

  if (header != NULL) {
    memset(header, 0, size);
    header->capacity = capacity;
    header->item_size = item_size;
    header->allocator = allocator;
  }

  memset(header + 1, 0, header->capacity);
  return (DynArray *)header;
}

void DynArray_free(DynArray *da)
{
  DynArray_Header *h = (DynArray_Header *)da;
  h->allocator->free(da, h->allocator->context);
}

size_t DynArray_length(DynArray *da)
{
  return ((DynArray_Header *)da)->length;
}

size_t DynArray_capacity(DynArray *da)
{
  return ((DynArray_Header *)da)->capacity;
}

void *DynArray_items(DynArray *da)
{
  return (DynArray_Header *)da + 1;
}

DynArray *DynArray_extend(DynArray *da, size_t n)
{
  DynArray_Header *h = (DynArray_Header *)da;
  size_t target_capacity = h->capacity + n;

  if (h->capacity <= target_capacity) {
    size_t new_capacity = h->capacity << 1;

    while (new_capacity < target_capacity) new_capacity = new_capacity << 1;
    new_capacity = (new_capacity * h->item_size) + sizeof(DynArray_Header);

    DynArray *new_da = h->allocator->realloc((DynArray_Header *)da, new_capacity, h->allocator->context);

    if (new_da != NULL) {
      h = (DynArray_Header *)new_da;
      da = new_da;
      h->capacity = new_capacity;
    } else {
      return NULL;
    }
  }

  return da;
}

DynArray *DynArray_append_items(DynArray *da, size_t n_items, void *items)
{
  DynArray_Header *h = (DynArray_Header *)da;
  DynArray *new_da = DynArray_extend(da, n_items);
  if (new_da == NULL) return NULL;
  da = new_da;

  memcpy((DynArray_Header *)da + (h->length * h->item_size), items, (n_items * h->item_size));
  h->length += n_items;
  return da;
}
