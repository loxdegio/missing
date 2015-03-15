# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/sddm-config-editor/sddm-config-editor-9999.ebuild,v1.0 2015/03/14 18:33 loxdegio Exp $

EAPI=5

inherit git-r3 eutils qmake-utils

DESCRIPTION="SDDM Configuration Editor"
HOMEPAGE="https://github.com/hagabaka/sddm-config-editor"
EGIT_REPO_URI="https://github.com/hagabaka/${PN}.git"
KEYWORDS="~amd64 ~x86"

LICENSE="GPL-2"
SLOT="0"

RDEPEND="
	sys-auth/polkit
	dev-qt/qtquick1
"

CDEPEND="	
	dev-qt/qtcore:5
"
	
DEPEND="
	${CDEPEND}
	${RDEPEND}
"

S=${WORKDIR}/${P}/cpp
DOCS=(README.md)

src_prepare() {
	epatch_user
}

src_configure() {
	eqmake5
}

src_install() {
	emake INSTALL_ROOT="${D}" install
}
