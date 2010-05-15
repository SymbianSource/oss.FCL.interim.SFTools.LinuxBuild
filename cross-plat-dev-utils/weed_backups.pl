#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org for Symbian Foundation Ltd - initial contribution.

# Script delete backup files from the package directory.

use strict;
use usage;
use File::Spec;
use places;

sub delete_backups($);

usage(\@ARGV,"This script deletes all files in the package directory " .
	"and the epoc32 tree with names ending in '~'\n");
my $epoc32_dir = get_epoc32_dir();
my $build_pkg_dir = get_pkg_dir();
my $deletes = 0;
delete_backups($build_pkg_dir);
delete_backups($epoc32_dir);
print ">>> $deletes files deleted\n"; 
exit 0;

sub delete_backups($)
{
	my($path) = @_; 
	print ">>> Weeding dir \"$path\"\n";
	$path = File::Spec->catfile("$path",'*');
	my @entries = glob($path);
	for my $entry (@entries) {
		if( -d $entry) {
			delete_backups($entry);
		} else {
			my @backups = grep(/~$/,@entries);
			foreach (@backups) {
				unlink $_;
				# Querying the result of unlink() for success is unreliable
				# on some tested systems.
				die "Failed to delete \"$_\"", if ( -f $_);
				++$deletes;
			}
		}
	}
}

