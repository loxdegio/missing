# Copyright 2015 loxdegio
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit linux-info eutils systemd

DESCRIPTION="ZRAM service for Systemd"
HOMEPAGE="https://github.com/loxdegio/SystemdZramService/" 
SRC_URI="https://github.com/loxdegio/SystemdZramService/blob/master/${P}.tar.bz2?raw=true -> ${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"

DEPEND=""

CONFIG_CHECK="ZRAM"
ERROR_ZRAM="CONFIG_ZRAM has to be configured at least Module to enable the activation of zram device(s)."

S=${WORKDIR}

pkg_setup() {
	if kernel_is lt 2 6 37 ; then
		eerror "${PN} isn't supported by version of installed kernel."
		eerror "Please use a newer kernel. At least linux 2.6.37.1"
		die
	fi
}

src_install() {
	
	into /usr
	dosbin ${S}/zramstart
	dosbin ${S}/zramstop
	
	exeinto /usr/bin
	doexe ${S}/zramstat
	
	insinto /etc/conf.d
	insopts -m644
	doins ${S}/zram
	
	systemd_dounit ${S}/zram.service
}

pkg_postrm() {
	if [ -f /usr/lib/systemd/system/zram.service ]; then
		rm /usr/lib/systemd/system/zram.service;
	fi
	
	if [ -f /usr/sbin/zramstart ]; then
		rm /usr/sbin/zramstart;
	fi
	
	if [ -f /usr/sbin/zramstop ]; then
		rm /usr/sbin/zramstop;
	fi
	
	if [ -f /usr/sbin/zramstat ]; then
		rm /usr/sbin/zramstat;
	fi
	
	if [ -f /etc/conf.d/zram ]; then
		rm /etc/conf.d/zram;
	fi;
}
