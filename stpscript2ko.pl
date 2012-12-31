#!/usr/bin/perl
#
# use for to convert script to kernel module.
#   stap -r 2.6.35.14-106.fc14.i686 nettop.stp -m nettop -p4

use strict;
use warnings;
use Smart::Comments;
use Getopt::Long;
use File::Basename;
use Term::ANSIColor;

my $uname;
chomp($uname = `uname -r`);
## $uname
my $myscript;
my $mymodule;
my $program = &_my_program();

my $command = 'stap -r ';

my $usage = "
Usage: $program [option]...

       -h, --help 
            Display this help and exit

       -m, --module
            The output module name(default: $program\.ko).

       -s, --script
            The script name want to converted to *.ko.

       -V   Display version information.
";

my $ret = GetOptions(
    'script|s=s' => \$myscript,
    'module|m=s' => \$mymodule,
    'help|h'     => \&usage
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
if($uname =~ /^\'([^']+)\'/) {
    $uname = $1;
}
# print "$uname\n";

my $result = `$command $uname $myscript -m $mymodule -p4`;
chomp($result);
## $result
if($? == 0) {
    print "The $myscript successful converted to $result.\n";
} else {
    print "The $myscript convertion is failed!\n";
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

