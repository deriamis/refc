#include <stdio.h>

#include "util.h"

int main(int argc, char** argv)
{
  printf("%zu\n", next_power_of_two(1));
  printf("%zu\n", next_power_of_two(10));
  printf("%zu\n", next_power_of_two(100));
  printf("%zu\n", next_power_of_two(1000));
}
