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
# This is a Linux makefile for the filesystem library. 

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

cpp_inc_paths = -I include

lib = libfilesystem.a

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags) 

srcs = \
source/cluster.cpp \
source/directory.cpp \
source/dirregion.cpp \
source/errorhandler.cpp \
source/fat16bootsector.cpp \
source/fat16filesystem.cpp \
source/fat32bootsector.cpp \
source/fat32filesystem.cpp \
source/fatbasebootsector.cpp \
source/filesysteminterface.cpp \
source/longentry.cpp \
source/longname.cpp \
source/messagehandler.cpp \
source/messageimplementation.cpp \
source/filesystemclass.cpp

all: $(lib)

.PHONY: all patches remove_patches clean

bases = $(basename $(srcs))

objs = $(addsuffix .o,$(bases))

$(lib): $(objs)
	ar r $@ $(objs)

clean:
	rm -f $(objs) $(lib)

