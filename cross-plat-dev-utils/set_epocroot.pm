#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Routine to set EPOCROOT if not defined; is set to fully qualified name of ../..

use strict;
use Cwd;
sub set_epocroot()
{
    if (!$ENV{'EPOCROOT'}) {
        print ">>> EPOCROOT not defined. Assuming ../..\n";
        my $cwd = getcwd;
        chdir "../..";
    	print ">>> EPOCROOT=",getcwd,"\n";
    	$ENV{'EPOCROOT'}=getcwd;
    	chdir $cwd;
    }
}

1;

