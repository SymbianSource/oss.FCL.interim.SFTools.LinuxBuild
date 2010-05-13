#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Script to build all tools2 targets with Raptor, except Raptor itself
# and any that were broken upstream when last checked.

use strict;
use perl_run;
use places;
use check_os;
my $keepgoing = 0;
my @built = ();
my @failed = ();
my @skipped = ();

sub build($)
{
	my $targ = shift;
	return, if (is_built($targ));
	print ">>> Building target $targ\n";
	my $rc = perl_run("build_target.pl $targ");
	if ($rc) {
		print "*** Failed to build target $targ ***\n";
		if ($keepgoing) {
			push(@failed,$targ);
		} else {
			exit $rc;
		}
	} else { 
		push(@built,$targ);
	}
}

sub is_built($)
{
	my $targ = shift;
	return grep(/$targ/,@built) != 0;
}

if (@ARGV) {
    if (grep(/$ARGV[0]/,("-h","--help"))) {
        print "This script cleans all TOOLS2 targets with Raptor, " .
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
my $start_time = time();
foreach my $line (@targ_lines) {
	chomp $line;
	next, if ($line =~ /^>>>/);
	if ($line =~ /(\*\*\*.*\*\*\*)/) {
		my $reason = $1;
		my @words = split(/ /,$line);
		print ">>> Skipping target $words[0]: \"$reason\"\n";
		push (@skipped,[$words[0],$reason]);
	} else {
		foreach my $dep (@deps) {
			my ($targ,$prereq) = split(/ /,$dep);
			if (os_is_windows()) {
                $targ =~ s/\./\\/g;
                $prereq =~ s/\./\\/g;                
            } else {
                $targ =~ s/\./\//g;
                $prereq =~ s/\./\//g;                            
            }
			next, unless ($targ eq $line);
			build($prereq);
		}
		build($line);
	}
}
if (@built) {
	if (@failed == 0) {
		print ">>> Built all eligible targets:-\n";
	} else {
		print ">>> Built eligible targets:-\n";
	}
	foreach my $targ (@built) {
		print "+++ $targ\n";
	}
}
if (@failed) {
	print ">>> Failed to build eligible targets:-\n";
	foreach my $targ (@failed) {
		print "+++ $targ\n";
	}
} 
if (@skipped) {
	print ">>> Skipped targets:-\n";
	foreach my $skipped (@skipped) {
		print "+++ " . $skipped->[0] . ' ' . $skipped->[1] . "\n";
	}
}
my $end_time = time();
use integer;
my $elapsed_time = $end_time - $start_time;
my $hours = $elapsed_time / 3600;
$elapsed_time -= ($hours * 3600);
my $mins = $elapsed_time / 60;
my $secs = ($elapsed_time - ($mins * 60));
print ">>> Runtime ";
print "$hours hrs ", if ($hours);
print "$mins mins $secs secs\n";
exit 0;

