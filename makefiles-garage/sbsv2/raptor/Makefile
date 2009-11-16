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
# This is a Linux makefile for the raptor components.

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

subdirs = util
export CC=gcc
export SBS_HOME = $(patsubst %/,%,$(dir $(realpath Makefile)))

.PHONY: all clean

all:
	for dir in $(subdirs); do $(MAKE) -C $$dir; done

clean:
	for file in $(subdirs); do $(MAKE) -C $$file clean; done

