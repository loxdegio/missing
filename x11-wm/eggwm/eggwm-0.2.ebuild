# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/eggwm/eggwm-0.2.ebuild,v 1.1 2014/11/14 21:37:52 hwoarang Exp $

EAPI=5

inherit qt4-r2

DESCRIPTION="Egg Lightweight Window Manager written in C++ and Qt"
HOMEPAGE="https://code.google.com/p/eggwm/"
MY_P=${P/_}
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-qt/qtcore:4
	dev-qt/qtgui:4
"

S=${WORKDIR}/${MY_P}
DOCS=(AUTHORS Changelog README.md TODO)

src_configure() {
	eqmake4
}

src_install() {
	
	dodir /usr/share/eggwm
	
	exeinto /usr/bin
	doexe ${S}/eggwm	
	
	emake DESTDIR="${D}" install
}
