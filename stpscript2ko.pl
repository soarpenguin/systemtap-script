#!/usr/bin/perl
#
# use for to convert script to kernel module.
#   stap -r 2.6.35.14-106.fc14.i686 nettop.stp -m nettop -p4
#       
#       -p NUM Stop  after  pass  NUM.   The passes are numbered 1-5: parse, elaborate, translate,
#              compile, run.  See the PROCESSING section for details.

use strict;
use warnings;
use Smart::Comments;
use Getopt::Long;
use File::Basename;
use Term::ANSIColor;

my $uname;
chomp($uname = `uname -r`);
## $uname
my $myscript; # systemstp script to convert. 
my $mymodule; # kernel module name.
my $kerneldir; # kernel source code dir.
my $program = &_my_program();

my $command = 'stap -r';

my $usage = "
Usage: $program [option] ...

       -h, --help 
            Display this help and exit

       -m [modulename], --module [modulename]
            The output module name(default: scriptname.ko).

       -s scriptname, --script scriptname
            The script name want to converted to *.ko.
       
       -r /DIR
              Build  for  kernel  in given build tree. Can also 
              be set with the SYSTEMTAP_RELEASE environment variable.

       -r RELEASE (default)
              Build for kernel in build tree /lib/modules/RELEASE/build. 
              Can also  be  set  with the SYSTEMTAP_RELEASE environment variable.

       -V   Display version information.
";

my $ret = GetOptions(
    'script|s=s' => \$myscript,
    'module|m=s' => \$mymodule,
    'help|h'     => \&usage,
    'r=s'        => \$kerneldir
);

$| =1;

if(! $ret) {
   &usage(); 
}

unless($myscript) {
    &mydie("Please input the script needed convert to kernel module.");
}

if(! -e $myscript) {
    &mydie("The input script: $myscript not existed.");
}

unless($mymodule) {
    if($myscript =~ /^((\w)+)\.(\w)+/) {
        $mymodule = "$1";
    } else {
        $mymodule = "$myscript";
    }
}
## $mymodule

## the command to finish convertion
if(! $kerneldir) {
    &myprint("\nUse current running kernel: \"$uname\"!\n");
    if($uname =~ /^\'([^']+)\'/) {
        $uname = $1;
    }
    # print "$uname\n";
} else {
    if(-e $kerneldir) {
        ## $kerneldir
        if($kerneldir =~ /((.)+)\/$/) {
            $uname = $1;
        } else {
            $uname = $kerneldir;
        }
        ## $uname
        &myprint("Use kernel build tree: \"$uname\"!\n");
    } else {
        &myprint("The kernel build tree: \"$kerneldir\" not exists!\n");
        &myprint("Use current running kernel: \"$uname\"!\n");
        if($uname =~ /^\'([^']+)\'/) {
            $uname = $1;
        }
    }
}

my $result = `$command $uname $myscript -m $mymodule -p4`;
chomp($result);
## $result
if($? == 0) {
    print color("green");
    print "The $myscript successful converted to $result.\n";
    print color("reset");
} else {
    &myprint("The $myscript convertion is failed!\n");
}

##----------------------------------------------------
#
sub _my_program {
    require File::Basename;
    return File::Basename::basename( $0 );
}

sub usage {
    print $usage;
    exit;
}

sub mydie {
    print color("red");
    print("@_ \n");
    print color("reset");
    &usage();
}

sub myprint {
    print color("red");
    print("@_ \n");
    print color("reset");
}

