# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: src-vanilla.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (09 Jan 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building linux kernel.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# linux kernel.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/src-vanilla.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "src-vanilla.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_SRC_VANILLA} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_SRC_VANILLA="recur -_+^+_- spank"

inherit build deblob patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare src_compile src_install pkg_postinst

# No need to run scanelf/strip on kernel sources/headers (bug #134453).
RESTRICT="mirror binchecks strip"

LICENSE="GPL-2"

# 0 for 3.4.0
if [ "${SUBLEVEL}" = "0" ] || [ "${PV}" = "${KMV}" ] ; then
	PV="${KMV}" # default PV=3.4.0 new PV=3.4
	if [[ "${PR}" == "r0" ]] ; then
		SKIP_UPDATE=1 # Skip update to latest upstream
	fi
fi

# ebuild default values setup settings
EXTRAVERSION=${EXTRAVERSION:-"-geek"}
KV_FULL="${PVR}${EXTRAVERSION}"
S="${WORKDIR}"/linux-"${KV_FULL}"

DEPEND="!build? ( sys-apps/sed
		  >=sys-devel/binutils-2.11.90.0.31 )"
RDEPEND="!build? ( >=sys-libs/ncurses-5.2
		   sys-devel/make
		   dev-lang/perl
		   sys-devel/bc )"
PDEPEND="!build? ( virtual/dev-manager )"

SLOT=${SLOT:-${KMV}}
IUSE="${IUSE} symlink"

case "${PR}" in
	r0)	case "${VERSION}" in
		2)	extension="xz"
			case "${PATCHLEVEL}" in
			4)	kurl="mirror://kernel/linux/kernel/v${KMV}"
				kversion="${PV}"
				SKIP_UPDATE=1
			;;
			6)	kurl="mirror://kernel/linux/kernel/v${KMV}/longterm/v${KMV}.${SUBLEVEL}"
				kversion="${KSV}"
			;;
			esac
			if [ "${SUBLEVEL}" != "0" ] || [ "${PV}" != "${KMV}" ]; then
				if [ "${PATCHLEVEL}" = 6 ]; then
					pversion="${PV}"
					pname="patch-${pversion}.${extension}"
					SRC_URI="${SRC_URI} ${kurl}/${pname}"
				fi
			fi
		;;
		3)	extension="xz"
			kurl="mirror://kernel/linux/kernel/v${VERSION}.0"
			kversion="${KMV}"
			if [ "${SUBLEVEL}" != "0" ] || [ "${PV}" != "${KMV}" ]; then
				pversion="${PV}"
				pname="patch-${pversion}.${extension}"
				SRC_URI="${SRC_URI} ${kurl}/${pname}"
			fi
		;;
		esac
	;;
	*)	case "${VERSION}" in
		2)	extension="xz"
			case "${PATCHLEVEL}" in
			4)	kurl="mirror://kernel/linux/kernel/v${KMV}"
				kversion="${PV}"
				SKIP_UPDATE=1
			;;
			6)	kurl="mirror://kernel/linux/kernel/v${KMV}/longterm/v${KMV}.${SUBLEVEL}"
				kversion="${KSV}"
			;;
			esac
			if [ "${SUBLEVEL}" != "0" ] || [ "${PV}" != "${KMV}" ]; then
				if [ "${PATCHLEVEL}" = 6 ]; then
					pversion="${PV}"
					pname="patch-${pversion}.${extension}"
					SRC_URI="${SRC_URI} ${kurl}/${pname}"
				fi
			fi
		;;
		3)	extension="xz"
			kurl="mirror://kernel/linux/kernel/v${VERSION}.0/testing"
			kversion="${VERSION}.$((${PATCHLEVEL} - 1))"
			if [ "${SUBLEVEL}" != "0" ] || [ "${PV}" != "${KMV}" ]; then
				pversion="${PVR//r/rc}"
				pname="patch-${pversion}.${extension}"
				SRC_URI="${SRC_URI} ${kurl}/${pname}"
			fi
		;;
		esac
	;;
esac

