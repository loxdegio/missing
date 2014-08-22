# Copyright 2014 loxdegio
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit qt4-r2

DESCRIPTION="BitTorrent, Gnutella and ed2k client in C++ and Qt"
HOMEPAGE="http://quazaa.sourceforge.net/"
MY_P="gitcode"
EGIT_REPO_URI="git://git.code.sf.net/p/${PN}/${MY_P}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="dbus debug geoip X"

# geoip is runtime dep only (see INSTALL file)
CDEPEND="
	dev-libs/boost:=
	dev-qt/qtcore:4
	>=dev-qt/qtsingleapplication-2.6.1_p20130904-r1[X?]
	>=net-libs/rb_libtorrent-0.16.10
	dbus? ( dev-qt/qtdbus:4 )
	X? ( dev-qt/qtgui:4 )
"
DEPEND="${CDEPEND}
	virtual/pkgconfig
	net-im/libcommuni 
"
RDEPEND="${CDEPEND}
	geoip? ( dev-libs/geoip )
"

S=${WORKDIR}/${MY_P}
DOCS=(AUTHORS Changelog README TODO)

src_configure() {
	eqmake4
}
