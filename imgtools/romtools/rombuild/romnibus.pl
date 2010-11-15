#!/usr/bin/perl
#
# Copyright (c) 2009 Nokia Corporation and/or its subsidiary(-ies).
# All rights reserved.
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Nokia Corporation - initial contribution.
#
# Contributors:
# Mike Kinghan, mikek@symbian.org, for Symbian Foundation
#
# Description:
#
# romnibus.pl - Yet another rombuild wrapper. This one's claim to fame is that
# it works in Linux and in Windows, works when invoked from sbsv2 and when
# not invoked from sbsv2.
#
# Pre-processes the .oby/iby files then invokes rombuild.exe
# (or other specified builder)

# First, read our config file

use strict;
use Getopt::Long;
use Cwd;
use Cwd 'abs_path';
use File::Spec;

my $on_windows;
my $epocroot_vol;
my $epocroot_dir;
my $epocroot_file;
my %dir_listings = ();	
my %opts=();
my $param_count = scalar(@ARGV);
my (@assps, @builds, %variants, @templates, %flags, %insts, %zip, %builder);
my $main;
my $kmain;
my $toroot;
my $e32path;
my $rombuildpath;
my $euserdir;
my $elocldir;
my $kbdir;
my $romname;
my $single;
my $smain;
my $pagedCode;
my $debug;
my $quiet;
my $toolpath;
my $epoc32path;
my $epocroot;
my $lc_epocroot;
my $drive = "";
my $base_path;
my $line;
sub Variant_GetMacroHRHFile;
sub is_RVCT_build($);
sub parse_cfg;
sub ASSPS;
sub BUILDS;
sub TEMPLATES;
sub usage;
sub rectify($$$);
sub match_abbrev($$);
sub check_opts;
sub lookup_file_info($$);
sub lookupSymbolInfo($$);
sub parse_patch_data($$);
sub gen_file;
sub nix_fixes {
#	Fix case-sensitivity offenders for unix/linux environment.
	my $e32plat_pm = File::Spec->catfile($toolpath,"e32plat.pm");
	my $armutl_pm = File::Spec->catfile($toolpath,"armutl.pm");
	my $bpabiutl_pm = File::Spec->catfile($toolpath,"bpabiutl.pm");
	my $e32variant_pm = File::Spec->catfile($toolpath,"e32variant.pm");
	my $E32Plat_pm = File::Spec->catfile($toolpath,"E32Plat.pm");
	my $Armutl_pm = File::Spec->catfile($toolpath,"Armutl.pm");
	my $BPABIutl_pm = File::Spec->catfile($toolpath,"BPABIutl.pm");
	my $E32Variant_pm = File::Spec->catfile($toolpath,"E32Variant.pm");
	# Create symlinks for case-sensitively misnamed modules we need.
	unless ( -f $E32Plat_pm or -l $E32Plat_pm) {
		symlink($e32plat_pm,$E32Plat_pm);
	}
	unless ( -f $Armutl_pm or -l $Armutl_pm) {
		symlink($armutl_pm,$Armutl_pm);
	}
	unless ( -f $BPABIutl_pm or -l $BPABIutl_pm) {
		symlink($bpabiutl_pm,$BPABIutl_pm);
	}
	unless ( -f $E32Variant_pm or -l $E32Variant_pm) {
		symlink($e32variant_pm,$E32Variant_pm);
	}
	# Make uppercase symlinks to all .bsf files in /epoc32/tools
	my @bsf_files = glob(File::Spec->catfile($toolpath,"*.bsf"));
	foreach my $bsf_file (@bsf_files) {
		my ($vol,$dirs,$file) = File::Spec->splitpath($bsf_file);
		$file =~ /^(\S+)\.bsf/;
		my $uc_stem = uc($1);
		my $uc_bsf_file = File::Spec->catpath($vol,$dirs,($uc_stem .".bsf"));
		unless ( -f $uc_bsf_file or -l $uc_bsf_file ) {
			symlink($bsf_file,$uc_bsf_file) or die "Can't symlink $bsf_file -> $uc_bsf_file. $!";
		}
	}
}


BEGIN {
	$on_windows = $^O =~ /^MSWin/ ? 1 : 0;
	$epocroot = $ENV{EPOCROOT};
	die "ERROR: Must set the EPOCROOT environment variable.\n" if (!defined($epocroot));
	print "Environmental epocroot - >$epocroot<\n";
	$epocroot =~ s/:$/:\//, if $on_windows;
	$epocroot = abs_path($epocroot);
	die "ERROR: EPOCROOT must specify an existing directory.\n" if (!-d $epocroot);
	($epocroot_vol,$epocroot_dir,$epocroot_file) = File::Spec->splitpath($epocroot);
	$epocroot = File::Spec->catfile(($epocroot_vol,$epocroot_dir,$epocroot_file),undef);
	print "EPOCROOT=$ENV{EPOCROOT} resolved as \"$epocroot\"\n";
	$lc_epocroot = lc($epocroot);
	$epoc32path = File::Spec->catfile($epocroot,"epoc32");
	$toolpath = File::Spec->catfile($epoc32path,"tools");
	push @INC, $toolpath;
	nix_fixes(), unless ($on_windows);
}