kname="linux-${kversion}.tar.${extension}"
SRC_URI="${SRC_URI} ${kurl}/${kname}"

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
src-vanilla_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	local rm_unneeded_arch_cfg=$(source $cfg_file 2>/dev/null; echo ${rm_unneeded_arch})
	: ${rm_unneeded_arch:=${rm_unneeded_arch_cfg:-no}} # rm_unneeded-arch=yes/no

	local gen_init_cpio_cfg=$(source $cfg_file 2>/dev/null; echo ${gen_init_cpio})
	: ${gen_init_cpio:=${gen_init_cpio_cfg:-yes}} # gen_init_cpio=yes/no

	local oldconfig_cfg=$(source $cfg_file 2>/dev/null; echo ${oldconfig})
	: ${oldconfig:=${oldconfig_cfg:-yes}} # gen_init_cpio=yes/no

	debug-print "${FUNCNAME}: rm_unneeded_arch=${rm_unneeded_arch}"
	debug-print "${FUNCNAME}: gen_init_cpio=${gen_init_cpio}"
	debug-print "${FUNCNAME}: oldconfig=${oldconfig}"
}

src-vanilla_init_variables

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
src-vanilla_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	if [ "${A}" != "" ]; then
		ebegin "Extract the sources"
			tar xvJf "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/${kname}" &>/dev/null
		eend $?
		cd "${WORKDIR}" || die "${RED}cd ${WORKDIR} failed${NORMAL}"
		mv "linux-${kversion}" "${S}" || die "${RED}mv linux-${kversion} ${S} failed${NORMAL}"
	fi
	cd "${S}" || die "${RED}cd ${S} failed${NORMAL}"
	if [ "${SKIP_UPDATE}" = "1" ] ; then
		ewarn "${RED}Skipping update to latest upstream ...${NORMAL}"
	else
		ApplyPatch "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/${pname}" "${YELLOW}Update to latest upstream ...${NORMAL}"
	fi

	if use deblob; then
		geek-deblob_src_unpack
	fi
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
src-vanilla_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ebegin "Set extraversion in Makefile" # manually set extraversion
		sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile
	eend

	if [ ! "${EXTRAVERSION}" = "-geek" ]; then
		sed -i -e 's/CONFIG_FLAGS=""/CONFIG_FLAGS="GEEK"/;s/CONFIG_FLAGS="SMP"/CONFIG_FLAGS="$CONFIG_FLAGS SMP"/' scripts/mkcompile_h
	fi

	if [ "${gen_init_cpio}" = "yes" ] || [ "${oldconfig}" = "yes" ]; then
		get_config
	fi

	ebegin "Cleanup backups after patching"
		rm_crap
	eend

	case "$rm_unneeded_arch" in
	yes)	ebegin "Remove unneeded architectures"
			if use x86 || use amd64; then
				rm -rf "${WORKDIR}"/linux-"${KV_FULL}"/arch/{alpha,arc,arm,arm26,arm64,avr32,blackfin,c6x,cris,frv,h8300,hexagon,ia64,m32r,m68k,m68knommu,metag,mips,microblaze,mn10300,openrisc,parisc,powerpc,ppc,s390,score,sh,sh64,sparc,sparc64,tile,unicore32,um,v850,xtensa}
				sed -i 's/include/#include/g' "${WORKDIR}"/linux-"${KV_FULL}"/fs/hostfs/Makefile
			else
				rm -rf "${WORKDIR}"/linux-"${KV_FULL}"/arch/{avr32,blackfin,c6x,cris,frv,h8300,hexagon,m32r,m68k,m68knommu,microblaze,mn10300,openrisc,score,tile,unicore32,um,v850,xtensa}
			fi
		eend ;;
	no)	ewarn "Skipping remove unneeded architectures ..." ;;
	esac

	case "$gen_init_cpio" in
	yes)	ebegin "Compile ${RED}gen_init_cpio${NORMAL}"
			make -C "${WORKDIR}"/linux-"${KV_FULL}"/usr/ gen_init_cpio > /dev/null 2>&1
			chmod +x "${WORKDIR}"/linux-"${KV_FULL}"/usr/gen_init_cpio "${WORKDIR}"/linux-"${KV_FULL}"/scripts/gen_initramfs_list.sh > /dev/null 2>&1
		eend ;;
	no)	ewarn "Skipping compile ${RED}gen_init_cpio${NORMAL} ..." ;;
	esac

	cd "${WORKDIR}"/linux-"${KV_FULL}" || die "${RED}cd ${WORKDIR}/linux-${KV_FULL} failed${NORMAL}"
	local GENTOOARCH="${ARCH}"
	unset ARCH

	case "$oldconfig" in
	yes)	ebegin "Running ${RED}make oldconfig${NORMAL}"
			make oldconfig </dev/null &>/dev/null
		eend $? "Failed oldconfig"
		ebegin "Running ${RED}modules_prepare${NORMAL}"
			make modules_prepare &>/dev/null
		eend $? "Failed ${RED}modules prepare${NORMAL}" ;;
	no)	ewarn "Skipping ${RED}make oldconfig${NORMAL} ..." ;;
	esac

	ARCH="${GENTOOARCH}"

	echo
	einfo "${RED}$(rand_element "Gentoo is about choise" "Gentoo is about power" "Gentoo Rocks" "Thank you for using Gentoo. :)" "Are you actually trying to read this?" "How many times have you stared at this?" "We are generating the cache right now" "You are paying too much attention." "A theory is better than its explanation." "Phasers locked on target, Captain." "Thrashing is just virtual crashing." "To be is to program." "Real Users hate Real Programmers." "When all else fails, read the instructions." "Functionality breeds Contempt." "The future lies ahead." "3.1415926535897932384626433832795028841971694" "Sometimes insanity is the only alternative." "Inaccuracy saves a world of explanation." "Live long and prosper." "Initiating Self Destruct." "If you only know the power of the Dark Side!" "If you eliminate the impossible, whatever remains, however improbable, must be the truth!" "Enter ye in by the narrow gate: for wide is the gate, and broad is the way, that leadeth to destruction, and many are they that enter in thereby." "知る者は言わず言う者は知らず")${NORMAL}"
	echo
}

