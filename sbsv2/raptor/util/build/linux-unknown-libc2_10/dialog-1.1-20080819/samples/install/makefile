# $Id: makefile.in,v 1.1 2000/10/08 17:22:53 tom Exp $
# template makefile for DIALOG sample 'install'
#
SHELL		= /bin/sh

prefix		= /home/imk/symbian/epocroot-pdk-3.0.h/build/sbsv2/raptor/linux-unknown-libc2_10
exec_prefix	= ${prefix}

srcdir		= .
top_builddir	= ../..

DESTDIR		=
bindir		= $(DESTDIR)${exec_prefix}/bin

CFLAGS		= -O3 -mtune=i686 -s
CPPFLAGS	=  -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64  -DHAVE_CONFIG_H -I$(top_builddir) -I$(srcdir)/../.. -I. -I$(srcdir)
EXTRA_CFLAGS	= 
CC		= gcc
LDFLAGS		= 
LIBS		= -L../.. -ldialog -lncurses  -lm -L/lib
RANLIB		= ranlib

RM		= rm -f

all: setup

setup: setup.o
	$(CC) -o $@ setup.o $(LIBS)

clean:
	rm -f *.o setup

test: setup
	./setup

