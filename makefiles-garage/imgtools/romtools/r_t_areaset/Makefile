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
# This is a Linux makefile for r_t_areaset. 

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

cpp_inc_paths = \
-I ../../imglib/inc \
-I ../../imglib/compress \
-I ../../imglib/patchdataprocessor/include \
-I ../../imglib/memmap/include

lib_opts = -lboost_thread-mt \
-L../../imglib/memmap -lmemmap \
-L../../imglib/patchdataprocessor -lpatchdataprocessor

prereqs = memmap patchdataprocessor

exe = r_t_areaset

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags)
LDFLAGS = $(lib_opts) $(global_ld_flags)

srcs = \
../rombuild/r_t_areaset.cpp \
../rombuild/r_areaset.cpp \
../rombuild/r_dir.cpp \
../rombuild/r_header.cpp \
../rombuild/r_obey.cpp \
../rombuild/r_srec.cpp \
../rombuild/r_rom.cpp \
../rombuild/r_global.cpp \
../rombuild/r_build.cpp \
../rombuild/r_collapse.cpp \
../../imglib/e32uid/e32uid.cpp \
../../imglib/host/h_file.cpp \
../../imglib/host/h_mem.cpp \
../../imglib/host/h_utl.cpp \
../../imglib/e32image/e32image.cpp \
../../imglib/e32image/deflate/decode.cpp \
../../imglib/e32image/deflate/encode.cpp \
../../imglib/e32image/deflate/deflate.cpp \
../../imglib/e32image/deflate/inflate.cpp \
../../imglib/e32image/deflate/panic.cpp \
../../imglib/e32image/deflate/compress.cpp \
../../imglib/compress/byte_pair.cpp \
../../imglib/compress/pagedcompress.cpp

.PHONY: all clean $(prereqs)

all: $(exe)

bases = $(basename $(srcs))

objs = $(addsuffix .o,$(bases))

$(exe): $(objs) $(prereqs)
	$(CC) -o $@ $(objs) $(LDFLAGS)

$(prereqs): $(global_prereqs)
	$(MAKE) -C $(EPOCROOT)/build $@

clean:
	rm -f $(objs) $(exe)

