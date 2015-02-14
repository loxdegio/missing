# Copyright 2014 loxdegio
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit qt5-build

DESCRIPTION="Qt5 search tool for pcmanfm-qt"
HOMEPAGE="https://forum.manjaro.org/index.php?topic=16371.0"
SRC_URI="https://github.com/loxdegio/SystemdZramService/raw/master/extrapkg/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="+qt5"

CDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
"
DEPEND="${CDEPEND}
"
RDEPEND="${CDEPEND}
"

DOCS=(AUTHORS Changelog README TODO)

S="${WORKDIR}/${PN}_${PV}"

src_install() {
	exeinto /usr/bin
	doexe ${S}/${PN}
	
	insinto /usr/share/pixmaps
	doins ${S}/${PN}.png
	
	insinto /usr/share/file-manager/actions
	doins ${S}/${PN}.desktop
	
	dodir /usr/lib/${PN}_i18n
	insinto /usr/lib/${PN}_i18n
	doins ${S}/${PN}_i18n/*.qm
}
