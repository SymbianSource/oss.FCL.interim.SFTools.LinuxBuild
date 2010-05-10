#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Script to build a given tools target with Raptor
# Will look for BLD.INF or bld.inf in the current directory.
# If not found will try in ./group.
# $1 is the build dir for the desired target relative to $EPOCROOT/build/
# $@ is shifted to get optional additional arguments to the sbs command

use strict;
use set_epocroot;
use File::Spec;
use Cwd; 

if (@ARGV) {
    if (grep(/$ARGV[0]/,("-h","--help"))) {
        print "This script builds a target with Raptor\n";
        print "Call with \$ARG[0] = the name of a component directory ";
        print "relative to EPOCROOT/build\n";        
        print "Subsequent arguments will be passed to Raptor\n";
        print "Looks for BLD.INF or bld.inf in the component directory\n";
        print "In not found will try in ./group\n";                        
        exit 0;
    }         
}
set_epocroot();
my $epocroot = $ENV{'EPOCROOT'};
my $sbs_home = $ENV{'SBS_HOME'};
unless($sbs_home) {
    $sbs_home = File::Spec->catfile("$epocroot","build","sbsv2","raptor");
    $ENV{'SBS_HOME'} = $sbs_home;
}
my $build_dir = shift;
$build_dir = File::Spec->catfile("$epocroot","build","$build_dir");
if (! -d $build_dir) {
    die "*** Error: \"$build_dir\" not found ***\n";
}
chdir "$build_dir" or die $!;
if (! -f "BLD.INF" and ! -f "bld.inf") {
	if ( -d "group") {
		chdir "group" or die $!;
		$build_dir = cwd;
	}
}
print ">>> Build dir is \"$build_dir\"\n";
my $bld_inf = "BLD.INF"; 
if (! -f $bld_inf) {
	$bld_inf = "bld.inf";
}
if (! -f $bld_inf) {
	die "*** Error: No bld.inf in \"$build_dir\" ***";
}
my $log_stem = File::Spec->catfile("$epocroot","epoc32","build","Makefile");
my $log_pattern = "$log_stem\.\*\.log"; 
my $raptor = File::Spec->catfile("$sbs_home","bin","sbs");
my $cmd = "$raptor -c tools2 -b $bld_inf @ARGV";
print ">>> Executing: $cmd\n";
my $rc = system($cmd) >> 8;
my @build_logs = glob($log_pattern);
open BLDLOG, "<$build_logs[-1]" or die $!;
while(<BLDLOG>) {
    print $_;
}
close BLDLOG;
exit $rc;


