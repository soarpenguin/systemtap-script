systemtap-script
================

useful systemtap script.
just for study.

setup for ubuntu:

    1.install systemtap

    $sudo apt-get install systemtap
    $sudo apt-get install systemtap-runtime

    2.install kernel-debug-info

    use source-list:
    (1)Install the Linux kernel debug image
    ----------------------------------------------------------
    Add debug source to the sources list of Ubuntu

    Create an /etc/apt/sources.list.d/ddebs.list by running the following line at
    a terminal:
    echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" | \
    sudo tee -a /etc/apt/sources.list.d/ddebs.list

    Stable releases (not alphas and betas) require three more lines adding to the
    same file, which is done by the following terminal command:
    echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse
    deb http://ddebs.ubuntu.com $(lsb_release -cs)-security main restricted universe multiverse
    deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" | \
    sudo tee -a /etc/apt/sources.list.d/ddebs.list

    Import the debug symbol archive signing key:
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 428D7C01

    Then run:
    sudo apt-get update

    Get Linux kernel debug image
    sudo apt-get install linux-image-$(uname -r)-dbgsym
    
    --------------------------------------------------------
    (2)General ddeb repository configuration
    # cat > /etc/apt/sources.list.d/ddebs.list << EOF
    deb http://ddebs.ubuntu.com/ precise main restricted universe multiverse
    EOF

    # apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ECDCAD72428D7C01
    # apt-get update

    download url:
    ubuntu kernel-debug-info: http://ddebs.ubuntu.com/pool/main/l/linux/
    
setup for fedora:

    yum install systemtap kernel-devel debuginfo-install kernel


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/soarpenguin/systemtap-script/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

