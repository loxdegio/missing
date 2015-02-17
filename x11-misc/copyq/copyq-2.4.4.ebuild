# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit cmake-utils

DESCRIPTION="Qt-based clipboard to make easier copy and paste through the programs with LxQt"
HOMEPAGE="http://sourceforge.net/projects/${PN}/"
SRC_URI="http://sourceforge.net/projects/${PN}/files/${P}/${P}.tar.gz/download"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="qt5"

REQUIRED_USE="qt5"

DEPEND="
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
	)"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_use qt5)
	)
	cmake-utils_src_configure
}
