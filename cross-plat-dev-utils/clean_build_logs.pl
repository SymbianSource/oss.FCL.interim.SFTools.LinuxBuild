#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Script to delete any Raptor build logs from
# $EPOCROOT/epoc32/build

use strict;
use usage;
use set_epocroot;
use File::Spec;
use Cwd; 

usage(\@ARGV,"This script deletes all Raptor build logs");
set_epocroot();
my $epocroot = $ENV{'EPOCROOT'};
my $log_stem = File::Spec->catfile("$epocroot","epoc32","build","Makefile");
my $log_pattern = "$log_stem\.\*\.log"; 
my @old_logs = glob($log_pattern);
if (@old_logs) {
    print ">>> Deleting Raptor build logs\n";
    unlink @old_logs;
}
exit 0;

