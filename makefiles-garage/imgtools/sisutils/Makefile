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
# This is a Linux makefile for the sisutils library. 


ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

#todo_target = seclib
#include $(EPOCROOT)/build/makefiles-garage/todo.mk
#all: todo

cpp_inc_paths = -I inc

lib = libsisutils.a

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags) 

srcs = \
src/sisutils.cpp \
src/sis2iby.cpp \
src/pkglanguage.cpp \
src/pkgfileparser.cpp

fixfiles = src/sisutils.cpp src/sis2iby.cpp src/pkgfileparser.cpp inc/pkgfileparser.h inc/sisutils.h
fixbackups = $(addsuffix .original,$(fixfiles))

all: $(lib)

.PHONY: all clean fixes remove_fixes

$(srcs): fixes

bases = $(basename $(srcs))

objs = $(addsuffix .o,$(bases))

$(lib): $(objs)
	ar r $@ $(objs)

clean: remove_fixes
	rm -f $(objs) $(lib)

fixes:: $(fixbackups)

$(fixbackups):
	cp $(basename $@) $@ && \
	cp -f $(EPOCROOT)/build/clobber/imgtools/sisutils/$(basename $@) $(EPOCROOT)/build/imgtools/sisutils/$(basename $@) 
	
remove_fixes: 
	for file in $(fixbackups); do if [ -f $$file ]; then mv -f $$file $${file%\.original}; fi; done

