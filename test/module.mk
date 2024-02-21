CUR_LIST_DIR     := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

-include $(EXT_SRCDIR)/unity.mk
LIST_DIR     := $(CUR_LIST_DIR)

TEST_SRCS    := test_decode.c test_encode.c test_properties.c

TEST_SRCS    := $(addprefix $(LIST_DIR)/,$(TEST_SRCS))
TEST_OBJS    := $(addprefix $(OBJDIR)/,$(TEST_SRCS:.c=.o))
TEST_OBJDIR  := $(addprefix $(OBJDIR)/,$(LIST_DIR))
TEST_BINS    := $(addprefix $(OBJDIR)/,$(TEST_SRCS:.c=$(EXEEXT)))

TEST_DEPS    := $(addprefix $(LIST_DIR)/,util.c)
TESTDEP_OBJS := $(addprefix $(OBJDIR)/,$(TEST_DEPS:.c=.o))

$(TEST_OBJDIR): | $(OBJDIR)
	@mkdir $(TEST_OBJDIR)

$(TEST_OBJDIR)/util.o: $(TESTDIR)/util.c | $(TEST_OBJDIR)
	$(COMPILE.c) -fPIC $(OUTPUT_OPTION) $^

$(TEST_OBJDIR)/%.o: CPPFLAGS += -I$(UNITY_DIR)
$(TEST_OBJDIR)/%.o: $(TESTDIR)/%.c | $(TEST_OBJDIR)
	$(COMPILE.c) -fPIC $(OUTPUT_OPTION) $^

$(TEST_BINS): LINKFLAGS += -L. -l$(NAME)
$(TEST_BINS): $(TESTDEP_OBJS) $(UNITY_OBJS) | $(TEST_OBJDIR)

$(TEST_OBJDIR)/test_decode$(EXEEXT): $(TEST_OBJDIR)/test_decode.o
	$(CC) $(CFLAGS) $(LINKFLAGS) -pie -rdynamic -o $@ $< \
		$(TESTDEP_OBJS) $(UNITY_OBJS)

$(TEST_OBJDIR)/test_encode$(EXEEXT): $(TEST_OBJDIR)/test_encode.o
	$(CC) $(CFLAGS) $(LINKFLAGS) -pie -rdynamic -o $@ $< \
		$(TESTDEP_OBJS) $(UNITY_OBJS)

$(TEST_OBJDIR)/test_properties$(EXEEXT): $(TEST_OBJDIR)/test_properties.o
	$(CC) $(CFLAGS) $(LINKFLAGS) -pie -rdynamic -o $@ $< \
		$(TESTDEP_OBJS) $(UNITY_OBJS)

tests: DEPS := $(TEST_OBJS:.o=.d) $(TESTDEP_OBJS:.o=.d) $(UNITY_OBJS:.o=.d)
tests: all $(TEST_BINS)

retest: distclean tests

recheck: distclean check

debug: CFLAGS += -O1 -g -g3 -ggdb
debug: LDFLAGS += -g
debug: recheck

.PHONY: debug tests retest check recheck
