#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org for Symbian Foundation Ltd - initial contribution.

# Script to clone the upstream package at the baseline revision.

use strict;
use Cwd;
use get_baseline;
use File::Spec;

if (!@ARGV or @ARGV > 1 or grep(/$ARGV[0]/,("-h","--help"))) {
    print "This script clones or updates the upstream package at the baseline revision " .
		"from http://developer.symbian.org/oss/MCL/sftools/dev/build\n";
    print "Valid arguments are -h, --help, or CLONEDIR, where CLONEDIR is the" .
		" name of the existing directory into which the upstream package will " .
		"be cloned if this does not seem to have been already done Otherwise " .
		"CLONEDIR/build will be updated.\n";
	exit 0;
}         
my $clonedir = $ARGV[0];
unless ( -d "$clonedir") {
	die "*** Error: directory \"$clonedir\" does not exist ***";
}
my $baseline_rev = get_baseline();
print ">>> Baseline revision is $baseline_rev\n"; 
my $cwd = cwd;
my $cmd;
chdir $clonedir or die $!;
print ">>> Changed to dir \"$clonedir\"\n";
my $hg_dir = File::Spec->catfile("build",".hg");
if ( -d $hg_dir) {
	print ">>> There seems to a repo of the build package in \"$clonedir\"\n";
	print ">>> Will try to update it\n";
	chdir "build" or die $!;
	print ">>> Changed to dir \"build\"\n";
	$cmd = "hg update -c -r $baseline_rev ";

}
else {
	print ">>> There is no existing repo in \"$clonedir\"\n";
	print ">>> Will clone fresh\n";
 	$cmd = "hg clone -r $baseline_rev " .
	"http://developer.symbian.org/oss/MCL/sftools/dev/build";
} 
print ">>> Executing: $cmd\n";
my $rc = system($cmd) >> 8;
chdir $cwd or die $!;
print ">>> Changed to dir \"$cwd\"\n";
exit $rc;

