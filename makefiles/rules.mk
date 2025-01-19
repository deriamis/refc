# -*- mode: makefile-gmake -*-
.DEFAULT_GOAL  := all

ifeq ($(LINKER),MSVC)
DLL_FLAGS           = /DLL /NOENTRY
else ifeq ($(LINKER),Darwin)
DLL_LDFLAGS         = -dylib -install_name '@rpath/$(patsubst %$(DLLEXT),%,$(@F)).$(ABIVERSION)$(DLLEXT)' -current_version $(SOVERSION) -compatibility_version $(ABIVERSION)
SO_LDFLAGS          = -bundle
else ifeq ($(LINKER),MinGW)
DLL_LDFLAGS         = -s -shared
else
DLL_LDFLAGS         = -shared -soname '$@.$(ABIVERSION)'
endif

ifneq ($(LINKER),MSVC)
ifdef SHARED
EXE_LDFLAGS         = -pie -dynamic #-rpath
else
EXE_LDFLAGS         = -static
endif
endif

ifneq (,$(filter $(COMPILER),GCC Clang MinGW))
ifdef SHARED
CFLAGS             += -fPIC
CXXFLAGS           += -fPIC
endif
endif

ARFLAGS             = cr

ifdef SOURCE_DATE_PREFIX
ARFLAGS            += D
RANLIB             += -D
endif

ifeq ($(COMPILER),MSVC)
INCLUDE_OPT_PREFIX := /I
else
INCLUDE_OPT_PREFIX := -I
endif

ifeq ($(LINKER),MSVC)
LIB_OPT_PREFIX     := /l
LIBDIR_OPT_PREFIX  := /L
else
LIB_OPT_PREFIX     := -l
LIBDIR_OPT_PREFIX  := -L
endif

COMPILE.c           = $(CC) $(CFLAGS) $(EXTRA_CFLAGS) $(CPPFLAGS) $(addprefix $(INCLUDE_OPT_PREFIX),$(INCLUDEDIRS)) $(EXTRA_CPPFLAGS) -c
COMPILE.cpp         = $(CXX) $(CXXFLAGS) $(EXTRA_CXXFLAGS) $(CPPFLAGS) $(addprefix $(INCLUDE_OPT_PREFIX),$(INCLUDEDIRS)) $(EXTRA_CPPFLAGS) -c

LINK$(EXEEXT)       = $(LD) $(PLATFORM_LDFLAGS) $(LDFLAGS) $(EXE_LDDLAGS) $(addprefix $(LIBDIR_OPT_PREFIX),$(LIBDIRS)) $(EXTRA_LDFLAGS) $(LOADLIBES) $(LDLIBS) $(EXTRA_LIBS) $(addprefix $(LIB_OPT_PREFIX),$(LIBS))
LINK$(DLLEXT)       = $(LD) $(DLL_LDFLAGS) $(PLATFORM_LDFLAGS) $(LDFLAGS) $(addprefix $(LIBDIR_OPT_PREFIX),$(LIBDIRS)) $(EXTRA_LDFLAGS) $(EXTRA_LIBS) $(addprefix $(LIB_OPT_PREFIX),$(LIBS))
ifeq ($(LINKER),Darwin)
LINK$(SOEXT)        = $(LD) $(SO_LDFLAGS) $(PLATFORM_LDFLAGS) $(LDFLAGS) $(addprefix $(LIBDIR_OPT_PREFIX),$(LIBDIRS)) $(EXTRA_LDFLAGS) $(EXTRA_LIBS) $(addprefix $(LIB_OPT_PREFIX),$(LIBS))
endif

LINK.o              = $(LINK$(EXEEXT))

$(VERBOSE).SILENT:

$(BUILDDIR):
	@mkdir -p "$(BUILDDIR)"

$(OBJDIR):
	@mkdir -p "$(OBJDIR)"

$(DEPDIR):
	@mkdir -p "$(DEPDIR)"

$(TARGET_LIBDIR):
	@mkdir -p "$(TARGET_LIBDIR)"

$(TARGET_BINDIR):
	@mkdir -p "$(TARGET_BINDIR)"

$(TARGET_SBINDIR):
	@mkdir -p "$(TARGET_SBINDIR)"

$(TARGET_LIBEXECDIR):
	@mkdir -p "$(TARGET_LIBEXECDIR)"

ifdef CONFIGURED
%.o: | $(CONFIG_H)
endif

$(DEBUG_PLIST):
	/usr/libexec/PlistBuddy -c "Add :com.apple.security.get-task-allow bool true" $(DEBUG_PLIST)

ifdef DEBUG
ifeq ($(HOST_OS),Darwin)
$(CONFIGURE_BINS): .EXTRA_PREREQS += $(DEBUG_PLIST)
$(PROGRAMS):       .EXTRA_PREREQS += $(DEBUG_PLIST)
endif
endif

$(OBJDIR)%.o: .EXTRA_PREREQS = $(CC) $(AS)

$(OBJDIR)%.o: %.c | $(OBJDIR)
	@mkdir -p "$(dir $@)"
	@echo "[CC] $<"
	$(COMPILE.c) $< $(OUTPUT_OPTION)

