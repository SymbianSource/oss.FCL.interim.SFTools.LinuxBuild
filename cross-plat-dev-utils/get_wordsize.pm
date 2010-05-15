#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Subroutine to get the wordsize in bits of the host machine.

use strict;
use File::Path;
use File::Spec;
use check_os;
use places;

sub get_host_wordsize()
{
	if (os_is_windows()) {
		print ">>> Only 32bit Windows supported\n";
		return 32;
	} 
	my $source = "get_wordsize.c";
	unless(-f "$source") {
		die "*** Error: $source not found ***";
	}
	my $compile_cmd = "gcc -o get_wordsize $source";
	print ">>> Excuting: $compile_cmd\n";
	system($compile_cmd) >> 8 and die "*** Error: Could not compile $source ***";
	my $get_wordsize = "\.\/get_wordsize";
	print ">>> Excuting: $get_wordsize\n";
	my $wordsize = `$get_wordsize`;
	chomp $wordsize;
	die "$!", if ($? >> 8);
	$wordsize *= 8;
	print ">>> Host system wordsize is $wordsize bits\n";
	unlink("get_wordsize") or die $!;
	return $wordsize;
}

1;

