#!/bin/bash

AUTO_INVOKE_SUDO=yes;
curdir=$(dirname $(readlink -f $0));

function invoke_sudo() 
{
    if [ "`id -u`" != "`id -u $1`" ]; then
        echo "`whoami`:you need to be $1 privilege to run this script.";
        if [ "$AUTO_INVOKE_SUDO" == "yes" ]; then 
            echo "Invoking sudo ...";
            sudo -u "#`id -u $1`" bash -c "$2";
        fi
        exit 0;
    fi
}

uid=`id -u`
if [ $uid -ne '0' ]; then 
    invoke_sudo root "${curdir}/$0 $@"
fi
#------------------------------------------------------------------------------
# Prerequisites
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Install
#------------------------------------------------------------------------------
# Development
yum -y install systemtap
debuginfo-install kernel
yum -y install systemtap-runtime
yum -y install kernel-devel
yum -y install systemtap-client
yum -y install systemtap-devel
yum -y install kernel-debug-devel
yum -y install kernel-debug-debuginfo
yum -y install wget
yum -y install dpkg

