#ifndef UTIL_H_POSIX_
#define UTIL_H_POSIX_

#include <stdbool.h>

char *canonical_path_posix(const char *path);
bool is_directory_posix(const char *path);
bool is_file_posix(const char *path);
bool is_symlink_posix(const char *path);
char *get_environment_var_posix(const char* name);

#endif // UTIL_H_POSIX_
