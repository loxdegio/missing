# Copyright 2009-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"
KSV="$(echo $PV | cut -f 1-3 -d .)"

# AUFS_VER="3.x-rcN"
BFQ_VER="3.14.0-v7r5"
# # BLD_VER="3.13-rc1"
CK_VER="3.14-ck1"
FEDORA_VER="f19"
GRSEC_VER="3.0-${KSV}-201407072045" # 07/07/14 20:46
GRSEC_SRC="http://grsecurity.net/stable/grsecurity-${GRSEC_VER}.patch"
ICE_VER="for-linux-3.14.9-2014-06-27"
# LQX_VER="${KVL}-1"
MAGEIA_VER="releases/3.14.5/3.mga5"
OPENELEC_VER="${KSV}"
PAX_VER="3.14.11-test13"
PAX_SRC="http://www.grsecurity.net/~paxguy1/pax-linux-${PAX_VER}.patch"
REISER4_VER="3.14.1"
# RT_VER="3.14.10-rt7"
SUSE_VER="linux-next"
UKSM_VER="0.1.2.3"
UKSM_NAME="uksm-${UKSM_VER}-for-v${KMV}.ge.10"

SUPPORTED_USES="aufs bfq brand -build ck deblob exfat fedora gentoo grsec ice openelec pax reiser4 suse symlink uksm zen zfs"

inherit geek-sources

HOMEPAGE="https://github.com/init6/init_6/wiki/${PN}"
KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
