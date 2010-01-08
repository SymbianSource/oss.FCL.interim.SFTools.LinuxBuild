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
# This is a Linux makefile for elf2e32.

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

cpp_inc_paths = -I source -I include -I $(EPOCROOT)/epoc32/include/tools -include ext/hash_map

lib_opts =

exe = elf2e32

CPPFLAGS = $(cpp_inc_paths) $(global_cpp_flags)
LDFLAGS = $(lib_opts) $(global_ld_flags)

srcs = source/deffile.cpp  source/deflatecompress.cpp  source/dll_fb_target.cpp  source/dll_rebuild_target.cpp  \
source/e32exporttable.cpp source/filedump.cpp  source/e32imagefile.cpp source/elf2e32.cpp  source/elffilesupplied.cpp \
source/errorhandler.cpp source/exetarget.cpp source/exexp_fb_target.cpp source/exexp_rebuild_target.cpp \
source/export_type_fb_target.cpp  source/export_type_rebuild_target.cpp  source/export_type_target.cpp  source/h_utl.cpp \
source/huffman.cpp  source/imgdump.cpp  source/inflate.cpp  source/librarytarget.cpp  source/main.cpp \
source/messagehandler.cpp  source/messageimplementation.cpp source/parameterlistinterface.cpp  source/parametermanager.cpp \
source/pl_common.cpp  source/pl_dllsymbol.cpp source/pl_dso_handler.cpp  source/pl_elfconsumer.cpp \
source/pl_elfexecutable.cpp  source/pl_elfexports.cpp  source/pl_elfimportrelocation.cpp  source/pl_elfimports.cpp \
source/pl_elflocalrelocation.cpp  source/pl_elfproducer.cpp source/pl_elfrelocation.cpp source/pl_elfrelocations.cpp  \
source/pl_symbol.cpp source/polydll_fb_target.cpp source/polydll_rebuild_target.cpp  source/usecasebase.cpp \
source/byte_pair.cpp source/pagedcompress.cpp source/checksum.cpp source/stdexe_target.cpp

fixfiles = source/pl_elfexecutable.h source/e32imagefile.cpp source/elffilesupplied.cpp source/parametermanager.cpp
fixbackups = $(addsuffix .original,$(fixfiles)) 

.PHONY: all clean fixes remove_fixes

all: $(exe)

$(srcs): fixes

bases = $(basename $(srcs))

objs = $(addsuffix .o,$(bases))

$(exe): $(objs)
	$(CC) -o $@ $(objs) $(LDFLAGS)

clean: remove_fixes
	rm -f $(objs) $(exe)

fixes:: $(fixbackups)

source/pl_elfexecutable.h.original:
	cp $(basename $@) $@ && \
	sed -e 's|using std::hash_map;|using __gnu_cxx::hash_map;|g' -i $(basename $@)

source/e32imagefile.cpp.original:
	cp $(basename $@) $@ && \
	sed	-e 's|memcpy(iImportSection, aImportSection\.begin(), aImportSectionSize);|memcpy(iImportSection, \&*aImportSection.begin(), aImportSectionSize);|g' \
		-e 's|memcpy(aInfo+aPos, iSymAddrTab\.begin(),|memcpy(aInfo+aPos, \&*iSymAddrTab.begin(),|g' \
		-e 's|memcpy( ((void\*)(aInfo+aPos)), ((void\*)Iter), aOffLen);|memcpy( ((void*)(aInfo+aPos)), ((void*)\&*Iter), aOffLen);|g' \
		-e 's|memcpy(aInfo+aPos, iSymbolNames\.begin(), iSymbolNames\.size());|memcpy(aInfo+aPos, \&*iSymbolNames.begin(), iSymbolNames.size());|g' \
		-i $(basename $@)

source/elffilesupplied.cpp.original:
	cp $(basename $@) $@ && \
	sed -e 's|using namespace std;|using namespace std; using __gnu_cxx::hash_set; using __gnu_cxx::hash;|g' -i $(basename $@)

source/parametermanager.cpp.original:
	cp $(basename $@) $@ && \
	sed -e 's|ParseCapability1(b, e, aCapabilities, invert);|ParseCapability1(\&*b, \&*e, aCapabilities, invert);|g' \
		-e 's|memcpy(symbol, p, len);|memcpy(symbol, \&*p, len);|g'  -i $(basename $@)


remove_fixes: 
	for file in $(fixbackups); do if [ -f $$file ]; then mv -f $$file $${file%\.original}; fi; done

