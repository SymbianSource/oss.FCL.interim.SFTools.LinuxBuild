#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org for Symbian Foundation Ltd - initial contribution.

# Script to remove all files created by building Raptor"

use strict;
use usage;
use perl_run;
use File::Spec;
use File::Path 'remove_tree';
use places;

usage(\@ARGV,"This script removes all files created by building Raptor");
my $any_old_targ = File::Spec->catfile("buildtoolguides","romtoolsguide");
my $build_log = perl_slurp("build_target.pl $any_old_targ --what 2> ". File::Spec->devnull());
$build_log =~ /<info>Environment HOSTPLATFORM_DIR=(\S*)<\/info>/;
my $host_platform_dir = $1;
die "*** Error: Can't determine HOSTPLATFORM_DIR ***", unless ($host_platform_dir);
my $epocroot = get_epocroot();
my $abs_host_platform_dir = File::Spec->catfile(get_sbs_home(),"$host_platform_dir");
if (-d $abs_host_platform_dir) {
	print ">>> Clean Raptor\n";
	perl_run("clean_raptor.pl") and die $!;
	print ">>> Delete the HOSTPLATFORM_DIR\n";
	print ">>> HOSTPLATFORM_DIR = \"$abs_host_platform_dir\"\n";
	my $remove_tree_err;
	remove_tree($abs_host_platform_dir, { verbose => 1, error => \$remove_tree_err });
	if (@$remove_tree_err) {
		print "*** Error(s) while deleting HOSTPLATFORM_DIR ***\n";
		for my $diag (@$remove_tree_err) {
			my ($file, $message) = %$diag;
			if ($file eq '') {
				print "+++ General error: $message\n";
			} else {
				print "+++ Error unlinking \"$file\": $message\n";
			}
		}
		exit 1;
	}
}
print ">>> OK\n";
exit 0;

