#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org for Symbian Foundation Ltd - initial contribution.

# Script to build Raptor (sbsv2)

use strict;
use File::Spec;
use set_epocroot;

if (@ARGV) {
    if (grep(/$ARGV[0]/,("-h","--help"))) {
        print "This script builds Raptor\n";
        print "It needs no arguments\n";
		exit 0;        
    }
	if (@ARGV > 1 or @ARGV[0] !~ /^clean$/i) {
        print "Valid arguments are -h, --help, clean\n";
        exit 1;
    }
}
set_epocroot();
my $epocroot = $ENV{'EPOCROOT'};
my $sbs_home = File::Spec->catfile("$epocroot","build","sbsv2","raptor");
$ENV{'SBS_HOME'} = $sbs_home;
my $cmd = "make -C $sbs_home/util @ARGV";
print "Executing: $cmd\n";
system($cmd) and die $!;
exit 0;

