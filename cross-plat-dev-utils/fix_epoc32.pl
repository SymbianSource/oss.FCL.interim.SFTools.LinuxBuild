#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org for Symbian Foundation Ltd - initial contribution.

# Script to patch the epoc32 tree as required.

use strict;
use check_os;
use perl_run;

if (os_is_windows()) {
	exit perl_run("fix_epoc32_win.pl @ARGV");
}
if (os_is_linux()) {
	exit perl_run("fix_epoc32_linux.pl @ARGV");
}
die "*** Unsupported OS $^O ***";