# @FUNCTION: src_compile
# @USAGE:
# @DESCRIPTION: Configure and build the package.
src-vanilla_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	if use deblob; then
		geek-deblob_src_compile
	fi
}

# @FUNCTION: src_install
# @USAGE:
# @DESCRIPTION: Install a package to ${D}
src-vanilla_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	if use build; then
		geek-build_src_compile
	fi

	local version_h_name="usr/src/linux-${KV_FULL}/include/linux"
	local version_h="${ROOT}${version_h_name}"

	if [ -f "${version_h}" ]; then
		einfo "Discarding previously installed version.h to avoid collisions"
		addwrite "/${version_h_name}"
		rm -f "${version_h}"
	fi

	cd "${S}" || die "${RED}cd ${S} failed${NORMAL}"
	dodir /usr/src
	echo ">>> Copying sources ..."

	move "${WORKDIR}/linux-${KV_FULL}" "${D}/usr/src/linux-${KV_FULL}"
	move "${WORKDIR}/linux-${KV_FULL}-patches" "${D}/usr/src/linux-${KV_FULL}-patches"

	if use symlink; then
		if [ -h "/usr/src/linux" ]; then
			addwrite "/usr/src/linux"
			unlink "/usr/src/linux" || die "${RED}unlink /usr/src/linux failed${NORMAL}"
		elif [ -d "/usr/src/linux" ]; then
			move "/usr/src/linux" "/usr/src/linux-old"
		fi
		dosym linux-${KV_FULL} \
			"/usr/src/linux" ||
			die "${RED}cannot install kernel symlink${NORMAL}"
	fi
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
src-vanilla_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo " ${BLUE}If you are upgrading from a previous kernel, you may be interested${NORMAL}${BR}
 ${BLUE}in the following document:${NORMAL}${BR}
 ${BLUE}- General upgrade guide:${NORMAL} ${RED}http://www.gentoo.org/doc/en/kernel-upgrade.xml${NORMAL}${BR}
 ${RED}${CATEGORY}/${PN}${NORMAL} ${BLUE}is UNSUPPORTED Gentoo Security.${NORMAL}${BR}
 ${BLUE}This means that it is likely to be vulnerable to recent security issues.${NORMAL}${BR}
 ${BLUE}For specific information on why this kernel is unsupported, please read:${NORMAL}${BR}
 ${RED}http://www.gentoo.org/proj/en/security/kernel.xml${NORMAL}${BR}
 ${BR}
 ${BLUE}Now is the time to configure and build the kernel.${NORMAL}${BR}"

	if use deblob; then
		geek-deblob_pkg_postinst
	fi
}

fi
