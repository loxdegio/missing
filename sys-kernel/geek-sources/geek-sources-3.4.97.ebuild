# Copyright 2009-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"
KSV="$(echo $PV | cut -f 1-3 -d .)"

BFQ_VER="3.4.0-v7r5"
CK_VER="${KMV}-ck3"
FEDORA_VER="d0633aed96aaed8d8996ecec7213ad2bf1a819df" # Linux v3.4-10115-g829f51d
ICE_VER="for-linux-3.4.95-2014-06-27"
MAGEIA_VER="releases/3.4.6/1.mga3"
PAX_VER="3.4.8-test32"
SUSE_VER="259fc874ec90b84ca02ad1c1ae186989c83bb2fa" # rpm-3.4.11-2.16
# RT_VER="${KSV}-rt117-rc1"
UKSM_VER="0.1.2.3"
UKSM_NAME="uksm-${UKSM_VER}-for-v${KMV}.ge.96"

SUPPORTED_USES="aufs bfq brand -build ck deblob fedora gentoo ice mageia pax pf suse symlink uksm zen"

inherit geek-sources

HOMEPAGE="https://github.com/init6/init_6/wiki/${PN}"
KEYWORDS="amd64 x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
