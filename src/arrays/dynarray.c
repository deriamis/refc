#include <stddef.h>
#include <string.h>

#include "dynarray.h"

void *DynArray_init(size_t item_size, size_t capacity, Allocator *allocator)
{
  if (allocator == NULL) allocator = THREAD_CURRENT_ALLOCATOR;
  if (capacity <= 0) {
    capacity = DYNARRAY_INIT_CAPACITY;
  } else {
    capacity = next_power_of_two(capacity);
  }

  void *ptr = NULL;
  size_t size = (item_size * capacity) + sizeof(DynArray_Header);
  DynArray_Header *header = allocator->alloc(size, allocator->context);

  if (header != NULL) {
    memset(header, 0, size);
    header->capacity = capacity;
    header->item_size = item_size;
    header->allocator = allocator;
    ptr = header + 1;
  }

  return ptr;
}

size_t DynArray_length(void *array)
{
  return DynArray_get_header(array)->length;
}

size_t DynArray_capacity(void *array)
{
  return DynArray_get_header(array)->capacity;
}

void *DynArray_extend(void *array, size_t n)
{
  DynArray_Header *header = DynArray_get_header(array);
  size_t target_capacity = header->capacity + n;

  if (header->capacity < target_capacity) {
    size_t new_capacity = header->capacity << 1;

    while (new_capacity < target_capacity) new_capacity = new_capacity << 1;
    new_capacity = (new_capacity * header->item_size) + sizeof(DynArray_Header);

    DynArray_Header *new_header = header->allocator->realloc(header, new_capacity, header->allocator->context);

    if (new_header != NULL) {
      header = new_header;
      header->capacity = new_capacity;
    } else {
      return NULL;
    }
  }

  return header + 1;
}

void *DynArray_append_items(void *array, size_t n_items, void *items)
{
  DynArray_Header *header = DynArray_get_header(array);

  array = DynArray_extend(array, n_items);
  if (array == NULL) return NULL;
  header = DynArray_get_header(array);

  memcpy((char *)array + (header->length * header->item_size), items, (n_items * header->item_size));
  header->length += n_items;
  return array;
}
