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
# This is a Linux makefile for the imgutils library. 

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

fixfiles = inc/typedefs.h
fixbackups = $(addsuffix .original,$(fixfiles)) 

cpp_inc_paths = \
-I ../inc \
-I ../libimgutils/inc \
-I ../../imglib/inc \
-I ../../romtools/rofsbuild \
-I ../../imglib/compress \
-I ../../imglib/e32image \
-I ../../imglib/e32image/deflate \
-I ../../imglib/inc \
-I ../../imglib/e32uid \
-I ../../romtools/rofsbuild \
-I ../../imglib/patchdataprocessor/include

lib = libimgutils.a

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags)
CXXFLAGS = $(global_cxx_flags) -pthread 

srcs = \
../../imglib/compress/byte_pair.cpp \
../../imglib/compress/pagedcompress.cpp \
../../imglib/e32image/e32image.cpp \
../../imglib/e32image/deflate/inflate.cpp \
../../imglib/e32image/deflate/compress.cpp \
../../imglib/e32image/deflate/decode.cpp \
../../imglib/e32image/deflate/deflate.cpp \
../../imglib/e32image/deflate/panic.cpp \
../../imglib/e32image/deflate/encode.cpp \
../../imglib/host/h_file.cpp \
../../imglib/host/h_mem.cpp \
../../imglib/host/h_utl.cpp \
../../imglib/e32uid/e32uid.cpp \
../../romtools/rofsbuild/r_coreimage.cpp \
../../romtools/rofsbuild/r_build.cpp \
src/romreader.cpp \
src/imagereader.cpp \
src/e32reader.cpp \
src/rofsreader.cpp \
src/romimageheader.cpp \
src/rofsimage.cpp \
src/utils.cpp \
src/dirreader.cpp
	
all: $(lib)

.PHONY: all clean fixes remove_fixes

bases = $(basename $(srcs))

objs = $(addsuffix .o,$(bases))

$(srcs): fixes

$(lib): $(objs)
	ar r $@ $(objs)

clean: remove_fixes
	rm -f $(objs) $(lib)

fixes:: $(fixbackups)

inc/typedefs.h.original:
	cp $(basename $@) $@ && \
	sed -e 's|fstream.h|fstream|g' -e 's|iostream.h|iostream|g' \
		-e 's|typedef ios|typedef std::ios|g' \
		-e 's|typedef ofstream|typedef std::ofstream|g' \
		-e 's|typedef ifstream|typedef std::ifstream|g' -i $(basename $@)

remove_fixes: 
	for file in $(fixbackups); do if [ -f $$file ]; then mv -f $$file $${file%\.original}; fi; done

