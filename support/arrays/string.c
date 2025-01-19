#include <string.h>

#include "../platform.h"
#include "dynarray.h"
#include "string.h"

StringBuilder *StringBuilder_init(size_t capacity, Allocator *allocator)
{
  return (StringBuilder *)DynArray_init(sizeof(STRING_TYPE), capacity, allocator);
}

StringBuilder *StringBuilder_from_cstr(const STRING_TYPE *s, Allocator *allocator)
{
  if (allocator == NULL) allocator = THREAD_CURRENT_ALLOCATOR;
  StringBuilder *new_sb = StringBuilder_init(strlen(s), allocator);
  if (new_sb == NULL) return NULL;
  memcpy(new_sb + 1, s, strlen(s));
  ((DynArray_Header *)new_sb)->length = strlen(s);
  return new_sb;
}

StringBuilder *StringBuilder_from_StringView(StringView *sv, Allocator *allocator)
{
  if (allocator == NULL) allocator = THREAD_CURRENT_ALLOCATOR;
  StringBuilder *new_sb = StringBuilder_init(sv->length, allocator);
  if (new_sb == NULL) return NULL;
  memcpy(new_sb + 1, sv->data, sv->length);
  ((DynArray_Header *)new_sb)->length = sv->length;
  return new_sb;
}

StringBuilder *StringBuilder_copy(StringBuilder *sb, Allocator *allocator)
{
  if (allocator == NULL) allocator = THREAD_CURRENT_ALLOCATOR;
  StringBuilder *new_sb = StringBuilder_init(((DynArray_Header *)sb)->capacity, allocator);
  if (new_sb == NULL) return NULL;
  memcpy(new_sb + 1, sb + 1, ((DynArray_Header *)sb)->length);
  ((DynArray_Header *)new_sb)->length = ((DynArray_Header *)sb)->length;
  return new_sb;
}

void StringBuilder_free(StringBuilder *sb)
{
  DynArray_free((DynArray *)sb);
}

size_t StringBuilder_length(const StringBuilder *sb)
{
  return ((DynArray_Header *)sb)->length;
}

size_t StringBuilder_capacity(const StringBuilder *sb)
{
  return ((DynArray_Header *)sb)->capacity;
}

StringBuilder *StringBuilder_extend(StringBuilder *sb, size_t n)
{
  return (StringBuilder *)DynArray_extend((DynArray *)sb, n);
}

StringBuilder *StringBuilder_append(StringBuilder *sb, size_t n, STRING_TYPE *s)
{
  StringBuilder *new_sb = (StringBuilder *)DynArray_append_items((DynArray *)sb, n, s);
  DynArray_Header *new_h = (DynArray_Header *)new_sb;
  if (!s[n]) new_h->length = new_h->length - 1;
  return new_sb;
}

StringBuilder *StringBuilder_concat(StringBuilder *sb1, size_t n, StringBuilder *sb2)
{
  return (StringBuilder *)DynArray_append_items((DynArray *)sb1, n, sb2 + 1);
}

STRING_TYPE *StringBuilder_cstr(StringBuilder *sb)
{
  return (STRING_TYPE*)(sb + 1);
}

StringView StringBuilder_build(StringBuilder *sb)
{
  return (StringView) {
    .length = ((DynArray_Header *)sb)->length,
    .data = (STRING_TYPE *)(sb + 1),
  };
}

void StringBuilder_clear(StringBuilder *sb)
{
  DynArray_Header *h = (DynArray_Header *)sb;
  memset(sb + 1, 0, h->length);
  h->length = 0;
}

bool StringBuilder_is_empty(StringBuilder *sb)
{
  return ((DynArray_Header *)sb)->length == 0;
}

bool StringBuilder_equal(StringBuilder *sb1, StringBuilder *sb2)
{
  DynArray_Header *h1 = (DynArray_Header *)sb1;
  DynArray_Header *h2 = (DynArray_Header *)sb2;
  return h1->length == h2->length && (memcmp(sb1 + 1, sb2 + 1, h1->length) == 0);
}

StringView StringView_from_cstr(const STRING_TYPE *s)
{
  return (StringView) {
    .length = strlen(s),
    .data = s,
  };
}

size_t StringView_length(StringView *sv)
{
  return sv->length;
}

const STRING_TYPE *StringView_cstr(StringView *sv)
{
  return sv->data;
}

bool StringView_is_empty(StringView *sv)
{
  return sv->length == 0;
}

bool StringView_equal(StringView *sv1, StringView *sv2)
{
  return sv1->length == sv2->length && (memcmp(sv1->data, sv2->data, sv1->length) == 0);
}
