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
# This makefile sets up the global environment for building the Symbian build tools.
# It is included by all the makefiles.

ifndef global_make_env
# include the following only once

export global_make_env = 1

export gcc_patch = $(shell gcc --version | head -n 1 | sed -e 's/^.*\([0-9]\.[0-9]\.[0-9]\)$$/\1/g' -)
export gcc_ver = $(shell gcc --version | head -n 1 | sed -e 's/^.*\([0-9]\.[0-9]\)\.[0-9]$$/\1/g' -)

linux_gcc_inc_path = $(EPOCROOT)/epoc32/include/tools/linux/gcc
linux_gcc_ver_inc_path = $(linux_gcc_inc_path)/$(gcc_ver)
linux_gcc_patch_inc_path = $(linux_gcc_inc_path)/$(gcc_patch)
linux_gcc_defs_inc = $(linux_gcc_ver_inc_path)/hack_defs.h 
preinclude = $(linux_gcc_ver_inc_path)/preinclude.h
make_preinclude := $(shell if [ -f $(preinclude) ]; then echo N; else echo Y; fi)
global_cpp_defs = -D__LINUX__ -D__TOOLS2__ -D__TOOLS__ -D__GCC32__ -D__PLACEMENT_NEW_INLINE -D__PLACEMENT_VEC_NEW_INLINE
global_cpp_inc_paths = -I $(EPOCROOT)/epoc32/include -I $(EPOCROOT)/epoc32/include/tools/linux/gcc/$(gcc_ver)
global_cpp_preinclude = -include $(preinclude)
   
export CC = g++
export global_cpp_flags = $(global_cpp_defs) $(global_cpp_inc_paths) $(global_cpp_preinclude)
export global_cxx_flags = -O2
export global_prereqs = $(preinclude)
export global_cflags = 

ifeq ($(make_preinclude),Y)
# We need to make the global preinclude.h file

$(preinclude): $(linux_gcc_defs_inc)
	printf "#ifndef PREINCLUDE_H\n"\
"#include <cstdlib>\n"\
"#include <e32def.h>\n"\
"#include <hack_defs.h>\n"\
"#include <cstring>\n"\
"#include <climits>\n"\
"#include <exception>\n"\
"#include <new>\n"\
"#endif\n" >> $@
	$(MAKE)

$(linux_gcc_patch_inc_path):
	mkdir -p $@
	

$(linux_gcc_ver_inc_path) : $(linux_gcc_patch_inc_path)
	rm -f $@
	ln -s $< $@
	

$(linux_gcc_defs_inc): $(linux_gcc_ver_inc_path)
	printf "#ifndef HACK_DEFS_H\n"\
"#define HACK_DEFS_H\n"\
"#define DIMPORT_C\n"\
"#define __NO_THROW\n"\
"#define NONSHARABLE_CLASS(x) class x\n"\
"#undef _FOFF\n"\
"#define _FOFF(c,f) (((TInt)&(((c *)0x1000)->f))-0x1000)\n"\
"#define TEMPLATE_SPECIALIZATION template<>\n"\
"#undef __ASSERT_COMPILE\n"\
"#define __ASSERT_COMPILE(x)\n"\
"#define TAny void\n"\
"#endif\n" >> $@ 
  
endif
# End: make the global preinclude.h file  

endif
# End: included only once

ifdef query
# Running one of the query targets

hacks:
	@if [ "$(fixfiles)" != "" ]; then \
		echo $(targ): hacks for:-; \
		for file in $(fixfiles); do echo "  $$file"; done; \
	fi

prereqs:
	@if [ "$(prereqs)" != "" ]; then \
		echo $(targ): needs:-; \
		for prereq in $(prereqs); do echo "  $$prereq"; done; \
	fi
	
endif
# End: Running one of the query targets
 