my $result = GetOptions (\%opts, "assp=s",
						 "inst=s",
						 "type=s",
						 "variant=s",
						 "build=s", 
						 "conf=s",
						 "name=s",
						 "modules=s",
						 "xabi=s",
						 "clean",
						 "quiet",
						 "help",
						 "debug",
						 "zip",
						 "symbol",
						 "noheader",
						 "kerneltrace=s",
						 "rombuilder=s",
						 "define=s@",
						 "rofsbuilder=s",
						 "compress",
						 );

$debug = $opts{debug};
$quiet = $opts{quiet} unless $debug;

my $cwd = Cwd::cwd();
my ($vol,$dirs,$file) = File::Spec->splitpath($cwd);
$drive = $vol, if ($on_windows);
my @path_parts = File::Spec->splitdir($dirs);
while(@path_parts[-1] ne "sf") {
	pop(@path_parts);
}
$base_path = File::Spec->catdir((@path_parts,"os"));
$base_path = "$drive$base_path", if ($on_windows);
$rombuildpath = File::Spec->catfile($base_path,"kernelhwsrv","kernel","eka","rombuild");
$base_path .= ($on_windows ? '\\' : '/');  
$e32path = ($on_windows ? "\\sf\\os" : "/sf/os"); 

use E32Plat;
{
        Plat_Init($toolpath . ($on_windows ? '\\' : '/'));
}

if ($debug) {
	print "epocroot = $epocroot\n";
	print "epoc32path = $epoc32path\n";
	print "drive = $drive\n";
	print "toolpath = $toolpath\n";
	print "toroot = $toroot\n";
	print "e32path = $e32path\n";
	print "rombuildpath = $rombuildpath\n";
	print "base_path = $base_path\n";
}

#my $cppflags="-P -undef -Wno-endif-labels -traditional -lang-c++ -nostdinc -iwithprefixbefore $rombuildpath -I $rombuildpath -I $drive$epoc32path ";
my $cppflags="-P -undef -Wno-endif-labels -traditional -lang-c++ -nostdinc -I $rombuildpath -I $epoc32path ";

# Include variant hrh file defines when processing oby and ibys with cpp
# (Code copied from \\EPOC\master\cedar\generic\tools\romkit\tools\buildrom.pm -
# it used relative path to the working dir but we are using absolute path seems neater)

my $variantMacroHRHFile = Variant_GetMacroHRHFile();
if($variantMacroHRHFile){
	my ($ignore1,$dir,$file) = File::Spec->splitpath($variantMacroHRHFile);
	$cppflags .= " -I " . File::Spec->catpath($epocroot_vol,$dir,undef) . " -include " . File::Spec->catpath($epocroot_vol,$dir,$file); 
}

if($param_count == 0 || $opts{'help'} || !$result) {
	usage();
	exit 0;
}

# Now check that the options we have make sense

checkopts();

if (!$quiet) {
	print "Starting directory: ", Cwd::cwd(), "\n";
	print <<EOF;
OPTIONS:
\tTYPE: $opts{'type'}
\tVARIANT: $opts{'variant'}
\tINSTRUCTION SET: $opts{'inst'}
\tBUILD: $opts{'build'}
\tMODULES: $opts{'modules'}
EOF
}

#Pick out the type file
my $skel = "$opts{'type'}.oby";
unless (-e $skel) {
	$skel= File::Spec->catfile($rombuildpath,"$opts{'type'}.oby");
}
unless (-e $skel) {
	die "Can't find type file for type $opts{'type'}, $!";
}

print "Using type file $skel\n" if !$quiet;

# If clean is specified, zap all the image and .oby files

if($opts{'clean'}) {
	unlink glob("*.img");
	unlink "rom.oby";
	unlink "rombuild.log";
	unlink glob("*.rofs");
	unlink "rofsbuild.log";
}

# Now pre-pre-process this file to point to the right places for .ibys
# Unfortunately cpp won't do macro replacement in #include strings, so
# we have to do it by hand

my $k = $opts{kerneltrace};

