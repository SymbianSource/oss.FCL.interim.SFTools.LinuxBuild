#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Subroutines to get Raptor's value of HOSTPLATFORM_DIR

use strict;
use File::Spec;

sub get_hostplatform_dir()
{
	my $any_old_targ = File::Spec->catfile("buildtoolguides","romtoolsguide");
	my $build_log = perl_slurp("build_target.pl $any_old_targ --what 2> ". File::Spec->devnull());
	$build_log =~ /<info>Environment HOSTPLATFORM_DIR=(\S*)<\/info>/;
	my $host_platform_dir = $1;
	die "*** Error: Can't determine HOSTPLATFORM_DIR ***", unless ($host_platform_dir);
	return $host_platform_dir;
}

1;


