#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>
#include <errno.h>
#include <limits.h>
#include <ctype.h>

#include "platform.h"

#include "util.c"
#include "allocator.c"
#include "arrays/dynarray.c"
#include "arrays/string.c"

#define MSG_BUF_MAX 255

typedef char *(*format_fn)(const char *var_name, const char *var_value,
                           const char *file, size_t line);

static char *env_vars[] = {
  "CPP", "CC", "CXX", "LD", "AR", "AS", "RANLIB", "OBJCOPY", "DSYMUTIL",
  "STRIP", "CPPFLAGS", "CFLAGS", "CXXFLAGS", "LDFLAGS", "LDLIBS", "LIBS"
};

static char *unprefixed_vars[] = {
  "CONFIGURED", "SHARED", "STATIC", "DEBUG", "HOST_MACHINE"
};

char *format_define(const char *var_name, const char *var_value,
                    const char *file, size_t line)
{
  assert(var_name != NULL && var_value != NULL && file != NULL);

  char *prefix = "CONFIG_";
  for (size_t i = 0; i < COUNT_OF(unprefixed_vars); i++) {
    if (strcmp(unprefixed_vars[i], var_name) == 0) {
      prefix = "";
      break;
    }
  }
  size_t needed = (size_t) snprintf(NULL, 0, "#define %s%s %s    /* %s:%zu */",
                                    prefix, var_name, var_value, file, line) + 1;

  char *buffer = malloc(needed * sizeof(char));
  if (buffer == NULL) {
    fprintf(stderr, "Failed to allocate memory for buffer in format_define()");
    abort();
  }

  snprintf(buffer, needed, "#define %s%s %s    /* %s:%zu */",
           prefix, var_name, var_value, file, line);
  return buffer;
}

char *format_makefile(const char *var_name, const char *var_value,
                      const char *file, size_t line)
{
  assert(var_name != NULL && var_value != NULL && file != NULL);

  size_t needed = (size_t) snprintf(NULL, 0, "# %s:%zu\n%s = %s",
                                    file, line, var_name, var_value) + 1;

  char *buffer = malloc(needed * sizeof(char));
  if (buffer == NULL) {
    fprintf(stderr, "Failed to allocate memory for buffer in format_makefile()");
    abort();
  }

  snprintf(buffer, needed, "# %s:%zu\n%s = %s", file, line, var_name, var_value);
  return buffer;
}

void print_str_var(FILE *fh, const format_fn fn, const char *var_name,
                   const char *var_value, const char *file, size_t line)
{
  assert(fh != NULL && var_name != NULL && var_value != NULL && file != NULL);
  char *define = (*fn)(var_name, var_value, file, line);
  fprintf(fh, "%s\n", define);
  free(define);
  return;
}

void print_int_var(FILE *fh, const format_fn fn, const char *var_name,
                   int var_value, const char *file, size_t line)
{
  assert(fh != NULL && var_name != NULL && file != NULL);

  size_t needed = digits_int(var_value) + 1;

  char *buffer = malloc(needed * sizeof(char));
  if (buffer == NULL) {
    fprintf(stderr, "Failed to allocate memory for buffer in print_int_var()");
    abort();
  }

  snprintf(buffer, needed, "%d", var_value);
  print_str_var(fh, fn, var_name, buffer, file, line);

  free(buffer);
  return;
}

void print_double_var(FILE *fh, const format_fn fn, const char *var_name,
                      double var_value, const char *file, size_t line)
{
  assert(fh != NULL && var_name != NULL && file != NULL);

  size_t needed = digits_double(var_value) + 1;

  char *buffer = malloc(needed * sizeof(char));
  if (buffer == NULL) {
    fprintf(stderr, "Failed to allocate memory for buffer in print_double_var()");
    abort();
  }

  snprintf(buffer, needed, "%lf", var_value);
  print_str_var(fh, fn, var_name, buffer, file, line);

  free(buffer);
  return;
}

#define print_var(fh, format_fn, var_name, var_value) _Generic((var_value),              \
                                                               char *: print_str_var,    \
                                                               double: print_double_var, \
                                                                 bool: print_int_var,    \
                                                                  int: print_int_var     \
                                                               )(fh, fn, var_name, var_value, __FILE__, __LINE__)


void print_usage(FILE *fh, const ARGV_TYPE *prog_name) {
  assert(fh != NULL && prog_name != NULL);

  fprintf(fh, "%s: Write a C/C++ configuration file\n\n", prog_name);
  fprintf(fh, "Usage:\n");
  fprintf(fh, "  %s [-h | --help]\n", prog_name);
  fprintf(fh, "  %s [options] <-f FORMAT> <-o|--output PATH>\n\n", prog_name);
  fprintf(fh, "Options:\n");
  fprintf(fh, "  -h, --help                              Show this message\n");
  fprintf(fh, "  --strict                                Require strict standard conformance\n");
  fprintf(fh, "  -f, --format                            Output file format\n\n");
  fprintf(fh, "Arguments:\n");
  fprintf(fh, "  FORMAT                                  File format to write: makefile, config.h (default)\n");
  fprintf(fh, "  PATH                                    Path of file to write\n\n");
}