if ($opts{assp}=~/^m(\S+)/i) {
	$kbdir="kb$1";
	$kbdir="kbarm" if (lc $1 eq 'eig');
} else {
	$kbdir="kb$opts{assp}";
}
$single=1 if ($opts{assp}=~/^s(\S+)/i);

if ($single) {
	# Hackery to cope with old compiler
	if ($main eq 'MARM') {
		$smain='SARM';
	} else {
		$smain="S$main";
	}
} else {
	$smain=$main;
}

unless ($on_windows) {
	$main = lc($main);
	$kmain = lc($kmain);
}


open(X, "$skel") || die "Can't open type file $skel, $!";
open(OUT, "> rom1.tmp") || die "Can't open output file, $!";

# First output the ROM name
print OUT "\nromname=$romname\n";
while(<X>) {
	s/\#\#ASSP\#\#/$opts{'assp'}/;
	s/\#\#VARIANT\#\#/$opts{'variant'}/;
	s/\#\#BUILD\#\#/$opts{'build'}/;
	s/\#\#MAIN\#\#/$main/;
	s/\#\#KMAIN\#\#/$kmain/;
	s/\#\#E32PATH\#\#/$e32path/;
	s/\#\#BASEPATH\#\#/$base_path/;
	s/\#\#EUSERDIR\#\#/$euserdir/;
	s/\#\#ELOCLDIR\#\#/$elocldir/;
	s/\#\#KBDIR\#\#/$kbdir/;
	unless ($on_windows) {
		if (m/#include/) {
			s|\\|\/|g;
			lc;
		}
	}
	print OUT;
}

close X;
close OUT;

# Use cpp to pull in include chains and replace defines

my $defines = "";
$defines .= "-D MAIN=$main ";
$defines .= "-D KMAIN=$kmain ";
$defines .= "-D EUSERDIR=$euserdir ";
$defines .= "-D ELOCLDIR=$elocldir ";
$defines .= "-D E32PATH=$e32path ";
$defines .= "-D BASEPATH=$base_path ";
$defines .= "-D EPOCROOT=$epocroot ";
$defines .= "-D SMAIN=$smain " if $smain;

foreach (@{$opts{'define'}}) {
	my @array=split(/,/,$_);
	foreach (@array) {
		$defines.="-D ".uc $_." ";
		$pagedCode = 1 if $_ eq 'PAGED_CODE';
		}
	}

if ($opts{'modules'}) {
	my @array=split(/,/,$opts{'modules'});
	foreach (@array) {
		$defines.="-D ".uc $_." ";
		}
	}

foreach (keys %opts) {
	next if ($_ eq 'name');
	next if ($_ eq 'modules');
	next if ($_ eq 'zip');
	next if ($_ eq 'symbol');
	next if ($_ eq 'kerneltrace');
	next if ($_ eq 'define');
	$defines.="-D ".uc $_."=".$opts{$_}." ";
	$defines.="-D ".uc $_."_".$opts{$_}." ";
}

$defines.="-D SINGLE " if ($single);
$defines.="-D RVCT " if (IsRVCTBuild($main));

print "Using defines $defines\n" if !$quiet;

my $ret=1;
my $cppcmd;
if($opts{'build'}=~/^u/i and $on_windows) {
	# Unicode build
	$cppcmd = File::Spec->catfile($epoc32path,"gcc","bin","cpp") . " $cppflags -D UNICODE $defines rom1.tmp rom2.tmp";
} else {
	$cppcmd = "cpp $cppflags $defines rom1.tmp rom2.tmp";
}
print "Executing CPP:\n\t$cppcmd\n" if $debug;
$ret = system($cppcmd);
die "ERROR EXECUTING CPP\n" if $ret;

# Purge remarks and blank lines. Complete source filenames and adapt them to host filesystem.
rectify("rom2.tmp", "rom3.tmp", $k);

# scan tmp file and generate auxiliary files, if required
open TMP, "rom3.tmp" or die("Can't open rom3.tmp\n");
while ($line=<TMP>)
	{
	if ($line=~/\s*gentestpaged/i) {
		genfile("paged");	}
	if ($line=~/\s*gentestnonpaged/i) {
		genfile("nonpaged");	}
	}

parsePatchData("rom3.tmp", "rom4.tmp");

# break down the oby file into rom, rofs and extensions oby files

