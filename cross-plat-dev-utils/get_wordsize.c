/*
Copyright (c) 2010 Symbian Foundation Ltd
This component and the accompanying materials are made available
under the terms of the License "Eclipse Public License v1.0"
which accompanies this distribution, and is available
at the URL "http://www.eclipse.org/legal/epl-v10.html".

Initial Contributors:
Mike Kinghan, mikek@symbian.org for Symbian Foundation Ltd - initial contribution.

Program to return the wordsize in bits of the host machine
*/

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
	printf("%lu\n",sizeof(unsigned long));
	exit(0);
}

