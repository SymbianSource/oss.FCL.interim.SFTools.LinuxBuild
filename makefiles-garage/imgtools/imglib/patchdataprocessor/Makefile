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
# This is a Linux makefile for the for patchdataprocessor library. 

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

cpp_inc_paths = -I ../inc -I include \

lib = libpatchdataprocessor.a

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags) 

srcs = source/patchdataprocessor.cpp

all: $(lib)

.PHONY: all clean

bases = $(basename $(srcs))

objs = $(addsuffix .o,$(bases))

$(lib): $(objs)
	ar r $@ $(objs)

clean:
	rm -f $(objs) $(lib)