my $oby_index =0;
my $dumpfile="rom.oby";
my $rofs=0;
my $extension=0;
my $corerofsname="";
open DUMPFILE, ">$dumpfile" or die("Can't create $dumpfile\n");
open TMP, "rom4.tmp" or die("Can't open rom4.tmp\n");
while ($line=<TMP>)
	{
	if ($line=~/^\s*rofsname/i)
		{
		close DUMPFILE;							# close rom.oby or previous rofs#/extension#.oby
		$oby_index=1;
		$corerofsname=$line;
		$corerofsname =~ s/rofsname\s*=\s*//i;		# save core rofs name
		chomp($corerofsname);
		unlink $corerofsname || print "unable to delete $corerofsname";
		my $dumpfile="rofs".$rofs.".oby";
		$rofs++;
		open DUMPFILE, ">$dumpfile" or (close TMP and die("Can't create $dumpfile\n"));
		}

	if ($line=~/^\s*coreimage/i)
		{
		close DUMPFILE;							# close rofs.oby
		if ($oby_index ne 1) {
			close TMP;
			die "Must specify ROFS image before ROFS extension\n";
		}
		my $name=$line;
		$name =~ s/coreimage\s*=\s*//i;		# read core rofs name
		chomp($name); 			# remove trailing \n
		if ($name ne $corerofsname) {
			close TMP;
			die "This extension does not relate to previous ROFS\n";
		}
		$oby_index=33;						# open window
		my $dumpfile="extension".$extension.".oby";
		$extension++;
		open DUMPFILE, ">$dumpfile" or (close TMP and die("Can't create $dumpfile\n"));
		}

	if ($line=~/^\s*extensionrofs/i)
		{
		$oby_index=3 if ($oby_index eq 2);
		}

	if (($oby_index eq 2) && !($line=~/^\s*$/)) {
		close TMP;
		die "Bad ROFS extension specification\n";
	}
	print DUMPFILE $line;
	$oby_index=2 if ($oby_index eq 33);		# close window
	}
close DUMPFILE;
close TMP;

# For paged roms that use rofs, move all data= lines in rom which are not 'paging_unmovable' to rofs, so that paged ram-loaded code
# is automatically put into rofs
rename('rom.oby', 'rom4.tmp') || die;

open(IN, 'rom4.tmp') || die "Can't read rom4.tmp";
open(ROM, '>rom.oby') || die "Can't write to rom.oby";

if ($oby_index >= 1 && $pagedCode)	{
	open(ROFS, '>>rofs0.oby') || die "Can't append to rofs0.oby";
}

while ($line=<IN>)
{
	if(($oby_index >= 1) && ($pagedCode) && ($line=~/^\s*data\s*=/) && !($line=~/\.*paging_unmovable\s*/)) {
		print ROFS $line;
	}
	else {
		$line=~s/paging_unmovable//;
		print ROM $line;
	}
}

close IN;
close ROM;

if ($oby_index >= 1 && $pagedCode)	{
	close ROFS;
}
	unlink 'rom4.tmp';

my $flags;

foreach (@{$flags{$opts{'assp'}}}) {
	$flags.=" -$_";
}

if($opts{'noheader'}) {
	$flags.=" -no-header";
}

if($opts{'compress'}) {
	$flags.=" -compress";
}

my $builder = $opts{'rombuilder'};
if ($on_windows) {
	$builder = File::Spec->catfile($toolpath,"rombuild.exe") unless ($builder);
}
else {
	$builder = File::Spec->catfile($toolpath,"rombuild") unless ($builder);
	unless ( -x $builder ) {
		chmod 0755,$builder;
	}
}

print "$builder $flags -type-safe-link -S rom.oby 2>&1\n\n";

open(Y, "$builder $flags -type-safe-link -S rom.oby 2>&1 | ") || 
	die "Can't start $builder command, $!";

my $nerrors=0;
my $nwarnings=0;

while(<Y>) {
	my $error=(/^error:/i);
	my $warning=(/^warning:/i);
	print if ($error or $warning or !$quiet);
	$nerrors++ if ($error);
	$nwarnings++ if ($warning);
}

print "\nGenerated .oby file is rom.oby\n" if !$quiet;
print "\nGenerated image file is $romname\n" if (!$nerrors);

my$rerrors;
my $rofsbuilder;
if ($rofs) {
	$rofsbuilder = $opts{'rofsbuilder'};
	$rofsbuilder = "rofsbuild" unless ($rofsbuilder);
	for(my $i=0;$i<$rofs;++$i) {
		print "Executing $rofsbuilder on main rofs\n" if !$quiet;
		my $image="rofs".$i.".oby";
		system("$rofsbuilder $image");
		if ($? != 0)
			{
			print "$rofsbuilder $image returned $?\n";
			$rerrors++;
			}
		rename "rofsbuild.log", "rofs$i.log"
		}
}

if ($rofs and $extension) {
	for(my $i=0;$i<$extension;++$i) {
		print "Executing $rofsbuilder on extension rofs\n" if !$quiet;
		my $image="extension".$i.".oby";
		system("$rofsbuilder $image");
		if ($? != 0)
			{
			print "$rofsbuilder $image returned $?\n";
			$rerrors++;
			}
		rename "rofsbuild.log", "extension$i.log"
		}
}

