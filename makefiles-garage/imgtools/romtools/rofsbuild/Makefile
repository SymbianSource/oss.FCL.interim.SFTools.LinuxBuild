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
# This is a Linux makefile for rofsbuild. 

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
-I ../../imglib/memmap/include \
-I ../../imglib/filesystem/include

lib_opts = -lboost_thread-mt \
-L../../imglib/memmap -lmemmap \
-L../../imglib/patchdataprocessor -lpatchdataprocessor \
-L../../imglib/parameterfileprocessor -lparameterfileprocessor \
-L../../imglib/filesystem -lfilesystem

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags)
LDFLAGS = $(lib_opts) $(global_ld_flags)

prereqs = memmap patchdataprocessor parameterfileprocessor filesystem

srcs = \
r_obey.cpp \
r_build.cpp \
r_rofs.cpp \
r_driveimage.cpp \
r_driveutl.cpp \
rofsbuild.cpp \
r_coreimage.cpp \
r_smrimage.cpp \
../../imglib/host/h_utl.cpp \
../../imglib/host/h_file.cpp \
../../imglib/host/h_mem.cpp \
../../imglib/e32uid/e32uid.cpp \
../../imglib/e32image/e32image.cpp \
../../imglib/e32image/deflate/decode.cpp \
../../imglib/e32image/deflate/encode.cpp \
../../imglib/e32image/deflate/deflate.cpp \
../../imglib/e32image/deflate/inflate.cpp \
../../imglib/e32image/deflate/panic.cpp \
../../imglib/e32image/deflate/compress.cpp \
../../imglib/compress/byte_pair.cpp \
../../imglib/compress/pagedcompress.cpp

exe = rofsbuild

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