typedef enum ARGUMENT_TYPE {
  FLAG,
  COUNTER,
  OPTION,
  WITH_OPTION,
  PARAMETER,
  PARAMETER_LIST,
} ARGUMENT_TYPE;

typedef struct {
  StringView name;
  bool value;
} FlagArgument;

typedef struct {
  StringView name;
  uint8_t value;
} CounterArgument;

typedef struct {
  bool is_enabled;
  StringView name;
  StringView *value;
  StringView *default_value;
  StringView *metavar;
} OptionArgument;

typedef struct {
  StringView *value;
  StringView *metavar;
} ParameterArgument;

typedef struct {
  ARGUMENT_TYPE arg_type;
  bool is_required;
  STRING_TYPE short_name;
  StringView help_text;
  union {
    FlagArgument flag;
    CounterArgument counter;
    OptionArgument option;
    ParameterArgument *parameter;
  };
} CmdArgument;

typedef struct {
  StringView program_name;
  StringView *options;
  StringView *brief_description;
  StringView *long_description;
  StringView *notes;
} CmdDef;

CmdArgument *parse_argument(size_t optind, DynArray *argv)
{
  return NULL;
}

DynArray *parse_arguments(int argc, ARGV_TYPE *argv, StringView *optargs)
{
  DynArray *args = Array(StringView, NULL);
  StringView current_arg;
  StringView next_arg;

  if (argc > 0) {
    current_arg = "";
  }

  for (size_t i = 1; i < (size_t)argc - 1; i++) {
  }
}

int _tmain(int argc, ARGV_TYPE *argv[])
{
  char msg_buf[MSG_BUF_MAX] = {0};
  STRING_TYPE *prog_name;
  DynArray *program_args = Array(CmdArgument, NULL);

  if (argc == 0 || argv[0] == NULL) {
    prog_name = "configure";
  } else {
    prog_name = argv[0];
  }

  if (argc == 1) {
    print_usage(stderr, prog_name);
    return 1;
  }

  for (size_t arg_num = 1; arg_num <= (size_t) argc - 1; arg_num++) {
    if (strcmp(argv[arg_num], "--help") == 0 || strcmp(argv[arg_num], "-h") == 0) {
      print_usage(stdout, prog_name);
      return 0;
    } else if (strcmp(argv[arg_num], "--enable-shared") == 0) {
      enable_shared = true;
    } else if (strcmp(argv[arg_num], "--enable-static") == 0) {
      enable_static = true;
    } else if (strcmp(argv[arg_num], "-f") == 0 || strcmp(argv[arg_num], "--format") == 0) {
      arg_num++;
      if (argv[arg_num] == NULL) {
        fprintf(stderr, "An output format is required\n\n");
        print_usage(stderr, prog_name);
        return 1;
      }
      out_format = strdup(argv[arg_num]);
      for (char *p = out_format; *p; p++ ) *p = (char)tolower(*p);
    } else if (strcmp(argv[arg_num], "-o") == 0 || strcmp(argv[arg_num], "--output") == 0) {
      arg_num++;
      if (argv[arg_num] == NULL) {
        fprintf(stderr, "An output file is required\n\n");
        print_usage(stderr, prog_name);
        return 1;
      }
      out_file_path = canonical_path(argv[arg_num]);
    } else {
      fprintf(stderr, "Unknown argument: %s\n\n", argv[arg_num]);
      print_usage(stderr, prog_name);
      return 1;
    }
  }

  if (out_file_path == NULL) {
    error_exit("No output file!");
  }

  if (is_directory(out_file_path)) {
    snprintf(msg_buf, MSG_BUF_MAX, "Path is a directory: `%s'", out_file_path);
    error_exit(msg_buf);
  }

  FILE *out_file = fopen(out_file_path, "w");
  if (out_file == NULL) {
    snprintf(msg_buf, MSG_BUF_MAX, "Failed to open file: `%s': %s", out_file_path, strerror(errno));
    error_exit(msg_buf);
  }

  format_fn fn = NULL;
  if (strcmp(out_format, "config.h") == 0) {
    fn = &format_define;
  } else if (strcmp(out_format, "makefile") == 0) {
    fn = &format_makefile;
  } else {
    fprintf(stderr, "Unknown output format: `%s'", out_format);
    print_usage(stderr, prog_name);
    return 1;
  }

  for (size_t i = 0; i < COUNT_OF(env_vars); i++) {
    char *var_value = getenv(env_vars[i]);
    if (var_value == NULL) var_value = "";
    print_var(out_file, fn, env_vars[i], var_value);
  }

  print_var(out_file, fn, "SHARED", enable_shared);
  print_var(out_file, fn, "STATIC", enable_static);

  print_var(out_file, fn, "CONFIGURED", 1);
 
  fclose(out_file);
  free(out_file_path);
  free(out_format);

  return 0;
}
