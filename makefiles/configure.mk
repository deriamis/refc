# -*- mode: makefile-gmake -*-

## User configurables
LEAK_CHECK     ?=
SHARED         ?=
STATIC         ?=
STRICT         ?=
PREFIX         ?=

export HOST_ARCH
export HOST_OS
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
export STRIP
export EXEEXT
export DLLEXT

CONFIGURE_SRCS  := $(UTILSDIR)util.c $(UTILSDIR)configure/configure.c
ifneq (,$(filter MinGW MSVC,$(C_COMPILER)))
CONFIGURE_SRCS  += $(UTILSDIR)windows/util.c
else
CONFIGURE_SRCS  += $(UTILSDIR)posix/util.c
endif

CONFIGURE_OBJS  := $(addprefix $(OBJDIR),$(CONFIGURE_SRCS:.c=.o))
CONFIGURE_LIBS  := -lc
CONFIGURE_BIN   := configure$(EXEEXT)

ifeq ($(REAL_OS),Darwin)
CONFIGURE_PLIST := $(BUILDDIR)configure.entitlements
endif

OBJS            += $(CONFIGURE_OBJS)
BINS            += $(CONFIGURE_BIN)

CONFIG_MK       := config.mk
CONFIG_H        := $(SRCDIR)config.h

CONFIGURED      :=

$(CONFIGURE_OBJS): EXTRA_CPPFLAGS += -D_POSIX_SOURCE=1 -DPOSIX_C_SOURCE=200809L -D_XOPEN_SOURCE=700
$(CONFIGURE_OBJS): EXTRA_CFLAGS   += -I$(UTILSDIR) -O0 -g

$(CONFIGURE_PLIST):
ifeq ($(REAL_OS),Darwin)
	/usr/libexec/PlistBuddy -c "Add :com.apple.security.get-task-allow bool true" $(CONFIGURE_PLIST)
endif

$(CONFIGURE_BIN): .EXTRA_PREREQS = $(CONFIGURE_PLIST) $(LD)
$(CONFIGURE_BIN): EXTRA_LIBS = $(CONFIGURE_LIBS)
$(CONFIGURE_BIN): $(CONFIGURE_OBJS)
	@echo "[LINK] $@"
	$(LINK.o) $^ $(OUTPUT_OPTION)
ifeq ($(REAL_OS),Darwin)
	codesign -s - --entitlements $(CONFIGURE_PLIST) -f $@
endif

$(CONFIG_MK): $(CONFIGURE_BIN)
	$(CONFIGURE_BIN) -f makefile -o $(CONFIG_MK)

.PHONY: unconfigure
unconfigure:
	rm -f $(CONFIG_MK)
	rm -f $(CONFIG_H)

.PHONY: reconfigure
reconfigure: unconfigure
	$(CONFIGURE_BIN) -f makefile -o $(CONFIG_MK)
	$(CONFIGURE_BIN) -f config.h -o $(CONFIG_H)