if ($nerrors) {
	print "\n\n Errors found during $builder!!\n\nLeaving tmp files\n";
} elsif ($nwarnings) {
	print "\n\n Warnings during $builder!!\n\nLeaving tmp files\n";
} elsif ($rerrors) {
	print "\n\n Errors during $rofsbuilder!!\n\nLeaving tmp files\n";
} else {
	unlink glob("*.tmp") if !$debug;
}
if ($opts{zip} or $zip{$opts{assp}}) {
	my $zipname=$romname;
	$zipname =~ s/\.(\w+)$/\.zip/i;
	unlink $zipname;
	system("zip $zipname $romname");
}
if ($opts{symbol}) {
	my $logname=$romname;
	$logname =~ s/\.(\w+)$/\.log/i;
	my $obyname=$romname;
	$obyname =~ s/\.(\w+)$/\.oby/i;
	unlink $logname;
	unlink $obyname;
	system("rename rombuild.log $logname");
	system("rename rom.oby $obyname");
	system("maksym $logname");
}

#IMK if ($nerrors || $nwarnings || $rerrors) {
#IMK	exit 4;
#IMK}	
if ($nerrors || $rerrors) {
	exit 4;
}	

	
exit 0;


################################ Subroutines  ##################################

sub usage {
	print <<EOT;

rom <options>

Generate a rom image for the specified target, along with a rom.oby file
that can be fed to (a) rombuild to regenerate the image.

The following options are required:
  --variant=<variant>         e.g. --variant=assabet
  --inst=<instruction set>    e.g. --inst=arm4
  --build=<build>             e.g. --build=udeb
  --type=<type of rom>  
         tshell for a text shell rom
         e32tests for a rom with e32tests
         f32tests for rom with f32tests
         alltests for all the tests

The following are optional:
  --name=<image name>               Give image file specified name
  --noheader                        Pass -no-header option on to rombuild
  --help                            This help message.
  --clean                           Remove existing generated files first
  --quiet                           Be less verbose
  --modules=<comma separated list>  List of additional modules for this ROM
  --define=<comma separated list>   List of CPP macros to define

Options may be specified as a short abbreviation 
e.g. -b udeb instead of --build udeb

EOT
}

