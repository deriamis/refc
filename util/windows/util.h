#ifndef UTIL_H_WINDOWS_
#define UTIL_H_WINDOWS_

#define WIN32_LEAN_AND_MEAN
#define WIN64_LEAN_AND_MEAN
#include <windows.h>
#include <fileapi.h>
#include <stdbool.h>

#define strdup        _strdup
#define stat          _stat

char *canonical_path_windows(const char *path);
bool is_directory_windows(const char *path);
bool is_file_windows(const char *path);
bool is_symlink_windows(const char *path);

#endif // UTIL_H_WINDOWS_
