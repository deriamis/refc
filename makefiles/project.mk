# -*- mode: makefile-gmake -*-
PROJECT_NAME         = refc
VERSION              = 0.1
LIBS                 = c
PROGRAMS             =

STANDARD            := c11
CONFIGURE_OPTS      :=
PACKAGE_NAME        := $(PROJECT_NAME)-$(VERSION)

CFLAGS            += -Wall                     \
                     -Wextra                   \
                     -Wcast-align              \
                     -Wunused                  \
                     -Wno-unused-function      \
                     -Wpedantic                \
                     -Wconversion              \
                     -Wsign-conversion         \
                     -Wnull-dereference        \
                     -Wdouble-promotion        \
                     -Wformat=2
ifeq (,$(NO_WARNINGS_AS_ERRORS))
CFLAGS            += -Werror
endif
CFLAGS            += -fvisibility=hidden       \
                     -fstack-protector-strong  \
                     -ffunction-sections       \
                     -fdata-sections           \
                     -fstrict-aliasing
ifdef DISABLE_GNU_EXTENSIONS
ifneq (Darwin Clang /usr/bin,$(HOST_OS) $(COMPILER) $(dir $(CC)))
CFLAGS            += -fgnuc-version=0
endif
endif

CPPFLAGS          += -std=$(STANDARD)
ifdef STRICT_STANDARD
CPPFLAGS          += -pedantic                 \
                     -pedantic-errors
endif
ifneq ($(LINKER),MinGW)
CPPFLAGS          += -D_POSIX_SOURCE=1         \
                     -D_POSIX_C_SOURCE=200809L \
                     -D_XOPEN_SOURCE=700
endif
CPPFLAGS          += -D_FORTIFY_SOURCE=2
ifeq ($(ARCH_BITS),64)
CPPFLAGS          += -D_FILE_OFFSET_BITS=$(ARCH_BITS)
ifneq ($(LINKER),MinGW)
CPPFLAGS          += -D_LARGEFILE_SOURCE=1
endif
endif

LDFLAGS           := $(PLATFORM_LDFLAGS) $(LDFLAGS)
ifeq ($(LINKER),Darwin)
LDFLAGS           += -unaligned_pointers warning  \
                     -warn_weak_exports
ifeq (,$(NO_WARNINGS_AS_ERRORS))
LDFLAGS           += -fatal_warnings
endif
ifdef SOURCE_DATE_EPOCH
LDFLAGS           += -reproducible
ifdef DEBUG
LDFLAGS           += -O0
endif
endif
else
LDFLAGS           += --no-as-needed
ifeq (,$(NO_WARNINGS_AS_ERRORS))
LDFLAGS           += --fatal-warnings
endif
LDFLAGS           += --gdb-index               \
                     --build-id                \
                     --hash-style=gnu          \
                     --gc-sections             \
                     --enable-new-dtags        \
                     --warn-execstack          \
                     -z noexecstack            \
                     -z relro                  \
                     -x now                    \
                     -z origin                 \
                     -z defs
ifdef SOURCE_DATE_EPOCH
LDFLAGS           += --no-insert-timestamp
endif
ifeq ($(LINKER),MinGW)
ifdef SUBSYSTEM
LDFLAGS           += --subsystem=$(SUBSYSTEM)
endif
endif
endif
