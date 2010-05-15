#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org for Symbian Foundation Ltd - initial contribution.


# Script to apply fixes to epoc32 tree on Linux so that:-
# - Case-sensitivity bug #1399 is worked around
# - Provide a valid pre-include header file to enable
#	compiling of the tools code with gcc 4.4.x


use strict;
use File::Spec;
use apply_patch_file;
use usage;
use check_os;

require_os_linux();

usage(\@ARGV,"This script makes required fixes to epoc32 tree in Linux");
my $epocroot = get_epocroot();
my $wrong_product_variant_hrh = File::Spec->catfile(get_epoc32_dir(),"include","ProductVariant.hrh");
my $right_product_variant_hrh = File::Spec->catfile(get_epoc32_dir(),"include","productvariant.hrh");
if (! -f $right_product_variant_hrh and ! -l $right_product_variant_hrh) {
	symlink($wrong_product_variant_hrh,$right_product_variant_hrh) or die $!;
	print ">>> Created symlink \"$wrong_product_variant_hrh\" -> \"$right_product_variant_hrh\"\n";
	print ">>> (workaround for bug #1399)\n";
}
my $gcc_include_dir = File::Spec->catfile(get_epoc32_dir(),"include","gcc");
if (! -d $gcc_include_dir) {
	mkdir $gcc_include_dir or die $!;
	print ">>> Created \"$gcc_include_dir\"\n";
}
my $gcc_441_prelinclude_hdr_rel = File::Spec->catfile("epoc32","include","gcc","gcc_4_4_1.h");
my $gcc_441_prelinclude_hdr_abs = File::Spec->catfile("$epocroot","$gcc_441_prelinclude_hdr_rel");
my $gcc_prelinclude_hdr = File::Spec->catfile("$epocroot","epoc32","include","gcc","gcc.h");
if (apply_patch_file($gcc_441_prelinclude_hdr_rel)) {
	print ">>> Created \"$gcc_441_prelinclude_hdr_abs\"\n";
	unlink($gcc_prelinclude_hdr)
}
if (! -l $gcc_prelinclude_hdr) {
	symlink($gcc_441_prelinclude_hdr_abs,$gcc_prelinclude_hdr);
	print ">>> Created symlink \"$gcc_441_prelinclude_hdr_abs\" -> \"$gcc_prelinclude_hdr\"\n";
}
exit 0;

