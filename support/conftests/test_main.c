#include "../platform.h"

#if LIBC == LIBC_WIN32
#  define WIN32_LEAN_AND_MEAN
#  define WIN64_LEAN_AND_MEAN
#  include "windows.h"
#endif

int main(int argc, char** argv)
{
    (void)argc;
    (void)argv;

    return 0;
}
