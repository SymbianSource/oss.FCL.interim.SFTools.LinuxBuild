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
# This is a Linux makefile for the seclib library. 


ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

fixfiles = ../setcap/setcap.h
fixbackups = $(addsuffix .original,$(fixfiles)) 

cpp_inc_paths = \
-I ../../../imgtools/imglib/compress \
-I ../setcap \
-I ../../e32lib/e32image/inc

lib = libseclib.a

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags)
CXXFLAGS = $(global_cxx_flags) -pthread 

srcs = \
seclib.cpp \
../e32image/e32image.cpp \
../e32image/deflate/decode.cpp \
../e32image/deflate/encode.cpp \
../e32image/deflate/deflate.cpp \
../e32image/deflate/inflate.cpp \
../e32image/deflate/panic.cpp \
../e32image/deflate/compress.cpp \
../../../imgtools/imglib/compress/pagedcompress.cpp \
../../../imgtools/imglib/compress/byte_pair.cpp \
../../../imgtools/imglib/e32uid/e32uid.cpp \
../setcap/setcap.cpp \
../../../imgtools/imglib/host/h_file.cpp \
../../../imgtools/imglib/host/h_mem.cpp \
../../../imgtools/imglib/host/h_utl.cpp

	
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

../setcap/setcap.h.original:
	cp $(basename $@) $@ && \
	sed -e 's|#if !defined(__TOOLS2_LINUX__)|#if !(defined(__TOOLS2__) \&\& defined(__LINUX__))|g' -i $(basename $@)

remove_fixes: 
	for file in $(fixbackups); do if [ -f $$file ]; then mv -f $$file $${file%\.original}; fi; done

