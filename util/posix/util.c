#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <libgen.h>

#if LIBC == LIBC_DARWIN || LIBC == LIBC_BSD
#include <sys/syslimits.h>
#else
#include <limits.h>
#endif

#include "util.h"

char *canonical_path_posix(const char *path)
{
  char real_path[PATH_MAX] = {0};
  char filename[FILENAME_MAX] = {0};
  char file_directory[PATH_MAX] = {0};
  char canonical_path[PATH_MAX] = {0};

  if (path == NULL) return NULL;

  if (realpath(path, real_path) == NULL) {
    strncpy(filename, basename((char *)path), FILENAME_MAX);

    if ((strncmp(filename, "/", 1) == 0 || strncmp(filename, "..", 2) == 0) ||
        (strncmp(filename, ".", 1) == 0 && strnlen(filename, FILENAME_MAX) == 1)) {
      fprintf(stderr, "Failed to get real path: `%s': %s\n", path, strerror(errno));
      return NULL;
    }
  }

  memset(filename, 0, FILENAME_MAX);
  strncpy(filename, basename(real_path), FILENAME_MAX);
  strncpy(file_directory, dirname(real_path), PATH_MAX);

  snprintf(canonical_path, PATH_MAX, "%s/%s", file_directory, filename);
  return strdup(canonical_path);
}

bool is_symlink_posix(const char *path)
{
  struct stat path_stat = {0};

  stat(path, &path_stat);
  return S_ISLNK(path_stat.st_mode);
}

bool is_directory_posix(const char *path)
{
  struct stat path_stat = {0};

  stat(path, &path_stat);
  return S_ISDIR(path_stat.st_mode);
}

bool is_file_posix(const char *path)
{
  struct stat path_stat = {0};

  stat(path, &path_stat);
  return S_ISREG(path_stat.st_mode) || S_ISLNK(path_stat.st_mode);
}

char *get_environment_var_posix(const char* name)
{
  return strdup(getenv(name));
}
