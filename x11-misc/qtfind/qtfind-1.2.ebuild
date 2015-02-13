# Copyright 2014 loxdegio
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit 

DESCRIPTION="Qt5 search tool for pcmanfm-qt"
HOMEPAGE="https://forum.manjaro.org/index.php?topic=16371.0"
SRC_URI="https://github.com/loxdegio/SystemdZramService/raw/master/extrapkg/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="+qt5"

CDEPEND="
	dev-qt/qtcore:5
"
DEPEND="${CDEPEND}
"
RDEPEND="${CDEPEND}
"

DOCS=(AUTHORS Changelog README TODO)

S="${WORKDIR}/${PN}_${PV}"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
