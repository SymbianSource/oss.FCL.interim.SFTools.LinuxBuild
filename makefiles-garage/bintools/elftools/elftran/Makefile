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
# This is a Linux makefile for elftran. 

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

cpp_inc_paths = \
-I ../inc \
-I ../../../e32tools/e32lib/e32image/inc \
-I ../../../imgtools/imglib/compress \
-I $(EPOCROOT)/epoc32/include/tools

lib_opts =

exe = elftran

CPPFLAGS = -D__SUPPORT_ELF_FILES__ $(cpp_inc_paths) $(global_cpp_flags)
LDFLAGS = $(lib_opts) $(global_ld_flags)

prereqs =

srcs = elf_file.cpp elf_dlld.cpp elf_imp.cpp elf_reloc.cpp elf_tran.cpp \
../../../imgtools/imglib/e32uid/e32uid.cpp \
../../../imgtools/imglib/host/h_file.cpp \
../../../imgtools/imglib/host/h_mem.cpp \
../../../imgtools/imglib/host/h_utl.cpp \
../../../e32tools/e32lib/e32image/e32image.cpp \
../../../e32tools/e32lib/e32image/tr_main.cpp \
../../../e32tools/e32lib/e32image/imgdump.cpp \
../../../e32tools/e32lib/e32image/deflate/decode.cpp \
../../../e32tools/e32lib/e32image/deflate/encode.cpp \
../../../e32tools/e32lib/e32image/deflate/deflate.cpp \
../../../e32tools/e32lib/e32image/deflate/inflate.cpp \
../../../e32tools/e32lib/e32image/deflate/panic.cpp \
../../../e32tools/e32lib/e32image/deflate/compress.cpp \
../../../imgtools/imglib/compress/byte_pair.cpp \
../../../imgtools/imglib/compress/pagedcompress.cpp

fixfiles = ../inc/e32ldfmt.h
fixbackups = $(addsuffix .original,$(fixfiles)) 
 
.PHONY: all clean $(prereqs)

all: $(exe)

$(srcs): fixes

bases = $(basename $(srcs))

objs = $(addsuffix .o,$(bases))

$(prereqs): $(global_prereqs)
	$(MAKE) -C $(EPOCROOT)/build $@

$(objs): $(prereqs)
 
$(exe): $(objs)
	$(CC) -o $@ $(objs) $(LDFLAGS)

clean: remove_fixes
	rm -f $(objs) $(exe)

fixes:: $(fixbackups)

remove_fixes: 
	for file in $(fixbackups); do if [ -f $$file ]; then mv -f $$file $${file%\.original}; fi; done

../inc/e32ldfmt.h.original:
	cp $(basename $@) $@ && \
	sed -e 's|fstream.h|fstream|g' -i $(basename $@)

