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
use set_epocroot;
use usage;
use File::Spec;
sub list_targets($);

my @broken_targs = (File::Spec->catfile("buildtoolguides","sbsv2guide"));
usage(\@ARGV,"This script lists the available Raptor targets in the build package",
		"Lists all directories that contain a BLD.INF or bld.inf file");


set_epocroot();
my $epocroot = $ENV{'EPOCROOT'};
my $build_pkg_dir = File::Spec->catfile("$epocroot","build");
my $build_pkg_dir_parts = File::Spec->splitdir($build_pkg_dir);
  
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

