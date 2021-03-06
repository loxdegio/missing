# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit wxwidgets cmake-utils multilib games

KEYWORDS="-* ~amd64 ~x86"
SRC_URI="https://github.com/PCSX2/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

DESCRIPTION="A PlayStation 2 emulator"
HOMEPAGE="http://www.pcsx2.net"

LICENSE="GPL-3"
SLOT="0"

IUSE="cg egl glew glsl joystick sdl sound video"
REQUIRED_USE="
    glew? ( || ( cg glsl ) )
    joystick? ( sdl )
    sound? ( sdl )
    video? ( || ( egl glew ) )
    ?? ( cg glsl )
"

LANGS="ar_SA ca_ES cs_CZ de_DE es_ES fi_FI fr_FR hr_HR hu_HU id_ID it_IT ja_JP ko_KR ms_MY nb_NO pl_PL pt_BR ru_RU sv_SE th_TH tr_TR zh_CN zh_TW"
for lang in ${LANGS}; do
        IUSE+=" linguas_${lang}"
done

RDEPEND="
	amd64? ( dev-libs/libaio[multilib] )
	x86? ( dev-libs/libaio )

	|| (
		x11-libs/wxGTK:2.8[X]
		x11-libs/wxGTK:3.0[X]
	)

	|| (
		amd64? ( app-emulation/emul-linux-x86-baselibs )
		(
			app-arch/bzip2
			virtual/jpeg:62
			>=sys-libs/zlib-1.2.4
		)
	)
	|| (
		amd64? ( app-emulation/emul-linux-x86-gtklibs )
		x11-libs/gtk+:2
	)
	|| (
		amd64? ( app-emulation/emul-linux-x86-xlibs )
		(
			x11-libs/libICE
			x11-libs/libX11
			x11-libs/libXext
		)
	)

	video? (
		|| (
			amd64? ( app-emulation/emul-linux-x86-opengl )
			(
				virtual/opengl
				egl? ( media-libs/mesa[egl] )
				glew? ( media-libs/glew )
			)
		)
		cg? ( media-gfx/nvidia-cg-toolkit )
	)

	sdl? (
		|| (
			amd64? ( app-emulation/emul-linux-x86-sdl )
			media-libs/libsdl[joystick?,sound?]
		)
	)

	sound? (
		|| (
			amd64? ( app-emulation/emul-linux-x86-soundlibs )
			(
				media-libs/alsa-lib
				media-libs/portaudio
			)
		)
		media-libs/libsoundtouch
	)
"
DEPEND="${RDEPEND}
	>=dev-cpp/sparsehash-1.5
"

PATCHES=(
	# Workaround broken glext.h, bug #510730
	"${FILESDIR}"/mesa-10.patch
)

# Upstream issue: https://github.com/PCSX2/pcsx2/issues/417
QA_TEXTRELS="usr/games/lib32/pcsx2/*"

src_prepare() {
	cmake-utils_src_prepare

	if ! use egl; then
		sed -i -e "s:GSdx TRUE:GSdx FALSE:g" cmake/SelectPcsx2Plugins.cmake || die
	fi
	if ! use glew || ! use cg; then
		sed -i -e "s:zerogs TRUE:zerogs FALSE:g" cmake/SelectPcsx2Plugins.cmake || die
	fi
	if ! use glew; then
		sed -i -e "s:zzogl TRUE:zzogl FALSE:g" cmake/SelectPcsx2Plugins.cmake || die
	fi
	if ! use joystick; then
		sed -i -e "s:onepad TRUE:onepad FALSE:g" cmake/SelectPcsx2Plugins.cmake || die
	fi
	if ! use sound; then
		sed -i -e "s:spu2-x TRUE:spu2-x FALSE:g" cmake/SelectPcsx2Plugins.cmake || die
	fi

	# Remove default CFLAGS
	sed -i -e "s:-msse -msse2 -march=i686::g" cmake/BuildParameters.cmake || die

	einfo "Cleaning up locales..."
	for lang in ${LANGS}; do
		use "linguas_${lang}" && {
			einfo "- keeping ${lang}"
			continue
		}
		rm -Rf "${S}"/locales/"${lang}" || die
	done

	epatch_user
}

src_configure() {
	multilib_toolchain_setup x86

	# pcsx2 build scripts will force CMAKE_BUILD_TYPE=Devel
	# if it something other than "Devel|Debug|Release"
	local CMAKE_BUILD_TYPE="Release"


	if use amd64; then
		# Passing correct CMAKE_TOOLCHAIN_FILE for amd64
		# https://github.com/PCSX2/pcsx2/pull/422
		local MYCMAKEARGS=(-DCMAKE_TOOLCHAIN_FILE=cmake/linux-compiler-i386-multilib.cmake)
	fi

	local mycmakeargs=(
		-DDISABLE_ADVANCE_SIMD=TRUE
		-DEXTRA_PLUGINS=TRUE
		-DPACKAGE_MODE=TRUE
		-DXDG_STD=TRUE

		-DBIN_DIR=${GAMES_BINDIR}
		-DCMAKE_INSTALL_PREFIX=/usr
		-DCMAKE_LIBRARY_PATH=$(games_get_libdir)/${PN}
		-DDOC_DIR=/usr/share/doc/${PF}
		-DGAMEINDEX_DIR=${GAMES_DATADIR}/${PN}
		-DGLSL_SHADER_DIR=${GAMES_DATADIR}/${PN}
		-DGTK3_API=FALSE
		-DPLUGIN_DIR=$(games_get_libdir)/${PN}
		# wxGTK must be built against same sdl version
		-DSDL2_API=FALSE

		$(cmake-utils_use egl EGL_API)
		$(cmake-utils_use glsl GLSL_API)
	)

	local WX_GTK_VER="2.8"
	# Prefer wxGTK:3
	if has_version 'x11-libs/wxGTK:3.0[X]'; then
		WX_GTK_VER="3.0"
	fi

	if [ $WX_GTK_VER == '3.0' ]; then
		mycmakeargs+=(-DWX28_API=FALSE)
	else
		mycmakeargs+=(-DWX28_API=TRUE)
	fi

	need-wxwidgets unicode
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install DESTDIR="${D}"
	prepgamesdirs
}
