#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Subroutines to deploy a patch file.
# The required patch files reside in build/{linux-prep|windows-prep}/patch_files.
# A patch file with the path:
#   patch-files/DIR1[/DIR...]/FILE
# will be copied to EPOCROOT/DIR1[/DIR...]/FILE,
# except in the special case where DIR1 begins with '$'.
# In this case, the DIR1 is construed as the name of an environment
# variable whose value VAL will be substituted to obtain the name of the
# destination file as VAL//DIR1[/DIR...]/FILE.

use strict;
use File::Spec;
use File::Copy;
use set_epocroot;
use check_os;

sub compare_files($$)
{
    my ($flhs,$frhs) = @_;
    my $delim = $/;
    $/ = undef;
    open FH,"<$flhs" or die $!;
    my $slhs = <FH>;
    close FH;
    open FH,"<$frhs" or die $!;
    my $srhs = <FH>;
    close FH;
    $/ = $delim;
    return "$slhs" eq "$srhs"; 
}

sub apply_patch_file($)
{
    my $patch_file = shift;
    my ($src_file, $dest_file);
    set_epocroot();
    my $epocroot = $ENV{'EPOCROOT'};
    my $patch_files_dir;
	if (os_is_windows()) {
		$patch_files_dir = File::Spec->catfile("$epocroot","build","cross-plat-dev-utils","patch-files","windows");
	} elsif (os_is_linux()) {
		$patch_files_dir = File::Spec->catfile("$epocroot","build","cross-plat-dev-utils","patch-files","linux");
	} else {
		die "*** Unsupported OS $^O ***";
	} 
    $src_file = File::Spec->catfile($patch_files_dir,$patch_file);
    if (! -f $src_file) {
        die("*** Error: not found \"$src_file\" ***");    
    }    
    if ($patch_file =~ /^\$/) {
        my ($vol,$dir,$file) = File::Spec->splitpath($patch_file);
        my @dirs = File::Spec->splitdir($dir);
        my $topdir = shift(@dirs);
        $topdir =~ s/^\$//;
        $topdir = $ENV{$topdir};
        my $destdir = File::Spec->catfile($topdir,@dirs);
        $dest_file = File::Spec->catfile($destdir,$file);
    }
    else {
        $dest_file = File::Spec->catfile($epocroot,$patch_file);
    }
	print "??? Need patch \"$src_file\" -> \"$dest_file\" ??? \n";
	if (! -f $dest_file) { 
		print ">>> Yes. \"$dest_file\" does not exist\n";
		print ">>> Copying \"$src_file\" to \"$dest_file\"n";
		copy($src_file,$dest_file) or die $!;
	}
	else {
		my $dif = !compare_files($src_file,$dest_file);
		print "$dif\n";
		if (!$dif) {
		  print ">>> No. \"$dest_file\" is same as \"$src_file\"\n";	   
		}
		else {
			print ">>> Yes. \"$dest_file\" differs  from \"$src_file\"\n";
			my $backup = $dest_file;
			for (; -f ($backup .= '~');) {};
			print ">>> Backing up \"$dest_file\" as \"$backup\"\n";
			copy($dest_file,$backup) or die $!;
			print ">>> Copying \"$src_file\" to \"$dest_file\"\n";                     
			copy($src_file,$dest_file) or die $!;       
		}
    }
}

1;


