#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.
 
# Script to list the available targets in the build package.
# Lists all directories that contain a BLD.INF or bld.inf file.

use strict;
use places;
use usage;
use check_os;
use File::Spec;
sub list_targets($);

my @broken_targs = (File::Spec->catfile("buildtoolguides","sbsv2guide"));
usage(\@ARGV,"This script lists the available Raptor targets in the build package",
		"Lists all directories that contain a BLD.INF or bld.inf file");

my $epocroot = get_epocroot();
my $build_pkg_dir = get_pkg_dir();
my $build_pkg_dir_parts = File::Spec->splitdir($build_pkg_dir);
--$build_pkg_dir_parts, if (os_is_windows()); # Discount drive letter on Windows.
  
list_targets($build_pkg_dir);
exit 0;

sub list_targets($)
{
	my($path) = @_; 
	$path = File::Spec->catfile("$path",'*');
	for my $entry (glob($path)) {
		if( -d $entry) {
			list_targets($entry);
		} else {
			my ($vol,$dirs,$file) = File::Spec->splitpath($entry);
			if ($file eq 'BLD.INF' or $file eq 'bld.inf') {
				my @dir_parts = File::Spec->splitdir(File::Spec->catfile($vol,$dirs));
				for (my $i = 0; $i <= $build_pkg_dir_parts; ++$i) {
				    shift(@dir_parts);
                }
                while(!$dir_parts[$#dir_parts]) {
                    pop @dir_parts;
                }                
                if ($dir_parts[$#dir_parts] eq "group") {
                    pop @dir_parts;
                }
				my $targ = File::Spec->catdir(@dir_parts);
				print "$targ";
				if ($targ eq File::Spec->catfile("sbsv2","pvmgmake")) {
					print " *** Nothing to build. Don't bother ***";
				}
				my $raptor_test_targ_prefix = File::Spec->catfile("sbsv2","raptor","test");
				if ($targ =~ /^$raptor_test_targ_prefix/) {
					print " *** Skipping Raptor's test suite ***";
				}
				foreach my $broken_targ (@broken_targs) {
                    if ($targ eq $broken_targ) {
					   print " *** Broken upstream. Don't bother ***";
					}
				}
				print "\n";				
			}
		}
	}
}

