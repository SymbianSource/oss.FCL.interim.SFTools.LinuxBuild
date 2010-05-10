#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.

# Subroutines to check the host OS.

use strict;

sub check_os($)
{
	my $osname = shift;
	return ($^O =~ /^$osname/) ? 1 : 0;
}

sub os_is_windows()
{
	return check_os("MSWin");
}

sub os_is_linux()
{
	return check_os("linux");
}

sub require_os_windows()
{
	unless(os_is_windows()) {
		die ("*** Windows host required ***");
	}
}

sub require_os_linux()
{
	unless(os_is_linux()) {
		die ("*** Linux host required ***");
	}
}


1;

