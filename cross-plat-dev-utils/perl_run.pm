#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Subroutines to call a perl script in the current directory.

use strict;

# Run the perl script and return its return code.
sub perl_run($)
{
	my $cmd = shift;
	return system("perl $cmd") >> 8; 
}

# Run the perl script and return its stdout.
sub perl_slurp($)
{
	my $cmd = shift;
	return `perl $cmd`; 
}

1;

