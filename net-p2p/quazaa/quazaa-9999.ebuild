# Copyright 2015 loxdegio
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit qmake-utils git-r3

DESCRIPTION="BitTorrent, Gnutella and ed2k client in C++ and Qt5"
HOMEPAGE="http://quazaa.sourceforge.net/"
EGIT_REPO_URI="git://git.code.sf.net/p/${PN}/gitcode"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"

CDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5[widgets]
	dev-qt/qtnetwork:5
	dev-qt/qtsql:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
"
DEPEND="
	${CDEPEND}"

DOCS=(README.md)

src_configure() {	
	epatch "${FILESDIR}/${P}-QObject.patch"
	
	eqmake5
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
