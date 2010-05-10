#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org for Symbian Foundation Ltd - initial contribution.

# Script to patch the epoc32 tree on Windows, so that it provides a valid
# pre-include header file to enable compiling of the tools code with gcc 3.4.5

use strict;
use apply_patch_file;
use usage;
use check_os;
use File::Spec;

require_os_windows();
usage(\@ARGV,"This script makes required fixes to epoc32 tree in Windows");
set_epocroot();
my $epocroot = $ENV{'EPOCROOT'};
my $gcc_mingw_include_dir = File::Spec->catfile("$epocroot","epoc32","include","gcc_mingw");

if (! -d $gcc_mingw_include_dir) { 
	print ">>> Creating \"$gcc_mingw_include_dir\"\n";
	mkdir $gcc_mingw_include_dir or die $!;
}
my $gcc_mingw_preinclude = File::Spec->catfile("epoc32","include","gcc_mingw","gcc_mingw_3_4_2.h");
my $libwsock32_deb = File::Spec->catfile("epoc32","release","tools2","deb","libwsock32.a");
my $libwsock32_rel = File::Spec->catfile("epoc32","release","tools2","rel","libwsock32.a");
apply_patch_file($gcc_mingw_preinclude);
apply_patch_file($libwsock32_deb);
apply_patch_file($libwsock32_rel);
exit 0;

