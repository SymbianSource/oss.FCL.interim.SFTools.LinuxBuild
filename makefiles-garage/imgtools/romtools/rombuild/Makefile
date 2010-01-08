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

fixfiles = rombuild.cpp r_global.cpp r_global.h
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

clean: remove_fixes
	rm -f $(objs) $(exe)

fixes:: $(fixbackups)

rombuild.cpp.original:
	cp $(basename $@) $@ && \
	sed -e 's|^TInt gCPUNum = 0;||g' \
		-e 's|TInt gThreadNum = 0;||g' \
		-e 's|char\* g_pCharCPUNum = NULL;||g' \
		-e 's|TBool gGenDepGraph = EFalse;||g' \
		-e 's|char\* gDepInfoFile = NULL;||g' -i $(basename $@)

r_global.cpp.original:
	cp $(basename $@) $@ && \
	printf "TInt gCPUNum = 0;\nTInt gThreadNum = 0;\nchar* g_pCharCPUNum = NULL;\nTBool gGenDepGraph = EFalse;\nchar* gDepInfoFile = NULL;\n" >> $(basename $@)

r_global.h.original:
	cp $(basename $@) $@ && \
	sed '/^extern TInt gPageIndexTableSize/a\
extern TInt gCPUNum;\
extern TInt gThreadNum;\
extern char* g_pCharCPUNum;\
extern TBool gGenDepGraph;\
extern char* gDepInfoFile;'  -i $(basename $@)


remove_fixes: 
	for file in $(fixbackups); do if [ -f $$file ]; then mv -f $$file $${file%\.original}; fi; done

