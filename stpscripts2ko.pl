#!/usr/bin/perl
#
# use for to convert scripts to kernel module.
#   stap -r 2.6.35.14-106.fc14.i686 nettop.stp [scripts...]
#       

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Term::ANSIColor;

my $DEBUG = 0;
if ($DEBUG) {
    eval q{
        use Smart::Comments;
    };
    die $@ if $@;
}

my $uname; ## $uname
my $module; # kernel module name.
my $guru; # guru mode
my $kerneldir; # kernel source code dir.
my $bufsize; # bufsize (megebyte) for kernel-to-user data transfer. 
my $program = basename( $0 );

my $command = 'stap';

my $usage = "
Usage: $program [options] [scripts]

       -g  
            Guru mode. Enable parsing of unsafe expert-level 
            constructs like embedded C.(Not enable default, 
            if script contains embedded C, must enable it.)

       -h, --help 
            Display this help and exit

       -r /DIR
            Build for kernel in given build tree. Can also 
            be set with the SYSTEMTAP_RELEASE environment variable.

       -r RELEASE (default)
            Build for kernel in build tree /lib/modules/RELEASE/build. 
            Can also be set with the SYSTEMTAP_RELEASE environment variable.

       -V   Display version information.
       
       -sNUM  
            Use NUM megabyte buffers for kernel-to-user data transfer.  
            On a multiprocessor in bulk mode, this is a per-processor amount.
";

my $ret = GetOptions(
    'help|h'     => \&usage,
    'V'          => \&usage,
    'g'          => \$guru,
    'r=s'        => \$kerneldir,
    'size=i'     => \$bufsize
);

$| =1;

if(! $ret) {
   &usage(); 
} elsif (scalar @ARGV < 1) {
    &myprint("A script must be specified.");
    &usage();
}

chomp($uname = `uname -r`) unless($kerneldir);

if(! $kerneldir) {
    print("\nUse current running kernel: \"$uname\"!\n");
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
        print("Use kernel build tree: \"$uname\"!\n");
    } else {
        &myprint("The kernel build tree: \"$kerneldir\" not exists!\n");
        print("Use current running kernel: \"$uname\"!\n");
        if($uname =~ /^\'([^']+)\'/) {
            $uname = $1;
        }
    }
}

if($guru) {
    $command = 'stap -g';
}

if($bufsize) {
    $bufsize = "-s$bufsize";
} else {
    $bufsize = '';
}

my @failed = ();
my $succeed = ();
## the command to finish convertion
foreach my $script (@ARGV) {
    if(! -e $script) {
        warn("The input script: $script not existed.");
        push @failed, $script;
        next;
    }

    if($script =~ /^((\w)+)\.(\w)+/) {
        $module = "$1";
    } else {
        $module = "$script";
    }

    if($module =~ /[^_0-9a-zA-Z]/) {
        $module =~ s/[^_0-9a-zA-Z]//g;
    }

    my $result = `$command $bufsize -r $uname $script -m $module -p4 2>&1`;
    chomp($result);
    ## $result
    if($? != 0) {
        if($result =~ 'embedded code' and !$guru) {
            &myprint("The script $script contains embedded C. Make try enable guru mode use -g.");
            print("Trying enable guru mode.....\n");
            # make try enable guru mode default.
            $command = 'stap -g';
            $result = `$command $bufsize -r $uname $script -m $module -p4 2>&1`;
        } 

        if ($result =~ 'no probes') {
            &myprint("Make sure $script have probes.");
        } elsif ($? != 0) {
            &myprint("$script: $result");
        }
    }

    if($? == 0) {
        $succeed->{"$script"} = $module;
    } else {
        push @failed, $script;
    }
}

if(scalar $succeed > 0) {
    print color("green");
    print "The scripts successful converted:\n";
    ## $succeed
    &printhash($succeed);
    print color("reset");
}

if(@failed > 0) {
    print color("red");
    print "The scripts failed converted:\n";
    &printarray(@failed);
    print color("reset");
}

##----------------------------------------------------
#
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

sub printarray {
    foreach my $element (@_) {
        print "\t$element\n";
    }
}

sub printhash {
    my $ref = shift;
    my ($key, $value);
    while (($key, $value) = each(%$ref)) {
        print "\t$key => $value\n";
    }
}

