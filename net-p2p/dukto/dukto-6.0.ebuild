# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit qmake-utils

DESCRIPTION="A simple, fast and multi-platform file transfer tool for LAN users."
HOMEPAGE="http://www.msec.it/dukto"
SRC_URI="http://download.opensuse.org/repositories/home:/colomboem/xUbuntu_15.04/${P}_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 -*"

DEPEND="dev-qt/qtnetwork:5
		dev-qt/qtquick1:5
		dev-qt/qtsingleapplication[X,qt5]
		dev-qt/qtdeclarative:5"
		
src_prepare() {
	eqmake5
}
		
src_install() {
	exeinto /usr/bin
	doexe ${S}/${PN}
	
	insinto /usr/share/applications
	doins ${S}/${PN}.desktop
	
	insinto /usr/share/pixmaps
	doins ${S}/${PN}.png
}
