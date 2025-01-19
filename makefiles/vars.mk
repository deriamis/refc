.SUFFIXES         += .d
TOPDIR            := $(dir $(CURDIR)/$(firstword $(MAKEFILE_LIST)))
CLEAN             := clean distclean mostlyclean reconfigure unconfigure
DATE_FMT          := +%Y-%m-%d


SRCDIR            := src/
SRCINCLUDEDIR     := include/
TESTDIR           := test/
SUPPORTDIR        := support/

BUILDDIR          := build/
OBJDIR            := $(BUILDDIR)obj/
DEPDIR            := $(OBJDIR).deps/

CONFIG_CACHE      := buildconf.cache
CONFIG_MK         := config.mk
CONFIG_H          := $(SRCDIR)config.h
CONFIG_FILES      := $(CONFIG_MK) $(CONFIG_H)

DEBUG_PLIST       := $(BUILDDIR)debug.entitlements

TARGET_DIR        := $(BUILDDIR)target/
TARGET_EPREFIX    := $(TARGET_DIR)
TARGET_BINDIR     := $(TARGET_EPREFIX)bin/
TARGET_SBINDIR    := $(TARGET_EPREFIX)sbin/
TARGET_LIBEXECDIR := $(TARGET_EPREFIX)libexec/
TARGET_DATADIR    := $(TARGET_DIR)share/
TARGET_SYSCONFDIR := $(TARGET_DIR)etc/
TARGET_INCLUDEDIR := $(TARGET_DIR)include/
TARGET_DOCDIR     := $(TARGET_DATADIR)doc/$(PACKAGE_NAME)/
TARGET_INFODIR    := $(TARGET_DATADIR)info/
TARGET_LIBDIR     := $(TARGET_DIR)lib/
TARGET_LISPDIR    := $(TARGET_DATADIR)emacs/site-lisp/
TARGET_LOCALEDIR  := $(TARGET_DATADIR)locale/
TARGET_MANDIR     := $(TARGET_DATADIR)man/
TARGET_MAN1DIR    := $(TARGET_MANDIR)man1/
TARGET_MAN2DIR    := $(TARGET_MANDIR)man2/
TARGET_MAN3DIR    := $(TARGET_MANDIR)man3/
TARGET_MAN4DIR    := $(TARGET_MANDIR)man4/
TARGET_MAN5DIR    := $(TARGET_MANDIR)man5/
TARGET_MAN6DIR    := $(TARGET_MANDIR)man6/
TARGET_MAN7DIR    := $(TARGET_MANDIR)man7/
TARGET_MAN8DIR    := $(TARGET_MANDIR)man8/
TARGET_MAN9DIR    := $(TARGET_MANDIR)man9/
