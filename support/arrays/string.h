#ifndef STRING_H_
#define STRING_H_

#include <stddef.h>
#include <stdbool.h>

#include "../platform.h"
#include "../allocator.h"
#include "dynarray.h"

#define STRING_INIT_CAPACITY 256

typedef struct DynArray *StringBuilder;

typedef struct {
  size_t length;
  const STRING_TYPE *data;
} StringView;

StringBuilder *StringBuilder_init(size_t capacity, Allocator *allocator);
StringBuilder *StringBuilder_from_cstr(const STRING_TYPE *s, Allocator *allocator);
StringBuilder *StringBuilder_from_StringView(StringView *sv, Allocator *allocator);
StringBuilder *StringBuilder_copy(StringBuilder *sb, Allocator *allocator);
void StringBuilder_free(StringBuilder *sb);
size_t StringBuilder_length(const StringBuilder *sb);
size_t StringBuilder_capacity(const StringBuilder *sb);
StringBuilder *StringBuilder_extend(StringBuilder *sb, size_t n);
StringBuilder *StringBuilder_append(StringBuilder *sb, size_t n, STRING_TYPE *s);
StringBuilder *StringBuilder_concat(StringBuilder *sb1, size_t n, StringBuilder *sb2);
STRING_TYPE *StringBuilder_cstr(StringBuilder *sb);
StringView StringBuilder_build(StringBuilder *sb);
void StringBuilder_clear(StringBuilder *sb);
bool StringBuilder_is_empty(StringBuilder *sb);
bool StringBuilder_equal(StringBuilder *sb1, StringBuilder *sb2);

StringView StringView_from_cstr(const STRING_TYPE *s);
size_t StringView_length(StringView *sv);
const STRING_TYPE *StringView_cstr(StringView *sv);
bool StringView_is_empty(StringView *sv);
bool StringView_equal(StringView *sb1, StringView *sb2);

StringView StringView_next_by_delimiter(const StringView *sv, STRING_TYPE delim);
StringView StringView_trim_left(const StringView *sv);
StringView StringView_trim_right(const StringView *sv);
StringView StringView_trim(const StringView *sv);

#endif // STRING_H_
