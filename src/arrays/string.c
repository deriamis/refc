#include "string.h"
#include "dynarray.h"

#include "dynarray.h"

typedef struct {
  char *c_str;
} StringData;

typedef struct {
  DynArray_Header header;
  StringData data;
} StringContainer;
