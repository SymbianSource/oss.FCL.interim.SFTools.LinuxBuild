#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org for Symbian Foundation Ltd - initial contribution.

# Script to apply fixes to the Linux Raptor config so that:-
# - It will invoke regular gcc instead of gcc_mingw
# - It will use the regular standard C++ library instead of stlport 
# - The compiler complies with the c++0x standard.

use strict;
use File::Spec;
use apply_patch_file;
use usage;
use check_os;

require_os_linux();
usage(\@ARGV,"This script makes required fixes to Raptor configuration for Linux");
my $gcc_config_file = File::Spec->catfile("build","sbsv2","raptor","lib","config","gcc.xml");
apply_patch_file($gcc_config_file);
exit 0;

