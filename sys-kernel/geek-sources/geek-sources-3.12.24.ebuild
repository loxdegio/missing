# Copyright 2009-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"
KSV="$(echo $PV | cut -f 1-3 -d .)"

# AUFS_VER="3.x-rcN"
BFQ_VER="3.12.0-v7r5"
BLD_VER="3.12.0"
CK_VER="3.12-ck2"
FEDORA_VER="f19"
# GRSEC_VER="3.0-3.12.8-201401191015" # 01/19/14 10:28
# GRSEC_SRC="http://grsecurity.net/test/grsecurity-${GRSEC_VER}.patch"
ICE_VER="for-linux-3.12.20-2014-06-02"
# LQX_VER="3.12.11-1" # LQX_VER="${KSV}-1"
MAGEIA_VER="releases/3.12.13/2.mga5"
PAX_VER="3.12.8-test15"
PAX_SRC="http://www.grsecurity.net/~paxguy1/pax-linux-${PAX_VER}.patch"
REISER4_VER="3.12.6"
# RT_VER="3.12.22-rt35-rc1"
UKSM_VER="0.1.2.3"
UKSM_NAME="uksm-${UKSM_VER}-for-v3.12.ge.23"

SUPPORTED_USES="aufs bfq bld brand -build ck deblob exfat fedora gentoo ice mageia openwrt pax pf reiser4 suse symlink uksm zen zfs"

inherit geek-sources

HOMEPAGE="https://github.com/init6/init_6/wiki/${PN}"
KEYWORDS="amd64 x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
