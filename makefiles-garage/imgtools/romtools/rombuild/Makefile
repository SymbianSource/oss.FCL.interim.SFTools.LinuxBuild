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
# This is a Linux makefile for rombuild. 


ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

cpp_inc_paths = \
-I ../../imglib/compress \
-I ../../imglib/inc \
-I ../../imglib/patchdataprocessor/include \
-I ../../imglib/parameterfileprocessor/include \
-I ../../imglib/memmap/include

lib_opts = -lboost_thread-mt \
-L../../imglib/memmap -lmemmap \
-L../../imglib/patchdataprocessor -lpatchdataprocessor \
-L../../imglib/parameterfileprocessor -lparameterfileprocessor \

exe = rombuild

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags)
LDFLAGS = $(lib_opts) $(global_ld_flags)

prereqs = memmap patchdataprocessor parameterfileprocessor

srcs = r_dir.cpp r_header.cpp r_obey.cpp r_srec.cpp r_rom.cpp rombuild.cpp r_build.cpp r_collapse.cpp r_global.cpp r_areaset.cpp \
r_coreimage.cpp r_coreimagereader.cpp \
../../imglib/e32uid/e32uid.cpp \
../../imglib/host/h_file.cpp ../../imglib/host/h_mem.cpp ../../imglib/host/h_utl.cpp \
../../imglib/e32image/e32image.cpp \
../../imglib/e32image/deflate/decode.cpp ../../imglib/e32image/deflate/encode.cpp ../../imglib/e32image/deflate/deflate.cpp \
../../imglib/e32image/deflate/inflate.cpp ../../imglib/e32image/deflate/panic.cpp \
../../imglib/e32image/deflate/compress.cpp \
../../imglib/compress/byte_pair.cpp \
../../imglib/compress/pagedcompress.cpp

.PHONY: all clean $(prereqs)

all: $(exe)

bases = $(basename $(srcs))

objs = $(addsuffix .o,$(bases))

$(prereqs): $(global_prereqs)
	$(MAKE) -C $(EPOCROOT)/build $@
 
$(exe): $(objs) $(prereqs)
	$(CC) -o $@ $(objs) $(LDFLAGS)

clean:
	rm -f $(objs) $(exe)

