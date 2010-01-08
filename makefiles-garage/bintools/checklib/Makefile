# Copyright (c) 2009 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Symbian Foundation Ltd - initial contribution.
# Mike Kinghan, mikek@symbian.org
#
# Contributors:
#
# Description:
# This is a Linux makefile for checklib.

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

cpp_inc_paths = -I . -I object/coff -I ..

lib_opts =

exe = checklib

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags)
LDFLAGS = $(lib_opts) $(global_ld_flags)

prereqs =

srcs = main.cpp \
library/library.cpp \
misc/endian.cpp \
object/object.cpp \
object/elf_object.cpp \
object/coff_object.cpp \
object/elf/elf_file_header.cpp \
object/elf/elf_section_header.cpp \
object/elf/elf_symbol.cpp \
object/elf/elf_string_table.cpp \
object/coff/coff_file_header.cpp \
object/coff/coff_symbol.cpp \
object/coff/coff_string_table.cpp


.PHONY: all clean $(prereqs)

all: $(exe)

bases = $(basename $(srcs))

objs = $(addsuffix .o,$(bases))

$(prereqs): $(global_prereqs)
	$(MAKE) -C $(EPOCROOT)/build $@

$(objs): $(prereqs)
 
$(exe): $(objs)
	$(CC) -o $@ $(objs) $(LDFLAGS)

clean:
	rm -f $(objs) $(exe)

