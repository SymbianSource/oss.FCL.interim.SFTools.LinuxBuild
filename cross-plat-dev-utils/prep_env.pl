#!/usr/bin/perl

# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org for Symbian Foundation Ltd - initial contribution.

# Script to make any necessary patches to the host environment.

use strict;
use usage;
use perl_run;

usage(\@ARGV,"This script makes all required fixes to the Linux host environment");
perl_run("fix_epoc32.pl") and die $!;
perl_run("fix_raptor_config.pl") and die $!;
exit 0;
