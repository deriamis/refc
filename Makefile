# -*- mode: makefile-gmake -*-

include makefiles/prologue.mk

-include $(SRCDIR)module.mk

CFLAGS         += -g

-include $(TEST_DIR)module.mk

DEPFILES       := $(SRCS:%.c=$(DEPDIR)%.d)

all::
	echo "CC: $(CC)"
