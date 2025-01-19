#include "util.h"

#  define realpath(N,R) _fullpath((R),(N),PATH_MAX)
#  define S_ISREG(m)    (((m) & S_IFMT) == _S_IFREG)
#  define S_ISDIR(m)    (((m) & S_IFMT) == _S_IFDIR)

LPCWSTR canonical_path_windows(const LPCWSTR path)
{
  char msg_buf[MSG_BUF_MAX] = {0};
  wchar_t canonical_path[32767] = {0};
  wchar_t filename[FILENAME_MAX] = {0};
  wchar_t file_directory[PATH_MAX] = {0};

  if (path == NULL) return NULL;

  if (realpath(path, canonical_path) == NULL) {
    snprintf(msg_buf, MSG_BUF_MAX, "Failed to get real path: `%s': %s", path, strerror(errno));
    return NULL;
  }

  char win_drive[_MAX_DRIVE] = {0};
  char file_extension[_MAX_EXT] = {0};

  errcode_t errcode = _splitpath_s(path, win_drive, _MAX_DRIVE, file_directory, PATH_MAX, filename, FILENAME_MAX, extension, _MAX_EXT);
  if (errcode != 0) {
    snprintf(msg_buf, MSG_BUF_MAX, "Failed to split path. Error code: %d", errcode);
    return NULL;
  }

  _makepath(canonical_path, win_drive, file_directory, filename, extension);
  return strdup(canonical_path);
}

bool is_symlink_windows(const LPCWSTR path)
{
  LPCWSTR wc_path;
  DWORD fileAttributes = GetFileAttributes(path);
  return false;
}
