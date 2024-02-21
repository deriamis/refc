# -*- mode: makefile-gmake -*-
.DEFAULT_GOAL  := all

$(V).SILENT:
$(VERBOSE).SILENT:

COMPILE.c   = $(CC) $(CFLAGS) $(EXTRA_CFLAGS) $(CPPFLAGS) $(EXTRA_CPPFLAGS) -c
COMPILE.cpp = $(CXX) $(CXXFLAGS) $(EXTRA_CXXFLAGS) $(CPPFLAGS) $(EXTRA_CPPFLAGS) -c
LINK.o      = $(LD) $(LDFLAGS) $(EXTRA_LDFLAGS) $(LOADLIBES) $(LDLIBS) $(LIBS) $(EXTRA_LIBS)

$(BUILDDIR):
	@mkdir -p "$(BUILDDIR)"

$(OBJDIR): | $(BUILDDIR)
	@mkdir -p "$(OBJDIR)"

$(DEPDIR): | $(OBJDIR)
	@mkdir -p "$(DEPDIR)"

ifdef CONFIGURED
$(OBJDIR)%.o: | $(CONFIG_H)
endif

$(OBJDIR)%.o: .EXTRA_PREREQS = $(CC) $(AS)

$(OBJDIR)%.o: %.c %.h | $(OBJDIR)
	@mkdir -p $(dir $@)
	@echo "[CC] $<"
	$(COMPILE.c) $(OUTPUT_OPTION) $<

$(OBJDIR)%.o : %.cpp %.hpp | $(OBJDIR)
	@mkdir -p $(dir $@)
	@echo "[CXX] $<"
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(DEPDIR)%.d: $(CC)
$(DEPDIR)%.d: %.c %.cpp | $(DEPDIR)
ifeq ($(COMPILER),GCC,MinGW,Clang)
	@$(MKDIR) $(dir $@)
	@echo "[DEPEND] $<"
	$(CC) $(CFLAGS) $(CPPFLAGS) -MT '$(patsubst $(SRCDIR)%.c,$(OBJDIR)%.o,$<)' $< -MMD -MP -MF $@
endif

ifeq (0, $(words $(findstring $(MAKECMDGOALS),$(CLEAN))))
-include $(DEPFILES)
endif

# $(SHARED_LIB):
# 	$(LD) $(LDFLAGS) -shared -soname $(SHARED_LIB) -o $@ $(OBJS)
