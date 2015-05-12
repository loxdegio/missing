# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit qt4-r2

DESCRIPTION="A simple, fast and multi-platform file transfer tool for LAN users."
HOMEPAGE="http://www.msec.it/dukto"
SRC_URI="http://download.opensuse.org/repositories/home:/colomboem/xUbuntu_15.04/${P}_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 -*"

DEPEND="dev-qt/qtnetwork
		dev-qt/qtquick1
		dev-qt/qtsingleapplication"
		
src_install() {
	insinto /
	doins ${S}/usr ${S}/bin
}
