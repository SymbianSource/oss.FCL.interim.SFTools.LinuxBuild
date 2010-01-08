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
# This is a Linux makefile for rcomp. 

# Need to make symklinks rcomp.l -> RCOMP.LEX, rcomp.y -> RCOMP.YACC

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

cpp_inc_paths = -I inc -I src

lib_opts =

exe = rcomp

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags)
LDFLAGS = $(lib_opts) $(global_ld_flags)

prereqs =

ucase_lexyaccfiles = src/RCOMP.LEX src/RCOMP.YACC
lcase_lexyaccfiles = $(shell echo $(ucase_lexyaccfiles) | tr '[:upper:]' '[:lower:]')

ucase_srcfiles = \
src/ARRAY.CPP \
src/ASTRING.CPP \
src/CCODES.CPP \
src/CTABLE.CPP \
src/DATATYPE.CPP \
src/ERRORHAN.CPP \
src/FILEACC.CPP \
src/FILELINE.CPP \
src/INDEXTAB.CPP \
src/LINKLIST.CPP \
src/MEM.CPP \
src/NAMEIDMA.CPP \
src/NUMVAL.CPP \
src/RCBINSTR.CPP \
src/RCOSTRM.CPP \
src/RCSCAN.CPP \
src/RCSTACK.CPP \
src/RESOURCE.CPP \
src/STACK.CPP \
src/STRINGAR.CPP \
src/STRUCTST.CPP \
src/UNICODE_COMPRESSOR.CPP \
src/QUALIFAR.CPP

lcase_srcfiles = $(shell echo $(ucase_srcfiles) | tr '[:upper:]' '[:lower:]')
 
srcs = src/main.cpp \
src/localise.cpp \
src/messages.cpp \
src/rcompl.cpp \
src/rcomp.cpp $(lcase_srcfiles)

ifneq "$(wildcard inc/*.H.original)" ""
ucase_headers := $(basename $(wildcard inc/*.H.original))
else
ucase_headers := $(wildcard inc/*.H)
endif

lcase_headers = $(shell echo $(ucase_headers) | tr '[:upper:]' '[:lower:]')

fixfiles = $(ucase_srcfiles) $(ucase_lexyaccfiles) $(ucase_headers) inc/Parser.h
fixedfiles = $(lcase_srcfiles) $(lcase_lexyaccfiles) $(lcase_headers) inc/parser.h
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
	for uchdr in $(ucase_headers) inc/Parser.h; do \
		uchdr=$${uchdr##inc/} && \
		lchdr=`echo $$uchdr | tr '[:upper:]' '[:lower:]'` && \
		uchdr=$${uchdr/./\\.} && \
		for file in $(srcs) inc/*.h; do \
			sed -e "s|$$uchdr|$$lchdr|g" -i $$file; \
		done; \
	done && \
	sed -e 's|^typedef bool TBool;||g' -i inc/unicode_compressor.h

$(fixbackups):
	ucfile=$(basename $@) && \
	cp $$ucfile $@ && \
	lcfile=`echo $$ucfile | tr '[:upper:]' '[:lower:]'` && \
	mv $$ucfile $$lcfile

clean: remove_fixes
	rm -f $(objs) $(exe)

remove_fixes:
	rm -f $(fixedfiles)
	for file in $(fixbackups); do if [ -f $$file ]; then mv -f $$file $${file%\.original}; fi; done

