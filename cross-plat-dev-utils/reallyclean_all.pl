#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Script to clean all tools2 targets with Raptor, except Raptor itself
# and any that were broken upstream when last checked.

use strict;
use perl_run;
my $keepgoing = 0;
my @cleaned = ();
my @uncleaned = ();
my @skipped = ();

if (@ARGV) {
    if (grep(/$ARGV[0]/,("-h","--help"))) {
        print "This script really-cleans all TOOLS2 targets with Raptor, " .
			"except Raptor itself and any that were broken upstream when last checked.\n";
        print "Valid arguments are -h, --help; -k, --keepgoing, or none.\n";
		print "-k, --keepgoing makes the script carry on after a failed clean,\n";
		exit 0;  
	} elsif (grep(/$ARGV[0]/,("-k","--keepgoing"))) {
		$keepgoing = 1;
	} else {
	    print "Valid arguments are -h, --help; -k, --keepgoing, or none.\n".
        exit 1;
    }         
}
my @targ_lines = perl_slurp("list_targets.pl");
foreach my $line (@targ_lines) {
	chomp $line;
	next, if ($line =~ /^>>>/);
	if ($line =~ /(\*\*\*.*\*\*\*)/) {
		my $reason = $1;
		my @words = split(/ /,$line);
		print ">>> Skipping target $words[0]: \"$reason\"\n";
		push (@skipped,[$words[0],$reason]);
	} else {
		print ">>> Really-cleaning target $line\n";
		my $rc = perl_run("reallyclean_target.pl $line");
		if ($rc) {
			print "*** $rc ***\n";
			print "*** Failed to really-clean target $line ***\n";
			if ($keepgoing) {
				push(@uncleaned,$line);
			} else {
				exit $rc;
			}
		} else {
			push(@cleaned,$line);
		}
	}
}
if (@cleaned) {
	if (@uncleaned == 0) {
		print ">>> Really-cleaned all eligible targets:-\n";
	} else {
		print ">>> Really-cleaned eligible targets:-\n";
	}
	foreach my $targ (@cleaned) {
		print "+++ $targ\n";
	}
}
if (@uncleaned) {
	print ">>> Failed to really-clean eligible targets:-\n";
	foreach my $targ (@uncleaned) {
		print "+++ $targ\n";
	}
} 
if (@skipped) {
	print ">>> Skipped targets:-\n";
	foreach my $skipped (@skipped) {
		print "+++ " . $skipped->[0] . ' '. $skipped->[1] . "\n";
	}
}   
exit 0;

