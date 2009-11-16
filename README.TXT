# Copyright (c) 2009 Symbian Foundation Ltd
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Symbian Foundation Ltd - initial contribution.
# Mike Kinghan, mikek@symbian.org
#
# Contributors:
#
# Description:
# This is readme file for a building the Symbian build tools
# by conventional GNU/Linux means.

To use this package, first clone the Symbian build tools
repository from //http://developer.symbian.org/oss/MCL/sftools/dev/build. To be
sure of getting the latest sources with which this package has been tested,
clone the repository at changeset number be27ed110b50, i.e.

$ hg clone -r be27ed110b50 http://developer.symbian.org/oss/MCL/sftools/dev/build

I assume you clone the repository at ~/somewhere/sftools/dev/build.

Then from the directory containing this file, copy the Makefile and the directory
'makefiles-garage' into ~/somewhere/sftools/dev/build.

Then:

$ cd ~/somewhere/sftools/dev/build
$ make help

Study the help, then:

$ make

This package is work in progress. Right now, it only makes a subset of the
tools libraries and executables. It does make any tools exports or any kind of install.

# EOF

