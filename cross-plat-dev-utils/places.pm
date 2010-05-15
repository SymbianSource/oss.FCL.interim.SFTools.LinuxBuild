#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Routines to get/set some essential paths.

use strict;
use Cwd;
use Cwd 'abs_path';
use File::Spec;

# get the package directory
sub get_pkg_dir()
{
	return abs_path("..");	
}

# get the epoc32 directory without insisting it exists
sub get_epoc32_path()
{
	my $epocroot = get_epocroot();
	my $epoc32 = File::Spec->catfile($epocroot,"epoc32");
	return $epoc32;
}

# get the epoc32 directory, insisting it exists
sub get_epoc32_dir()
{
	my $epoc32 = get_epoc32_path();
	die "*** Error: directory \"$epoc32\" does not exist ***",
		unless ( -d "$epoc32");	
	return $epoc32;
}

# Get the EPOCROOT directory, using the environment setting if it exists,
# otherwise assuming the parent of the package dir.
sub get_epocroot()
{
	my $epocroot = $ENV{'EPOCROOT'};
    unless ($epocroot) {
		$epocroot = abs_path(File::Spec->catfile("..",".."));
		if (-d "$epocroot") {
        	print ">>> EPOCROOT not defined. Assuming \"$epocroot\"\n";
		} else {
			die "*** Error: EPOCROOT not defined and guess \"$epocroot\" " .
				"does not exist ***";
		}
    	$ENV{'EPOCROOT'}=$epocroot;
		print ">>> EPOCROOT=\"$epocroot\"\n";
    }
	if (! -d "$epocroot") {
		die "*** Error: directory \"$epocroot\" does not exist ***";
	}
	else {
		my $epoc32 = File::Spec->catfile($epocroot,"epoc32");
		unless ( -d "$epoc32") {
			print "!!! Warning: No epoc32 die under EPOCROOT !!!\n";
		}
	}
	return $epocroot;
}

sub get_sbs_home()
{
	my $sbs_home = $ENV{'SBS_HOME'};
	unless($sbs_home) {
		$sbs_home = File::Spec->catfile(get_pkg_dir(),"sbsv2","raptor");
		if ( -d "$sbs_home") {
        	print ">>> SBS_HOME not defined. Assuming \"$sbs_home\"\n";
		} else {
			die "*** Error: SBS_HOME not defined and guess \"$sbs_home\" " .
				"does not exist ***";
		}
		$ENV{'SBS_HOME'} = $sbs_home;
	}
	unless ( -d "$sbs_home") {
		die "*** Error: directory \"$sbs_home\" does not exist ***";
	}
	return $sbs_home;
}

1;

