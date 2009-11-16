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
# This is a Linux makefile for the Symbian build tools components.

epocroot := $(dir $(realpath ../epoc32))
ifneq '$(epocroot)' ''
epocroot := $(patsubst %/,%,$(epocroot))
$(warning WARNING: EPOCROOT not set. Assuming $(epocroot))
export EPOCROOT=$(epocroot)
else
$(error EPOCROOT must be defined as the parent directory of your epoc32 tree)
endif

ifdef EPOCROOT
include $(EPOCROOT)/build/makefiles-garage/global-make-env.mk
endif

garage = $(EPOCROOT)/build/makefiles-garage
garage_makefiles = $(shell find $(garage) -name Makefile)
targets = $(notdir $(patsubst %/Makefile,%,$(garage_makefiles)))
clean_targets = $(addsuffix -clean,$(targets))
garage_make_dirs = $(patsubst %/Makefile,%,$(garage_makefiles))
make_dirs = $(patsubst $(garage)%,$(EPOCROOT)/build%,$(garage_make_dirs)) 
makefiles = $(patsubst $(garage)/%,$(EPOCROOT)/build/%,$(garage_makefiles))
raptor_linux_binaries = $(EPOCROOT)/build/sbsv2/raptor/linux-*
new_subdirs = $(EPOCROOT)/build/imgtools/romtools/r_t_areaset
subdirs = imgtools e32tools sbsv2 srctools buildframework buildtoolguides bintools
	
.PHONY: all tools export gen_preinclude clean distclean deploy_makefiles gather_makefiles help \
sbs_comp_list sbs_targ_list list_hacks list_prereqs

all: tools

tools: $(preinclude) $(makefiles)
	for dir in $(subdirs); do $(MAKE) -C $$dir; done

 
#export: tools
#	for dir in $(subdirs); do $(MAKE) -C $$dir export; done
		
clean: $(makefiles)
	for dir in $(subdirs); do $(MAKE) -C $$dir clean; done

distclean: clean
	rm -f -r $(makefiles) $($(preinclude) $(linux_gcc_defs_inc) $(raptor_linux_binaries) $(new_subdirs)

help:
	@echo "Build the Symbian build tools by conventional GNU/Linux means."
	@echo "PHONY targets:"
	@echo "" 	
	@echo "  help"
	@echo "  all              - Build all real targets (default)"
	@echo "  clean            - Remove all build object files, libraries and executables"
	@echo "  TARGET-clean     - clean the real target TARGET"
	@echo "  distclean        - Remove everything but the original files"
	@echo "  deploy_makefiles - Copy makefiles from the garage to the locations where they run"
	@echo "  gather_makefiles - Gather any new or updated makefiles from the places where they run into the garage"
	@echo "  export           - TODO: No exports are implemented yet"
	@echo "  what             - TODO: \"What is built?\" not implemented yet"
	@echo "  TARGET-what      - TODO: \"What is built for TARGET?\" not implemented yet" 
	@echo "  sbs_comp_list    - List the components that sbs would find (BLD.INF files)"
	@echo "  sbs_targ_list    - List the targets that sbs would find (MMP files)"
	@echo "  list_prereqs     - List the dependency graph of final targets"
	@echo "  list_hacks       - List the targets and files for which hacks are currently applied."
	@echo "                     The hacks are applied by the make and removed by clean." 
	@echo ""  
	@echo "Real targets in hierarchy:"
	@echo ""
	@for file in $(sort $(garage_makefiles)); do \
		dummy=`grep 'include $$(EPOCROOT)/build/makefiles-garage/todo.mk' $$file 2> /dev/null`;\
		todo=;\
		file=$${file#$(garage)/};\
		file=$${file%/Makefile};\
		targ=$${file##*/};\
		file=$${file%/*};\
		file=$${file%$${targ}};\
		file=`echo $$file | sed -e 's|/||g' -`;\
		file=$${file//?/-};\
		if [ "$${dummy}" != "" ]; then todo='  ### TODO ###'; fi; \
		echo "  $$file$$targ$$todo";\
	done

$(makefiles): $(EPOCROOT)/build/%: $(garage)/%
	mkdir -p $(dir $@) && cp $< $@

deploy_makefiles: $(makefiles)

gather_makefiles:
	for dir in $(subdirs); do \
		grep --include Makefile -r -e 'include $$(EPOCROOT)/build/makefiles-garage/global-make-env.mk' $$dir | \
		sed -e 's|:include $$(EPOCROOT)/build/makefiles-garage/global-make-env.mk||g' -e 's|$(EPOCROOT)/build/||g' - | while read makefile; do \
			if [ ! -f $(garage)/$$makefile ]; then \
				echo "### Garaging new makefile $(garage)/$$makefile ###" ;\
				cp -f --parents $$makefile $(garage); \
			else if [ $(EPOCROOT)/build/$$makefile -nt $(garage)/$$makefile ]; then \
				if [ "`diff $(EPOCROOT)/build/$$makefile $(garage)/$$makefile`" != "" ]; then \
					echo "### Updating garaged makefile $(garage)/$$makefile ###" ;\
					cp -f --parents $$makefile $(garage); \
				fi; \
			fi; \
			fi; \
		done; \
	done

sbs_comp_list:
	@for file in `find . -iname 'bld.inf'`; do echo $${file}; done

sbs_targ_list:
	@for file in `find . -iname '*.mmp'`; do echo $${file}; done

list_hacks: $(makefiles)
	@for make_dir in $(sort $(make_dirs)); do \
		$(MAKE) -s -C $$make_dir query=1 targ=$${make_dir##*/} hacks; \
	done	

list_prereqs: $(makefiles)
	@for make_dir in $(sort $(make_dirs)); do \
		$(MAKE) -s -C $$make_dir query=1 targ=$${make_dir##*/} prereqs; \
	done

$(targets): $(preinclude) $(makefiles)
	garage_makedir=`find $(garage) -name $@`;\
	makedir=$${garage_makedir##$(garage)/};\
	makedir=$(EPOCROOT)/build/$${makedir};\
	$(MAKE) -C $${makedir}

$(clean_targets): $(makefiles)
	targ=$@; \
	targ=$${targ%-clean}; \
	garage_makedir=`find $(garage) -name $${targ}`;\
	echo $$targ; \
	makedir=$${garage_makedir##$(garage)/};\
	makedir=$(EPOCROOT)/build/$${makedir};\
	$(MAKE) -C $${makedir} clean

