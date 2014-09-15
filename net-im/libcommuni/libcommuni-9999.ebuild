# Copyright 2014 loxdegio
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit qt5 git-2

DESCRIPTION="A cross-platform IRC framework written with Qt 4"
HOMEPAGE="http://communi.github.io/"
EGIT_REPO_URI="https://github.com/communi/libcommuni"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="icu test"

RDEPEND="dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	icu? ( dev-libs/icu )
	!icu? ( dev-libs/uchardet )"

DEPEND="${RDEPEND}
	test? ( dev-qt/qttest:5 )"

src_prepare() {
	UCHD="${S}"/src/3rdparty/uchardet-0.0.1/uchardet.pri
	echo "CONFIG *= link_pkgconfig" > "$UCHD"
	echo "PKGCONFIG += uchardet" >> "$UCHD"
	qt5_src_prepare
}

src_configure() {
	eqmake5 libcommuni.pro -config no_examples -config no_rpath \
		$(use icu || echo "-config no_icu") \
		$(use test || echo "-config no_tests")
}
