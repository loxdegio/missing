# Copyright 2009-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"
KSV="$(echo $PV | cut -f 1-3 -d .)"

BFQ_VER="3.10.8+-v7r5"
BLD_VER="3.10.0"
BLD_SRC="https://bld.googlecode.com/files/bld-${BLD_VER}.patch"
CK_VER="3.10-ck1"
# HARDENED_VER="3.10.11"
ICE_VER="for-linux-3.10.45-2014-06-27"
# LQX_VER="3.10.22-1"
MAGEIA_VER="releases/3.10.10/3.mga4"
PAX_VER="3.10.12-test26"
REISER4_VER="3.10"
# RT_VER="3.10.44-rt46-rc1"
RSBAC_VER="1.4.7"
RSBAC_NAME="patch-linux-3.10.7-rsbac-${RSBAC_VER}.diff.xz"
UKSM_VER="0.1.2.3"
UKSM_NAME="uksm-${UKSM_VER}-for-v${KMV}.ge.46"

SUPPORTED_USES="aufs bfq bld brand -build cjktty ck deblob fedora gentoo ice mageia openwrt pax pf reiser4 rsbac suse symlink uksm zen zfs"

inherit geek-sources

HOMEPAGE="https://github.com/init6/init_6/wiki/${PN}"
KEYWORDS="amd64 x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
