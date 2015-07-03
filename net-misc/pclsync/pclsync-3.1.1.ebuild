# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils multilib unpacker

DESCRIPTION="Sync your files between your PC and pCloud account"
HOMEPAGE="https://www.pcloud.com"
SRC_URI="
	amd64? (
		https://c163.pcloud.com/dHZ8IsmSZJvU4uZZZeyLdl7ZHkZZzo0ZkZ5LUXZzPBYbLJ2HJJIsDLlMtPu8bhTKmPy/pCloud_Linux_amd64_3.1.1.deb
	)
	x86? (
		https://c163.pcloud.com/dHZ8IsmSZJvU4uZZZeyLdl7ZHkZZzo0ZkZ5LUXZzPBYbLJ2HJJIsDLlMtPu8bhTKmPy/pCloud_Linux_i386_3.1.1.deb
	)
"

LICENSE="pCloud"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE=""

DEPEND="dev-qt/qtcore:4"
RDEPEND="${DEPEND}
		dev-libs/openssl
		dev-libs/libgcrypt
		media-libs/libpng
		net-dns/c-ares
		dev-libs/crypto++
		app-arch/xz-utils
		!app-arch/deb2targz
		dev-db/sqlite:3
		"

QA_PREBUILT="*"
S="${WORKDIR}"

src_unpack(){
	unpack ${A}
	unpack ./data.tar.gz
	rm -v control.tar.gz data.tar.gz debian-binary
}

pkg_setup(){
	elog "This ebuild installs the binary for pclsync. If any problems,"
	elog "please, contact the pCloud team."
}

src_install(){
	insinto /
	doins -r usr
	fperms +x /usr/bin/psyncgui
	#LIBCRYPTO=`equery f crypto++ | grep libcrypto++.so.0.0.0 | tail -n 1`
	#LIBDIR="${LIBCRYPTO%/*}"
	#dosym ${LIBDIR}/libcrypto++.so.0.0.0 ${LIBDIR}/libcrypto++.so.9
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
