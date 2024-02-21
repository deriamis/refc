#include <stdio.h>

#include "arrays/dynarray.h"

int main(int argc, char **argv)
{
  (void)argc;
  (void)argv;

  int *intarray = DynArray(int, NULL);
  intarray = DynArray_append(intarray, 1);
  intarray = DynArray_append(intarray, 2);
  intarray = DynArray_append(intarray, 3);

  printf("First:\n");
  for (size_t i = 0; i < DynArray_length(intarray); ++i) printf("  %d\n", intarray[i]);

  int more_nums[] = {4, 5, 6};
  intarray = DynArray_append_all(intarray, more_nums);

  printf("\nSecond:\n");
  for (size_t i = 0; i < DynArray_length(intarray); ++i) printf("  %d\n", intarray[i]);

  return 0;
}
