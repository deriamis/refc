# -*- mode: makefile-gmake -*-
export HOST_ARCH
export HOST_OS
export HOST_MACHINE
export TARGET_MACHINE
export SHARED
export STATIC
export DEBUG
export COMPILER
export LINKER
export CPP
export CC
export CXX
export LD
export CPPFLAGS
export CFLAGS
export CXXFLAGS
export LDFLAGS
export LDLIBS
export LIBS
export AR
export AS
export RANLIB
export OBJCOPY
export DSYMUTIL
export STRIP
export EXEEXT
export DLLEXT

CONFIGURE_SRCS   = $(SUPPORTDIR)configure.c
ifneq (,$(filter MinGW MSVC,$(COMPILER)))
CONFIGURE_SRCS  += $(SUPPORTDIR)windows/util.c
else
CONFIGURE_SRCS  += $(SUPPORTDIR)posix/util.c
endif

CONFIGURE_OBJS   = $(addprefix $(OBJDIR),$(CONFIGURE_SRCS:.c=.o))
CONFIGURE_LIBS   = c
CONFIGURE_BIN    = $(TOPDIR)configure$(EXEEXT)

SRCS            += $(CONFIGURE_SRCS)
OBJS            += $(CONFIGURE_OBJS)
CONFIGURE_BINS  += $(CONFIGURE_BIN)

$(CONFIGURE_OBJS): DISABLE_GNU_EXTENSIONS = 1
$(CONFIGURE_OBJS): STANDARD               = c11
$(CONFIGURE_OBJS): STRICT_STANDARD        = 1
ifneq ($(HOST_OS),Windows)
$(CONFIGURE_OBJS): CPPFLAGS              += -D_POSIX_SOURCE=1 -DPOSIX_C_SOURCE=200809L -D_XOPEN_SOURCE=700
endif
$(CONFIGURE_OBJS): INCLUDEDIRS            = $(SUPPORTDIR)
ifndef RELEASE
$(CONFIGURE_OBJS): CFLAGS                += -Og -g
else
$(CONFIGURE_OBJS): CFLAGS                += -O2 -g
endif

$(CONFIGURE_BIN): .EXTRA_PREREQS += $(LD)
$(CONFIGURE_BIN): LIBS = $(CONFIGURE_LIBS)
$(CONFIGURE_BIN): SUBSYSTEM = console
$(CONFIGURE_BIN): $(CONFIGURE_OBJS)

$(CONFIG_MK): $(CONFIGURE_BIN)
	$(CONFIGURE_BIN) -f makefile -o $(CONFIG_MK) $(CONFIGURE_OPTS)

$(CONFIG_H): $(CONFIGURE_BIN)
	$(CONFIGURE_BIN) -f config.h -o $(CONFIG_H) $(CONFIGURE_OPTS)
