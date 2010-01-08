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
# This is a Linux makefile for getexports. 

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

cpp_inc_paths = -I ../inc -I $(EPOCROOT)/epoc32/include/tools

lib_opts =

exe = getexports

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags) -Dstricmp=_stricmp
LDFLAGS = $(lib_opts) $(global_ld_flags)

prereqs =

srcs = geninf.cpp

fixfiles = geninf.cpp
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

geninf.cpp.original:
	cp $(basename $@) $@ && \
	sed -e 's|stricmp|strcmp|g' -i $(basename $@)

