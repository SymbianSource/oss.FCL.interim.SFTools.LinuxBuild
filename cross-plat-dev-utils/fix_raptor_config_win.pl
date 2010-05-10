#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org for Symbian Foundation Ltd - initial contribution.
 
# Script to apply fixes to the Windows Raptor config so that it 
# will use the regular standard C++ library instead of stlport 

use strict;
use apply_patch_file;
use usage;
use check_os;
use File::Spec;

require_os_windows();
usage(\@ARGV,"This script makes required fixes to the Windows Raptor configuration");
unless($ENV{'SBS_HOME'}) {
	die "*** SBS_HOME is not set ***";
}
my $gcc_config_file = File::Spec->catfile("\$SBS_HOME","lib","config","gcc.xml");
apply_patch_file($gcc_config_file);
exit 0;
