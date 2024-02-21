# -*- mode: makefile-gmake -*-

include makefiles/prologue.mk

-include $(SRCDIR)module.mk

CFLAGS         += -g

-include $(TEST_DIR)module.mk

.PHONY: mostlyclean
mostlyclean:
	rm -f $(DEPFILES)
	rm -f $(OBJS)

.PHONY: clean
clean: mostlyclean
	rm -rf $(OBJDIR)
	rm -rf $(TARGET_DIR)
	rm -f $(CONFIGURE_BIN)
ifeq ($(REAL_OS),Darwin)
	rm -f $(CONFIGURE_PLIST)
endif

.PHONY: distclean
distclean: clean unconfigure
	rm -rf $(BUILDDIR)

.PHONY: rebuild
rebuild: clean all

.PHONY: release
release: CFLAGS :=-O3 $(CFLAGS)
release: all $(if $(wildcard $(TEST_DIR)*),tests)

.PHONY: all
all: $(CONFIG_MK)
	echo "CC: $(CC)"
