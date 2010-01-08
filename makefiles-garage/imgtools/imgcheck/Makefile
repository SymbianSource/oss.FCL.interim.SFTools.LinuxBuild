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
# This is a Linux makefile for the imgcheck .

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

prereqs = patchdataprocessor libimgutils

.PHONY: all clean fixes remove_fixes $(prereqs)

cpp_inc_paths = -I . -I .libxml  -I ../imglib/inc -I ../romtools/rofsbuild \
-I libimgutils/inc -I inc -I ../imglib/compress

lib_opts = -lxml2 -L libimgutils -limgutils -L ../imglib/patchdataprocessor -lpatchdataprocessor

exe = imgcheck

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags)
CXXFLAGS = $(global_cxx_flags) -pthread
LDFLAGS = $(global_ld_flags) $(lib_opts)

srcs = src/cmdlinehandler.cpp src/depchecker.cpp src/hash.cpp src/main.cpp \
src/imgcheckmanager.cpp src/sidchecker.cpp src/vidchecker.cpp src/common.cpp src/checker.cpp src/reporter.cpp \
src/exceptionimplementation.cpp src/exceptionreporter.cpp \
src/cmdlinewriter.cpp src/xmlwriter.cpp src/dbgflagchecker.cpp
 
bases = $(basename $(srcs))

objs = $(addsuffix .o,$(bases))

fixfiles = inc/exceptionimplementation.h inc/xmlwriter.h src/exceptionimplementation.cpp src/xmlwriter.cpp
fixbackups = $(addsuffix .original,$(fixfiles))

all: $(exe)

$(srcs): fixes 

$(prereqs): $(global_prereqs)
	$(MAKE) -C $(EPOCROOT)/build $@

$(objs): $(prereqs)

$(exe): $(objs)
	$(CC) -o $@ $(objs) $(LDFLAGS)

clean: remove_fixes
	rm -f $(objs) $(exe)
	for file in $(subdirs); do $(MAKE) -C $$file clean; done

fixes:: $(fixbackups)
	
inc/exceptionimplementation.h.original:
	cp $(basename $@) $@ && \
	sed -e 's|ofstream iLogStream;|Ofstream iLogStream;|g' -i $(basename $@)

inc/xmlwriter.h.original:
	cp $(basename $@) $@ && \
	sed -e 's|ofstream iXmlFile;|Ofstream iXmlFile;|g' -i $(basename $@)

src/exceptionimplementation.cpp.original:
	cp $(basename $@) $@ && \
	sed '/#include "exceptionimplementation.h"/ a\
using namespace std;' -i $(basename $@)

src/xmlwriter.cpp.original:
	cp $(basename $@) $@ && \
	sed -e 's|ifstream xslSourceHandle;|Ifstream xslSourceHandle;|g' \
		-e 's|ofstream xslDestHandle|Ofstream xslDestHandle|g' -i $(basename $@)

remove_fixes: 
	for file in $(fixbackups); do if [ -f $$file ]; then mv -f $$file $${file%\.original}; fi; done

