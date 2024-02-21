# -*- mode: makefile-gmake -*-

PROJECT_NAME      = refc
VERSION           = 0.1
LIBS              =

ifneq (,$(filter MinGW,$(C_COMPILER) $(CXX_COMPILER)))
# For Windows apps
PROJECT_TYPE      := console  # may be "console" or ""windows" (or empty for a library)
endif

CONFIGURE_OPTS    := --std=c11 --strict --warnings-as-errors --posix=2008 --xopen=v4
PACKAGE_NAME      := $(PROJECT_NAME)-$(VERSION)

SRCS              := $(shell find $(SRCDIR) -type f -name '*.c')
DEPFILES          := $(SRCS:%.c=$(DEPDIR)%.d)
