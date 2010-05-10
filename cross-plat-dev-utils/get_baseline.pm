#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Subroutine to get the mercurial revision from which this package was branched
# from the file ../baseline.txt

use strict;
use File::Spec;
use set_epocroot;

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub get_baseline()
{
	set_epocroot();
	my $epocroot = $ENV{'EPOCROOT'};
	my $baseline_txt = File::Spec->catfile("$epocroot","build","baseline.txt");
	open IN,"<$baseline_txt" or die $!;
	my @lines = <IN>;
	close IN;
	while(@lines and $lines[0] =~ /^\s*#/) {
		shift @lines;
	}
	die "*** Error: can't extract baseline revsion no. from ../baseline.txt ***",
		unless(@lines);
	return trim($lines[0]);
}

1;