sub rectify($$$) {
	my ($in, $out, $k) = @_;
	my $lastblank;
	my $lineno = 0;
	my $epocroot_pattern = $on_windows ? $epocroot . '\\\\' : $epocroot;

	open(OUTPUT_FILE, "> $out") or die "Cannot open $out for output";
	open(INPUT_FILE, "< $in") or die "Cannot open for $in input";
  
	while ($line=<INPUT_FILE>) {
		++$lineno;
		if ($line =~ /^\/\// ) {} # Ignore c++ commented lines.
		elsif ($line =~ /^\s*REM\s+/i) {} # Ignore REM commented lines.
		elsif ($line =~ /^\s*$/) { # Compress blank lines down to one
			if($lastblank) {
				# Do nothing
			}
			else {
				# This is the first blank line
				$lastblank=1;
				print OUTPUT_FILE $line;
			}
		}
		else {
			# Not blank
			my $epoc32_line = 0;
			$lastblank = 0;
			$line =~ s|\#\#||g; # Delete "token-pasting" ops
			$line =~ s|//.*$||g; # Delete trailing c++ comments
			# prefix the epocroot dir to occurrences of 'epoc32' in all "KEYWORD=..." lines.
			$line =~ s/(=\s*)[\\\/]epoc32/\1$epoc32path/i;
			$epoc32_line = defined($1);
			if (!$epoc32_line) {
				$line =~ /(=.*$epocroot_pattern)/i;
				$epoc32_line = defined($1);
			}
			if (!$epoc32_line) {
				if ($k and $line=~/^\s*kerneltrace/i) {
					$line = "kerneltrace $k\n";
				}
			}
			elsif ($on_windows) {
				$line =~ s|\/|\\|g;
			}
			elsif ($line =~ /(^bootbinary\s*=\s*${epocroot}epoc32)(\S+)$/) {
				# unixify the bootbinary line
				my $tail = $2;
				$line =~ s|\\|\/|g;
				$tail =~ s|\\|\/|g;
				my $lc_tail = lc($tail);
				$line =~ s|$tail|$lc_tail|;
			}
			elsif ($line =~ /^(\s*\S+\s*=\s*)(\S+)(\s*\S*)/) {
				#unixify the lefthand sides of rom-mapping lines.
				my $keyword_part = $1;
				my $src = $2;
				my $dest = $3;
				$dest =~ s/^\s+//;
				$dest =~ s/\s+$//;
				$src =~ s|\\|\/|g;
				if ($dest) {
					my ($vol,$dir,$leaf) = File::Spec->splitpath($src);
					my $lc_leaf = lc($leaf);
					my $lc_dir = lc($dir);
					$lc_dir =~ s/\/$//;
					$lc_dir =~ s|^$lc_epocroot|$epocroot|;
					my $fulldir = $lc_dir;	
					$fulldir =~ s|//|/|g;
					$dest =~ s|\/|\\|g;
					$dest = '\\' . $dest, unless ($dest =~ /^\\/);
					unless ( -d $fulldir ) {
						chomp $line;
						# Lower-cased source directory doesn't exist. Give up.
						die "Guessed source directory \"$fulldir\" does not exist for line $lineno: \"$line\"\n";
					}
					if (($leaf eq $lc_leaf) or (-f "$fulldir\/$leaf")) { 
						# Using source directory lowercase and source filename as input.
						$line = "${keyword_part}${lc_dir}\/${leaf}\t${dest}\n";
					}
					elsif ( -f "$fulldir\/$lc_leaf") {
						# Using source directory source filename both lowercase.
						$line = "${keyword_part}${lc_dir}\/${lc_leaf}\t${dest}\n";
					}
					else { # Harder.
						my @dirlist;
						my $found = 0;
						if (!defined($dir_listings{$fulldir})) {
							# Haven't got a cached dir listing for the source directory.
							# Make one now.
							@dirlist = glob("$fulldir.*");
							$dir_listings{$fulldir} = \@dirlist;
						}	
						@dirlist = @{dir_listings{$fulldir}}; # Get listing of source directory from cache.
						foreach my $file (@dirlist) {
							# See if any file in the source directory case-insensitively matches the input source file.
							if ( (-f "$fulldir\/$file") and (lc($file) eq $lc_leaf)) {
								$line = "${keyword_part}${lc_dir}\/${file}\t${dest}\n";
								$found = 1;
								last;
							}
						}
						unless ($found) {
							die "Cannot find any file case-insensitively matching \"$fulldir\/$leaf\" at line $lineno: \"$line\"\n";
						}
					}
				}
				else {
					$line =~ s|\\|\/|g;
				}								
			}
			print OUTPUT_FILE $line;
		}
	}
	close(INPUT_FILE);
	close(OUTPUT_FILE);
}

sub IsRVCTBuild($) {
    my ($build)=@_;
    return 1 if ($build =~ /^ARMV/i);
	my @customizations = Plat_Customizations('ARMV5');
	return 1 if (grep /$build/, @customizations);
	return 0;
}


sub IsSmp($) {
	my %SmpKernelDirs=(
		'x86smp' => 1,
		'x86gmp' => 1,
		'arm4smp' => 1,
		'armv4smp' => 1,
		'armv5smp' => 1
	);

	my ($kdir) = @_;
	return $SmpKernelDirs{lc $kdir};
}

sub checkopts {
	unless($opts{variant}) { die "No Variant specified"; }
	$opts{'build'}="UDEB" unless($opts{'build'});
	$opts{'type'}="TSHELL" unless($opts{'type'});
	$opts{'inst'}="ARM4" unless($opts{'inst'});

	my $additional;
	if ($opts{'modules'}) {
		$additional="_".$opts{modules};
		$additional=~ s/,/_/ig;
	}
	my $build=lc $opts{build};
	my $inst=uc $opts{'inst'};
	if ($inst eq "MARM") {
		# Hackery to cope with old compiler
		$main="MARM";
		$euserdir="MARM";
		$elocldir="MARM";
	}
	else {
		$main=$inst;
		if ($main eq "THUMB") {
			$euserdir="ARMI";
		} else {
			$euserdir=$main;
		}
		if ($main eq "ARMI" or $main eq "THUMB") {
			$elocldir="ARM4";
		} else {
			$elocldir=$main;
		}
	}
	$kmain = $opts{'xabi'};
	$kmain = $main unless ($kmain);
	if (IsSmp($kmain)) {
		$euserdir = $kmain;
	}
	if ($opts{name}) {
		$romname=$opts{name};
	} else {
		$romname=uc($opts{variant}.$additional.$main);
		if ($build=~/^\w*DEB$/i) {
			$romname.='D';
		}
		$romname.='.IMG';
	}
}

sub lookupFileInfo($$)
{
	my ($infile, $fullname) = @_;

	my ($name, $ext) = $fullname =~ /^(.+)\.(\w+)$/ ? ($1, $2) : ($fullname, undef);

	open TMP, $infile or die("Can't open $infile\n");
	while(<TMP>)
	{
		$_ = lc;
		if(/^\s*(\S+)\s*=\s*(\S+)\s+(\S+)/i)
		{
			my ($src, $dest) = ($2, $3);

			my $destFullname = $dest =~ /^.*\\(.+)$/ ? $1 : $dest;
			my ($destName, $destExt) = $destFullname =~ /^(.+?)\.(\w+)$/ ? ($1, $2) : ($destFullname, undef);

			if ($destName eq $name && (!$ext || $ext eq $destExt))
			{
				close TMP;
				return ($src, $dest);
			}
		}
	}

	die "patchdata: Can't find file $fullname\n";
}

sub lookupSymbolInfo($$)
{
	my ($file, $name) = @_;
	open TMP, $file or die "Can't read $file\n";

	# ignore local symbols.
	while (<TMP>)
	{
		last if /Global Symbols|Linker script and memory map/;
	}

  my @return_values = ();
  my $line;
	while ($line = <TMP>)
	{
		next if (index($line, $name) < 0);		
		
		# RVCT 2.2
		# 
		#     KHeapMinCellSize  0x0004e38c  Data 4  mem.o(.constdata)
		#
		if ($line =~ /^\s*(\S+)\s+(\S+)\s+data\s+(\S+)/i)
		{
			my ($symbol, $addr, $size) = ($1, $2, $3);
			if ($symbol eq $name)
			{
				@return_values = ($addr, $size);
				last;
			}
		}

		# This is a quick fix for RVCT 3.1, which uses the text "(EXPORTED)"
		# in the map file. Here is an example:
		#
		# KHeapMinCellSize (EXPORTED) 0x0003d81c Data 4 mem.o(.constdata)
		#
		elsif ($line =~ /^\s*(\S+)\s+\(exported\)\s+(\S+)\s+data\s+(\S+)/i)
		{
			my ($symbol, $addr, $size) = ($1, $2, $3);
			if ($symbol eq $name)
			{
				@return_values = ($addr, $size);
				last;
			}
		}
		
		# GCC 4.x map files
		#                 0x00114c68                KHeapMinCellSize
		#                 0x00114c6c                KHeapShrinkHysRatio
		#  .rodata        0x00115130      0x968 M:/epoc32/build/kernel/c_99481fddbd6c6f58/_omap3530_ekern_exe/armv5/udeb/heap_hybrid.o
		#
		elsif ($line =~ /^.+\s+(0x\S+)\s+(\S+)/i)
		{
			my ($addr, $symbol) = ($1, $2);
			if ($symbol eq $name)
			{
				my $next_line = <TMP>;
				if ($next_line =~ /^.+\s+(0x\S+)\s+(\S+)/i)
				{
					my $addr2 = $1;
					
					@return_values = ($addr, hex($addr2) - hex($addr));
					last;
				}
			}
		}

	}
	close TMP;

	die "patchdata: Can't find symbol $name\n" if (scalar @return_values == 0);
	return @return_values;
}

sub parsePatchData($$)
{
	my ($infile, $outfile) = @_;

	open IN, $infile or die("Can't read $infile\n");
	open OUT, ">$outfile" or die("Can't write $outfile\n");

	my $line;
	while($line = <IN>)
	{
		if ($line =~ /^\s*patchdata\s+(.+?)\s*$/i)
		{
			if ($1 !~ /(\S+)\s*@\s*(\S+)\s+(\S+)\s*$/)
			{
				die "Bad patchdata command: $line\n";
			}

			my ($file, $symbol, $value) = (lc $1, $2, $3);
			my ($srcFile, $destFile) = lookupFileInfo($infile, $file);
			my ($index, $elementSize) = (undef, undef);
			if ($symbol =~ s/:(\d+)\[(\d+)\]$//)
			{
				($index, $elementSize) = ($2, $1);
				$index = hex($index) if $index =~ /^0x/i;
			}

			if ($srcFile =~ /\\armv5(smp)?\\/i)
			{
				my ($symbolAddr, $symbolSize) = lookupSymbolInfo("$srcFile.map", $symbol);

				my $max;
				if (defined($index))
				{
					my $bytes;
					$bytes = 1, $max = 0xff       if $elementSize ==  8;
					$bytes = 2, $max = 0xffff     if $elementSize == 16;
					$bytes = 4, $max = 0xffffffff if $elementSize == 32;
					die("patchdata: invalid element size $elementSize: $line\n") unless defined($bytes);

					if ($bytes > 1 && (($symbolSize & ($bytes-1)) != 0))
					{
						die("patchdata: unexpected symbol size $symbolSize for array $symbol ($elementSize-bit elements)\n");
					}

					if ($index >= int($symbolSize / $bytes))
					{
						die("patchdata: index $index out of bounds for $symbol of $symbolSize bytes ($elementSize-bit elements)\n");
					}

					$symbolAddr = hex($symbolAddr) if $symbolAddr =~ /^0x/i;
					$symbolAddr += $index * $bytes;
					$symbolAddr = sprintf("0x%x", $symbolAddr);

					$symbolSize = $bytes;
				}
				elsif ($symbolSize == 1) { $max = 0xff; }
				elsif ($symbolSize == 2) { $max = 0xffff; }
				elsif ($symbolSize == 4) { $max = 0xffffffff; }
				else { die "patchdata: Unexpected symbol size $symbolSize for $symbol\n"; }

				$value = hex($value) if $value =~ /^0x/i;
				if ($value > $max)
				{
					print("Warning:  Value overflow of $symbol\n");
					$value &= $max;
				}					
				$value = sprintf("0x%08x", $value);

				$line = "patchdata $destFile addr $symbolAddr $symbolSize $value\n";
			}
			else
			{
				$line = "";
			}

		}

		print OUT $line;
	}

	close IN;
	close OUT;
}

sub genfile {
	my $count=0;
	if($_[0] eq 'paged') {
		my $file='gentestpaged.txt';
		unlink $file;
		open(OUTFILE, ">$file") or die "Can't open output file, $!";
		for(my $i=0;$i<50000;++$i) {
			if(($i >5) && ($i % 40 ==0)) {
			print OUTFILE "\n";
			$count++;
			} 
			if(($i+$count) % 5 ==0) {
			print OUTFILE "SATOR ";
			}
			if(($i+$count) % 5 ==1) {
			print OUTFILE "AREPO ";
			}
			if(($i+$count) % 5 ==2) {
			print OUTFILE "TENET ";
			}
			if(($i+$count) % 5 ==3) {
			print OUTFILE "OPERA ";
			}
			if(($i+$count) % 5 ==4) {
			print OUTFILE "ROTAS ";
			}
		}
	} else {
		my $file='gentestnonpaged.txt';
		unlink $file;
		open(OUTFILE, ">$file") or die "Can't open output file, $!";
		for(my $i=0;$i<20000;++$i) {
			if(($i >5) && ($i % 40 ==0)) {
			print OUTFILE "\n";
			$count++;
			} 
			if(($i+$count) % 4 ==0) {
			print OUTFILE "STEP ";
			}
			if(($i+$count) % 4 ==1) {
			print OUTFILE "TIME ";
			}
			if(($i+$count) % 4 ==2) {
			print OUTFILE "EMIT ";
			}
			if(($i+$count) % 4 ==3) {
			print OUTFILE "PETS ";
			}
		}
	}
}

sub Variant_GetMacroHRHFile {
	my $cfgFile =  File::Spec->catfile($toolpath,"variant","variant.cfg"); # default location
	# save the volume, if any.
	my ($cfg_vol,$ignore1,$ignore2) = File::Spec->splitpath($cfgFile);    
    my $file;
    if(-e $cfgFile){
		open(FILE, $cfgFile) || die "\nCould not open for reading: " . $cfgFile ."\n";
		while (<FILE>) {
			# strip comments
			s/^([^#]*)#.*$/$1/o;
			# skip blank lines
			if (/^\s*$/o) {
				next;
			}
			# get the hrh file
			if($_ =~ /\.hrh/xi){
				$file = $_; 
				last;
			}
		}
		close FILE;
		die "\nERROR: No variant file specified in $cfgFile!\n" unless $file;
		$file =~ s/\s+//g;
		$file =~ s|\\|\/|g, unless($on_windows);

		if ($on_windows) {
			if (File::Spec->file_name_is_absolute($file)) {
				my ($vol,$dir,$leaf) = File::Spec->splitpath($file);
				unless ( $vol) {
					$vol = substr $epocroot,0,2;
					$file = substr $file,1;                 
					$file = File::Spec->catfile($epocroot,$dir,$leaf);
				}
				die "\nERROR: Variant file specified in $cfgFile is not on the same volume as EPOCROOT\n", if (lc($vol) ne lc($cfg_vol));
			}
			else {
				$file = File::Spec->catfile($epoc32path,$file);
			}
		}
		elsif (File::Spec->file_name_is_absolute($file) && ! -e $file) {
			$file = File::Spec->catfile($epocroot,$file);
		} 

		unless(-e $file) {
			die "\nERROR: $cfgFile specifies $file which doesn't exist!\n";
		}

		$file =~ s/\//\\/g, if ($on_windows);
    }
    return $file;
}

