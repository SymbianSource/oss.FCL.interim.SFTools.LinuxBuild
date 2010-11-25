# Copyright (c) 2007-2009 Nokia Corporation and/or its subsidiary(-ies).
# All rights reserved.
# This component and the accompanying materials are made available
# under the terms of "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Nokia Corporation - initial contribution.
#
# Contributors:
#
# Description:
# Envoke CED to install correct CommDB
#

do_nothing :
	rem do_nothing

#
# The targets invoked by abld 
#

MAKMAKE : do_nothing

RESOURCE : do_nothing

SAVESPACE : BLD

BLD : do_nothing

FREEZE : do_nothing

LIB : do_nothing

CLEANLIB : do_nothing

FINAL : 
	perl $(EXTENSION_ROOT)/installdefaultcommdb.pl --command=build --platform=$(PLATFORM) --variant=$(CFG) --platsec

CLEAN : 
	perl $(EXTENSION_ROOT)/installdefaultcommdb.pl --command=clean --platform=$(PLATFORM) --variant=$(CFG) --platsec

RELEASABLES : 
	@perl $(EXTENSION_ROOT)/installdefaultcommdb.pl --command=releasables --platform=$(PLATFORM) --variant=$(CFG) --platsec
	


