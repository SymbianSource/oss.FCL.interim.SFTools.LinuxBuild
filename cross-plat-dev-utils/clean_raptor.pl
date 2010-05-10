#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org for Symbian Foundation Ltd - initial contribution.

# Script to clean Raptor (sbsv2) by running the 'clean' target of
# the Raptor build. 

use strict;
use usage;
use perl_run;

usage(\@ARGV,"This script cleans Raptor, by running the 'clean' target of " .
	"the Raptor build. ");
perl_run("build_raptor.pl clean") and die $!;
exit 0;
