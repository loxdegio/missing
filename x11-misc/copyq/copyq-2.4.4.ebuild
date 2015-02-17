# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit cmake-utils

DESCRIPTION="Qt-based clipboard to make easier copy and paste through the programs with LxQt"
HOMEPAGE="http://sourceforge.net/projects/${PN}/"
SRC_URI="http://sourceforge.net/projects/${PN}/files/${P}/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="qt4"

REQUIRED_USE="qt4"

DEPEND="
	dev-qt/qt3support:4
	dev-qt/qtcore:4
	dev-qt/qtdbus:4
	dev-qt/qtdeclarative:4
	dev-qt/qtgui:4
	dev-qt/qtnetwork:4
	dev-qt/qtopengl:4
	dev-qt/qtscript:4
	dev-qt/qtsvg:4
	dev-qt/qtwebkit:4
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_use qt5)
	)
	cmake-utils_src_configure
}
