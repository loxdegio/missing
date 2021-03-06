# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit qt5 git-2

DESCRIPTION="A cross-platform IRC framework written with Qt"
HOMEPAGE="http://communi.github.io/"
EGIT_REPO_URI="git://github.com/communi/${PN}"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="icu test"

RDEPEND="dev-qt/qtcore:5
	icu? ( dev-libs/icu )
	!icu? ( dev-libs/uchardet )"

DEPEND="${RDEPEND}
	test? ( dev-qt/qttest:5 )"

src_prepare() {
	epatch "${FILESDIR}/${PN}-ircmessage.patch"
	
	UCHD="${S}"/src/3rdparty/uchardet-0.0.1/uchardet.pri
	echo "CONFIG *= link_pkgconfig" > "$UCHD"
	echo "PKGCONFIG += uchardet" >> "$UCHD"
	qt5_src_prepare
}

src_configure() {
	eqmake5 libcommuni.pro -config no_examples -config no_rpath \
		$(use icu && echo "-config icu" || echo "-config no_icu") \
		$(use test || echo "-config no_tests")
}
