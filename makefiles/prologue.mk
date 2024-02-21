# -*- mode: makefile-gmake -*-
include makefiles/vars.mk

ifeq (0, $(words $(findstring $(MAKECMDGOALS),$(CLEAN) unconfigure reconfigure)))
include config.mk
endif

ifeq (0, $(words $(findstring $(MAKECMDGOALS),$(CLEAN) unconfigure)))
ifndef CONFIGURED
include makefiles/platform.mk
endif
endif

include makefiles/project.mk
include makefiles/rules.mk
include makefiles/configure.mk

ifdef CONFIGURED
include makefiles/flags.mk
endif
