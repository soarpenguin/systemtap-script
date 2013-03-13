#!/usr/bin/env perl
#

use strict;
use Term::ANSIColor;
#use Smart::Comments;

my $user = `whoami`;
chomp($user);
### $user
my $password;
### $password

if( $> != '0') {
    #&noecho();
    #print "password for $user: ";
    #$password = <>;
    #&echo();
    #
    #`sudo -s << "EOF" $password EOF perl $0;`;
    #print "\n$password\n";
    &myprint("Must be root to run this script.");
    exit;
}

&main();

sub main {
    my $uname = `uname -r`;
    chomp($uname);
    my $error = 0;

    my @softlist = ('systemtap',
                    'systemtap-runtime',
                    'kernel-debuginfo',
                    'kernel-debuginfo-common',
                    'kernel-devel');
    foreach my $soft (@softlist) {
        if($soft =~ /kernel/) {
            $soft .= "-$uname";
            if(&install($soft) != 0) {
                $error = 1;
            }
        } else {
            if(&install($soft) != 0) {
                $error = 1;
            }
        }
    }

    if($error) {
        &myprint("Systemtap setup unsuccessful.\n");
    } else {
        &yesinstall("Systamtap setup successful.\n");
    }
}

sub noecho {
    print `stty -echo`
}

sub echo {
    print `stty sane`
}

sub install {
    my $soft = shift;
    ### $soft
    my $result;

    $result = `yum install -y $soft 2>&1`;
    if($result =~ "already installed" or $result =~ "Installed:"
        or $result =~ "Updated:" or $result =~ "already"
        or $result =~ "newly installed") {
        print color("blue");
        print("+++The $soft installed successful.\n\n");
        print color("reset");
        $result = 0;
    } elsif ($result =~ "No package $soft available") {
        &myprint("Check the name of software: $soft\n");
        $result = 1;
    } elsif ($result =~ "need to be root") {
        &myprint("Need to be root to install $soft.\n");
        $result = 1;
    }else {
        &myprint("$result\n");
        $result = 0;
    }

    return $result;
}

sub myprint {
    print color("red");
    print("@_ \n");
    print color("reset");
}

sub yesinstall {
    print color("green");
    print("@_ \n");
    print color("reset");
}
