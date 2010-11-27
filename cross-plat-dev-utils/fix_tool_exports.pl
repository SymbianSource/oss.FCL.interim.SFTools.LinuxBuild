#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Script to perform all fix-up exports from this package.

use strict;
use perl_run;
use places;
use check_os;
use File::Spec;
my $keepgoing = 0;
my @exported = ();
my @failed = ();
# These are the targets that need exports performed.
my @needed_exports = (File::Spec->catfile("sbsv1","abld"),
    File::Spec->catfile("sbsv1","buildsystem"),
    File::Spec->catfile("imgtools","romtools"));
    
if (os_is_windows()) {
    foreach (@needed_exports) {
        s/\\/\//g;
    }
}

sub export($)
{
	my $targ = shift;
	return, if (is_exported($targ));
	print ">>> Cleaning exports for target $targ\n";
	my $rc = perl_run("build_target.pl $targ cleanexport");
	if ($rc) {
		print "*** Failed to clean exports for target $targ ***\n";
		if ($keepgoing) {
			push(@failed,$targ);
		} else {
			exit $rc;
		}
	} else { 
		print ">>> Exporting target $targ\n";
		my $rc = perl_run("build_target.pl $targ export");
		if ($rc) {
			print "*** Failed to export target $targ ***\n";
			if ($keepgoing) {
				push(@failed,$targ);
			} else {
				exit $rc;
			}
		} else { 
			push(@exported,$targ);
		}
	}
}

sub is_exported($)
{
	my $targ = shift;
	return grep(/$targ/,@exported) != 0;
}

if (@ARGV) {
    if (grep(/$ARGV[0]/,("-h","--help"))) {
        print "This script performs all necessary exports from the targets under the sbsv1 directory " .
			"to fix up the exports to epoc32/tools.";
        print "Valid arguments are -h, --help; -k, --keepgoing, or none.\n";
		print "-k, --keepgoing makes the script carry on after a failed export,\n";
		exit 0;  
	} elsif (grep(/$ARGV[0]/,("-k","--keepgoing"))) {
		$keepgoing = 1;
	} else {
	    print "Valid arguments are -h, --help; -k, --keepgoing, or none.\n".
        exit 1;
    }         
}
my $epocroot = get_epocroot();
my @targ_lines = perl_slurp("list_targets.pl");
open DEPS,"<deps.txt" or die $!;
my @deps = <DEPS>;
close DEPS;
while (@deps and $deps[0] =~ /^\s*#/) {
	shift @deps;
}
foreach my $dep (@deps) {
	chomp $dep;
}
foreach my $line (@targ_lines) {
	chomp $line;
	my $re_line = $line;
	if (os_is_windows()) {
	   $re_line =~ s/\\/\//g;
    } 
    next, if ($line =~ /(\*\*\*.*\*\*\*)/);
 	next, if ($line =~ /^>>>/);   
	next, unless (grep(/^$re_line$/,(@needed_exports)));	
	export($line);
}
if (@exported) {
	if (@failed == 0) {
		print ">>> Exported all eligible targets:-\n";
	} else {
		print ">>> Exported eligible targets:-\n";
	}
	foreach my $targ (@exported) {
		print "+++ $targ\n";
	}
}
if (@failed) {
	print ">>> Failed to export eligible targets:-\n";
	foreach my $targ (@failed) {
		print "+++ $targ\n";
	}
} 
exit 0;

