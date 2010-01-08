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
# This is a Linux makefile for readimage. 


ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

cpp_inc_paths = \
-I ../readimage/inc \
-I ../rofsbuild \
-I../rombuild \
-I ../../imglib/compress \
-I ../../imglib/patchdataprocessor/include \
-I ../../sisutils/inc \
-I ../../imglib/inc

lib_opts = -lboost_thread-mt \
-L../../sisutils -lsisutils \

exe = readimage 

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags) -D__SUPPORT_ELF_FILES__
CXXFLAGS = $(global_cxx_flags) -pthread
LDFLAGS = $(lib_opts) $(global_ld_flags)

prereqs = sisutils rombuild rofsbuild patchdataprocessor 

srcs = \
src/common.cpp \
src/e32_image_reader.cpp \
src/image_handler.cpp \
src/image_reader.cpp \
src/rofs_image_reader.cpp \
src/rom_image_reader.cpp \
../../imglib/e32uid/e32uid.cpp \
../../imglib/host/h_file.cpp \
../../imglib/host/h_mem.cpp \
../../imglib/host/h_utl.cpp \
../rofsbuild/r_build.cpp \
../rofsbuild/r_coreimage.cpp \
../rombuild/r_global.cpp \
../../imglib/e32image/e32image.cpp \
../../imglib/e32image/deflate/decode.cpp \
../../imglib/e32image/deflate/encode.cpp \
../../imglib/e32image/deflate/deflate.cpp \
../../imglib/e32image/deflate/inflate.cpp \
../../imglib/e32image/deflate/panic.cpp \
../../imglib/e32image/deflate/compress.cpp \
../../imglib/compress/pagedcompress.cpp \
../../imglib/compress/byte_pair.cpp \
../../imglib/patchdataprocessor/source/patchdataprocessor.cpp

fixfiles = inc/image_reader.h src/image_reader.cpp src/rofs_image_reader.cpp src/rom_image_reader.cpp

fixbackups = $(addsuffix .original,$(fixfiles))
 
.PHONY: all clean $(prereqs) fixes remove_fixes

all: $(exe)

$(srcs): fixes

bases = $(basename $(srcs))

objs = $(addsuffix .o,$(bases))

$(prereqs): $(global_prereqs)
	$(MAKE) -C $(EPOCROOT)/build $@

$(objs): $(prereqs)
 
$(exe): $(objs)
	$(CC) -o $@ $(objs) $(LDFLAGS)

fixes:: $(fixbackups)

clean: remove_fixes
	rm -f $(objs) $(exe)

inc/image_reader.h.original:
	cp $(basename $@) $@ && \
	sed -e 's|^#include <direct.h>||g' -i $(basename $@)

src/image_reader.cpp.original:
	cp $(basename $@) $@ && \
	sed -e 's|_getcwd|GETCWD|g' -e 's|_chdir|CHDIR|g' -e 's|_mkdir|MKDIR|g' -e '/^#include "image_reader.h"/a\
#if defined(_WIN32)\
#include <direct.h>\
#define GETCWD _getcwd\
#define MKDIR _mkdir\
#define CHDIR _chdir\
#elif defined(__LINUX__)\
#include <unistd.h>\
#include <sys/stat.h>\
#define GETCWD getcwd\
#define MKDIR(d) mkdir(d,S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH)\
#define CHDIR chdir\
#else\
#error Target OS not defined\
#endif' -i  -i $(basename $@)

src/rofs_image_reader.cpp.original:
	cp $(basename $@) $@ && \
	sed -e 's|iInputFile->seekg(aOff, aStartPos);|iInputFile->seekg(aOff, SEEKDIR(aStartPos));|g' -e '/^#include "e32_image_reader.h"/a\
#if defined(_WIN32)\
#define SEEKDIR(pos) pos\
#elif defined(__LINUX__)\
#define SEEKDIR(pos) std::_Ios_Seekdir(pos)\
#else\
#error Target OS not defined\
#endif' -i  -i $(basename $@)

src/rom_image_reader.cpp.original:
	cp $(basename $@) $@ && \
	sed -e 's|_alloca|ALLOCA|g' -e '/#include "r_rom.h"/a\
#if defined(_WIN32)\
#define ALLOCA _alloca\
#elif defined(__LINUX__)\
#include <alloca.h>\
#define ALLOCA alloca\
#else\
#error Target OS not defined\
#endif' -i  -i $(basename $@)


remove_fixes: 
	for file in $(fixbackups); do if [ -f $$file ]; then mv -f $$file $${file%\.original}; fi; done

