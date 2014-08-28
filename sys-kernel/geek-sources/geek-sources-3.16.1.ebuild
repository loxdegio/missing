# Copyright 2009-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="0"

KMV="$(echo $PV | cut -f 1-2 -d .)"
KSV="$(echo $PV | cut -f 1-3 -d .)"

AUFS_VER="3.x-rcN"
BFQ_VER="${KSV}-v7r5"
BLD_VER="3.16"
CK_VER="3.16-ck1"
FEDORA_VER="master"
# GRSEC_VER="3.0-${KSV}-201407072046" # 07/07/14 20:47
# GRSEC_SRC="http://grsecurity.net/test/grsecurity-${GRSEC_VER}.patch"
# LQX_VER="${KSV}-1"
# MAGEIA_VER="releases/${KSV}/1.mga5"
PAX_VER="3.16-test1"
PAX_SRC="http://www.grsecurity.net/~paxguy1/pax-linux-${PAX_VER}.patch"
# REISER4_VER="3.14.1"
# RT_VER="${KSV}-rt17"
SUSE_VER="linux-next"
UKSM_VER="0.1.2.3"
UKSM_NAME="uksm-${UKSM_VER}-for-v${KMV}.ge.1"

SUPPORTED_USES="aufs brand -build ck -deblob fedora pax suse symlink uksm zen zfs"

inherit geek-sources

HOMEPAGE="https://github.com/init6/init_6/wiki/${PN}"
KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
