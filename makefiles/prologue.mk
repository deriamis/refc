# -*- mode: makefile-gmake -*-
include makefiles/vars.mk

ifeq (0, $(words $(filter $(MAKECMDGOALS),$(CLEAN) configure)))
-include config.mk
endif

ifeq (0, $(words $(filter $(MAKECMDGOALS),$(CLEAN))))
ifndef CONFIGURED
include makefiles/platform.mk
else

E :=
$(info $(E))
$(info $(E)  Host OS: $(HOST_OS))
$(info $(E)Host Arch: $(HOST_ARCH))
$(info $(E))
ifneq (,$(filter $(COMPILER),GCC Clang MinGW))
$(info $(E)   Target: $(TARGET_MACHINE))
$(info $(E))
endif
$(info $(E) Compiler: $(COMPILER))
$(info $(E)       CC: $(CC))
$(info $(E)      CXX: $(CXX))
$(info $(E)       AR: $(AR))
$(info $(E)       AS: $(AS))
$(info $(E)   RANLIB: $(RANLIB))
ifeq ($(LINKER),Darwin)
$(info $(E) DSYMUTIL: $(DSYMUTIL))
else
$(info $(E)  OBJCOPY: $(OBJCOPY))
endif
$(info $(E)    STRIP: $(STRIP))
ifeq ($(COMPILER),MinGW)
$(info $(E)  DLLTOOL: $(DLLTOOL))
endif
$(info $(E))
$(info $(E)   Linker: $(LINKER))
$(info $(E)       LD: $(LD))
$(info $(E)   LDLIBS: $(LDLIBS))
$(info $(E)  LDFLAGS: $(LDFLAGS))
$(info $(E))

endif
endif

include makefiles/project.mk
include makefiles/configure.mk
include makefiles/rules.mk
