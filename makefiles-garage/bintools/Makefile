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
# This is a Linux makefile for the bintools components.

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

subdirs = checklib elftools evalid rcomp

prereqs =

.PHONY: all clean $(prereqs)

all: $(prereqs)
	for file in $(subdirs); do $(MAKE) -C $$file; done

$(prereqs) : $(global_prereqs)
	$(MAKE) -C $(EPOCROOT)/build $@ 

clean:
	for file in $(subdirs); do $(MAKE) -C $$file clean; done