$(OBJDIR)%.o: %.cpp | $(OBJDIR)
	@mkdir -p "$(dir $@)"
	@echo "[CXX] $<"
	$(COMPILE.cpp) $< $(OUTPUT_OPTION)

$(DEPDIR)%.d: $(CC)
$(DEPDIR)%.d: %.c %.cpp | $(DEPDIR)
ifeq ($(COMPILER),GCC,MinGW,Clang)
	@mkdir -p "$(dir $@)"
	@echo "[DEPEND] $<"
	$(CC) $(CFLAGS) $(CPPFLAGS) -MT '$(patsubst $(SRCDIR)%.c,$(OBJDIR)%.o,$<)' $< -MMD -MP -MF $@
endif

ifeq (0, $(words $(findstring $(MAKECMDGOALS),$(CLEAN))))
-include $(DEPFILES)
endif

$(TOPDIR)%$(EXEEXT): $(OBJS) |
	@mkdir -p "$(dir $@)"
	@echo "[LINK$(EXEEXT)] $@"
	$(LINK$(EXEEXT)) $^ $(OUTPUT_OPTION)
ifeq ($(HOST_OS),Darwin)
ifdef DEBUG
		@echo "[SIGN] $@"
		codesign -s - --entitlements $(DEBUG_PLIST) -f $@
endif
endif

ifeq ($(LINKER),MSVC)
format_libname = $(patsubst %$(DLLEXT),%,$1)-$(ABIVERSION).lib
$(TARGET_LIBDIR)%.lib: $(TARGET_LIBDIR)%$(DLLEXT) | $(TARGET_LIBDIR)
	@mkdir -p "$(dir $@)"
	@echo "[EXPORTS] $@"
	"$(IMPLIB)" "$(call format_libname,$@).lib" "$<"
else ifeq ($(LINKER),MinGW)
format_libname = $(patsubst %$(DLLEXT),%,$1)-$(ABIVERSION).lib
$(TARGET_LIBDIR)%.lib: OUTPUT_OPTION = --output-lib $(call format_libname,$@).lib
$(TARGET_LIBDIR)%.lib: $(TARGET_LIBDIR)%$(DLLEXT) | $(TARGET_LIBDIR)
	@mkdir -p "$(dir $@)"
	@echo "[EXPORTS] $@"
	$(DLLTOOL) --dllname $< $(OUTPUT_OPTION)
else ifeq ($(LINKER),Darwin)
format_libname = $(patsubst %$(DLLEXT),%,$1).$(SOVERSION)$(DLLEXT)
$(TARGET_LIBDIR)%.lib: $(TARGET_LIBDIR)%$(DLLEXT)
else
format_libname = $(patsubst %$(DLLEXT),%,$1)$(DLLEXT)
$(TARGET_LIBDIR)%.lib:
endif

ifeq ($(LINKER),MSVC)
$(TARGET_LIBDIR)%$(DLLEXT): OUTPUT_OPTION = /O:$(call format_libname,$@)$(DLLEXT)
else
$(TARGET_LIBDIR)%$(DLLEXT): OUTPUT_OPTION = -o $(call format_libname,$@)
endif
$(TARGET_LIBDIR)%$(DLLEXT): %.o | $(TARGET_LIBDIR)
	@mkdir -p "$(dir $@)"
	@echo "[LINK$(DLLEXT)] $@"
	$(LINK$(DLLEXT)) $^ $(OUTPUT_OPTION)

$(TARGET_LIBDIR)%.a(%.o): %.o | $(TARGET_LIBDIR)
	@mkdir -p "$(dir $@)"
	@echo "[LIB] $@"
	$(AR) $(ARFLAGS) $@ $^
	@echo "[RANLIB] $@"
	$(RANLIB) $(RANLIBFLAGS) $@

.PHONY: unconfigure
unconfigure::
	$(eval CONFIGURED :=)
	rm -f $(CONFIG_CACHE)
	rm -f $(CONFIG_MK)
	rm -f $(CONFIG_H)

.PHONY: configure
configure: $(CONFIGURE_BINS)

.PHONY: reconfigure
reconfigure:: unconfigure configure

.PHONY: mostlyclean
mostlyclean::
	rm -f $(DEPFILES)
	rm -f $(OBJS)
	rm -f $(PROGRAMS)

.PHONY: clean
clean:: mostlyclean
	rm -rf $(OBJDIR)
	rm -rf $(TARGET_DIR)
	rm -f $(CONFIGURE_BINS)
ifeq ($(REAL_OS),Darwin)
	rm -f $(CONFIGURE_PLIST)
endif

.PHONY: distclean
distclean:: unconfigure clean
	rm -rf $(BUILDDIR)

.PHONY: rebuild
rebuild:: clean all

.PHONY: release
release:: CFLAGS :=-O3 $(CFLAGS)
release:: all $(if $(wildcard $(TEST_DIR)*),tests)

.PHONY: all
all:: configure $(LIBRARIES)

# For install, we need to make sure the DLLs are installed properly.
# Sarwin should be: libname.$(SOVERSION).dylib -> libname.$(ABI_VERSION).dylib
# Other *NIX should be: libname.so.$(SOVERSION) -> libname.$(ABI_VERSION).dylib
# Windows should be: libname-$(ABI_VERSION).dll and libname-$(ABI_VERSION).lib
.PHONY: install
install::
