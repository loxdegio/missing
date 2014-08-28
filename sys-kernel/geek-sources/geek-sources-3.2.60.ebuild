# Copyright 2009-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"
KSV="$(echo $PV | cut -f 1-3 -d .)"

BFQ_VER="3.2.0-v7r5"
CK_VER="${KMV}-ck1"
FEDORA_VER="8959a0e95fa1ab409603d38059342e7a99668418" # 3.2
GRSEC_VER="3.0-${KSV}-201407072042" # 07/07/14 20:44
ICE_VER="for-linux-3.2.59-2014-06-02"
LQX_VER="3.2.28-1"
LQX_SRC="http://liquorix.net/sources/legacy/${LQX_VER}.patch.gz"
MAGEIA_VER="releases/3.2.9/2.mga2"
PAX_VER="${KSV}-test153"
PAX_SRC="https://grsecurity.net/~paxguy1/pax-linux-${PAX_VER}.patch"
RSBAC_VER="1.4.7"
RSBAC_NAME="patch-linux-3.2.50-rsbac-${RSBAC_VER}.diff.xz"
RT_VER="${KSV}-rt88-rc1"
SUSE_VER="2206a5c5b9aa64bd9a741830257f184818a0f6ee" # rpm-3.2.0-2
UKSM_VER="0.1.2.3"
UKSM_NAME="uksm-${UKSM_VER}-for-v${KMV}.ge.60"

SUPPORTED_USES="aufs bfq brand -build ck deblob fedora gentoo grsec hardened ice lqx mageia pax pf rsbac rt suse symlink uksm"

inherit geek-sources

HOMEPAGE="https://github.com/init6/init_6/wiki/${PN}"
KEYWORDS="amd64 x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
