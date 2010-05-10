#!/usr/bin/perl
# Copyright (c) 2010 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation Ltd - initial contribution.
 
# Script to clean a given tools target with Raptor
# Will look for BLD.INF or bld.inf in the current directory.
# If not found will try in ./group.
# $1 is the build dir for the desired target relative to $EPOCROOT/build/

use perl_run;
 
if (@ARGV) {
    if (grep(/$ARGV[0]/,("-h","--help"))) {
        print "This script really-cleans a target with Raptor\n";
        print "Call with \$ARG[0] = the name of a component directory ";
        print "relative to EPOCROOT/build\n";        
        print "Looks for BLD.INF or bld.inf in the component directory\n";
        print "In not found will try in ./group\n";                        
        exit 0;
    }         
}
exit perl_run("build_target.pl @ARGV REALLYCLEAN");
