#
#  Copyright (c) 2008-2011,
#  Reto Buerki, Adrian-Ken Rueegsegger
#  secunet SwissIT AG
#
#  This file is part of Alog.
#
#  Alog is free software; you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published
#  by the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.
#
#  Alog is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with Alog; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
#  MA  02110-1301  USA
#

PREFIX ?= $(HOME)/libraries
INSTALL = install
TARGET ?= "base"

MAJOR = 0
MINOR = 3
VERSION = $(MAJOR).$(MINOR)
ALOG = libalog-$(VERSION)
SO_LIBRARY = libalog.so.$(VERSION)
A_LIBRARY = libalog.a
LIBRARY_KIND = dynamic

SOURCEDIR = src
OBJECTDIR = obj/$(TARGET)
LIBDIR = lib/$(TARGET)
COVDIR = cov/$(TARGET)
PROFDIR = prof/$(TARGET)
ALI_FILES = lib/$(TARGET)/*.ali
GPR_FILE = gnat/alog.gpr

TMPDIR = /tmp
DISTDIR = $(TMPDIR)/$(ALOG)
TARBALL = $(ALOG).tar.bz2
PWD = `pwd`

NUM_CPUS := $(shell getconf _NPROCESSORS_ONLN)

GMAKE_OPTS = -p -R -j$(NUM_CPUS)

CFLAGS = -fPIC -W -Wall -Werror -O3

LIBGLUE_SOURCES = $(wildcard libglue/*.c)
LIBGLUE_OBJECTS = $(LIBGLUE_SOURCES:.c=.o)

all: build_lib

tests: build_tests
	@$(OBJECTDIR)/runner_$(TARGET)

build_lib: prepare
	@gnatmake $(GMAKE_OPTS) -Palog_$(TARGET) -XALOG_VERSION="$(VERSION)" -XLIBRARY_KIND="$(LIBRARY_KIND)"

build_tests: prepare obj/lib/libglue.a
	@gnatmake $(GMAKE_OPTS) -Palog_$(TARGET)_tests -XALOG_BUILD="tests"

build_all: build_lib build_tests

prepare: $(SOURCEDIR)/alog-version.ads $(LIBGLUE_OBJECTS)
	@mkdir -p $(OBJECTDIR)/lib
	@cp $(LIBGLUE_OBJECTS) $(OBJECTDIR)/lib
	@mkdir -p $(COVDIR) $(PROFDIR)

$(SOURCEDIR)/alog-version.ads:
	@echo "package Alog.Version is"                > $@
	@echo "   Version_Number : constant Float :=" >> $@
	@echo "      $(VERSION);"                     >> $@
	@echo "end Alog.Version;"                     >> $@

clean:
	@rm -f alog.specs
	@rm -f $(LIBGLUE_OBJECTS)
	@rm -rf $(OBJECTDIR)/lib/*
	@rm -rf $(OBJECTDIR)/*
	@rm -rf $(LIBDIR)/*
	@rm -rf $(COVDIR)/*
	@rm -rf $(PROFDIR)/*

distclean: clean
	@rm -rf obj
	@rm -rf lib
	@rm -rf cov
	@rm -rf prof
	@rm -f $(SOURCEDIR)/alog-version.ads

dist: distclean $(SOURCEDIR)/alog-version.ads
	@echo -n "Creating release tarball '$(ALOG)' ... "
	@mkdir -p $(DISTDIR)
	@cp -R * $(DISTDIR)
	@tar -C $(TMPDIR) -cjf $(TARBALL) $(ALOG)
	@rm -rf $(DISTDIR)
	@echo "DONE"

install: install_lib install_$(LIBRARY_KIND)

install_lib: build_lib
	@mkdir -p $(PREFIX)/include/alog
	@mkdir -p $(PREFIX)/lib/alog
	@mkdir -p $(PREFIX)/lib/gnat
	$(INSTALL) -m 644 $(SOURCEDIR)/* $(PREFIX)/include/alog
	$(INSTALL) -m 444 $(ALI_FILES) $(PREFIX)/lib/alog
	$(INSTALL) -m 644 $(GPR_FILE) $(PREFIX)/lib/gnat

install_static:
	$(INSTALL) -m 444 $(LIBDIR)/$(A_LIBRARY) $(PREFIX)/lib/alog

install_dynamic:
	$(INSTALL) -m 444 $(LIBDIR)/$(SO_LIBRARY) $(PREFIX)/lib/alog
	@cd $(PREFIX)/lib/alog && \
	ln -sf $(SO_LIBRARY) libalog.so && \
	ln -sf $(SO_LIBRARY) libalog.so.$(MAJOR)

install_tests:
	$(INSTALL) -v -d $(PREFIX)/tests
	$(INSTALL) -m 755 $(OBJECTDIR)/runner_$(TARGET) $(PREFIX)/tests/test_runner
	@cp -vr data $(PREFIX)/tests

cov: prepare
	@rm -f $(OBJECTDIR)/cov/*.gcda
	@gnatmake $(GMAKE_OPTS) -Palog_$(TARGET)_tests -XALOG_BUILD="coverage"
	@$(OBJECTDIR)/cov/runner_$(TARGET) || true
	@lcov -c -d $(OBJECTDIR)/cov/ -o $(OBJECTDIR)/cov/alog_tmp.info
	@lcov -e $(OBJECTDIR)/cov/alog_tmp.info "$(PWD)/src/*.adb" -o $(OBJECTDIR)/cov/alog.info
	@genhtml --no-branch-coverage $(OBJECTDIR)/cov/alog.info -o $(COVDIR)

prof: prepare
	@rm -f $(OBJECTDIR)/callgrind.*
	@gnatmake $(GMAKE_OPTS) -Palog_$(TARGET)_tests -XALOG_BUILD="profiling"
	@cd $(OBJECTDIR) && \
		valgrind -q --tool=callgrind ./profiler_$(TARGET)
	@cp $(OBJECTDIR)/callgrind.* $(PROFDIR)
	@callgrind_annotate $(PROFDIR)/callgrind.* > $(PROFDIR)/profiler_$(TARGET).txt

obj/lib/libglue.a: $(LIBGLUE_OBJECTS)
	@mkdir -p obj/lib
	$(AR) $(ARFLAGS) $@ $^

.PHONY: cov dist prof tests build_all install_tests
