# -*- mode: makefile-gmake -*-

USER_CPPFLAGS     := $(CPPFLAGS)
USER_CFLAGS       := $(CFLAGS)
USER_LINKFLAGS    := $(LINKFLAGS)
USER_LDFLAGS      := $(LDFLAGS)

ifneq ($(COMPILER),MSVC)
    INCFLAGS          := $(if $(SRCINCLUDEDIR),$(if $(wildcard $(SRCINCLUDEDIR)/*),-I$(SRCINCLUDEDIR)))
    LIBFLAGS          := $(if $(SYSLIBS), $(addprefix -l,$(SYSLIBS)),)
    LIBFLAGS          := $(if $(LIBS), $(addprefix -l,$(LIBS)),)

    EXTRA_LIBFLAGS    := $(if $(EXTRA_LIBDIRS),$(addprefix -L,$(EXTRA_LIBDIRS)),)
    EXTRA_LIBFLAGS    += $(if $(EXTRA_LIBS), $(addprefix -l,$(EXTRA_LIBS)),)

    CPPFLAGS          := -std=c11                               \
                         -pedantic                              \
                         -pedantic-errors                       \
                         -fgnuc-version=0                       \
                         -D_POSIX_SOURCE=1                      \
                         -D_POSIX_C_SOURCE=200809L              \
                         -D_XOPEN_SOURCE=700                    \
                         -D_FORTIFY_SOURCE=2
    CPPFLAGS          += -D_FILE_OFFSET_BITS=$(ARCH_BITS)
    CPPFLAGS          += $(INCFLAGS)
    CPPFLAGS          += $(USER_CPPFLAGS)

    CFLAGS            += -Wall                                  \
                         -Wextra                                \
                         -Wcast-align                           \
                         -Wunused                               \
                         -Wno-unused-function                   \
                         -Wpedantic                             \
                         -Wconversion                           \
                         -Wsign-conversion                      \
                         -Wnull-dereference                     \
                         -Wdouble-promotion                     \
                         -Wformat=2                             \
                         -Werror                                \
                         -fvisibility=hidden                    \
                         -fstack-protector-strong               \
                         -ffunction-sections                    \
                         -fdata-sections                        \
                         -fstrict-aliasing
    CFLAGS            += $(USER_CFLAGS)

    LINKFLAGS         := -fuse-ld=$(subst ld.,,$(notdir $(LD))) \
                         -Wl,--no-as-needed                     \
                         -Wl,--fatal-warnings                   \
                         -Wl,--gdb-index                        \
                         -Wl,--build-id                         \
                         -Wl,--hash-style=gnu                   \
                         -Wl,--gc-sections                      \
                         -Wl,-z,noexecstack                     \
                         -Wl,--warn-execstack                   \
                         -Wl,-z,relro                           \
                         -Wl,-z,origin                          \
                         -Wl,--enable-new-dtags                 \
                         -Wl,-z,defs                            \
                         $(EXTRA_LIBFLAGS)
    LINKFLAGS         += $(USER_LINKFLAGS)

    LDFLAGS           := --no-as-needed                         \
                         --fatal-warnings                       \
                         --gdb-index                            \
                         --build-id                             \
                         --hash-style=gnu                       \
                         --gc-sections                          \
                         -z noexecstack                         \
                         --warn-execstack                       \
                         -z relro                               \
                         -z origin                              \
                         --enable-new-dtags                     \
                         -z defs                                \
                         $(LIBFLAGS)                            \
                         $(EXTRA_LIBFLAGS)
    LDFLAGS           += $(USER_LDFLAGS)

    ifdef $(SHARED)
        LINK.o        := $(LD) -pie -rdynamic $(LDFLAGS) $(TARGET_ARCH)
    else
        LINK.o        := $(LD) -static $(LDFLAGS) $(TARGET_ARCH)
    endif
endif
