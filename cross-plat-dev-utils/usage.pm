#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Subroutine to emit a help message for a script when it is passed
# -h or --help.

use strict;

sub usage(@)
{
	my ($argv_ref,@usage_lines) = @_;
	if (@{$argv_ref}) {
		if (grep(/$argv_ref->[0]/,("-h","--help"))) {
			foreach my $line (@usage_lines) {
				print "$line\n";
			}
			print "Needs no arguments\n";
			exit 0;
		}
		print "Valid arguments are -h, --help, or none\n";
		exit 1;
	}
}

1;

