# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: spl.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with spl patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with spl patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/spl.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "spl.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_SPL} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_SPL="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
spl_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${SPL_VER:=${SPL_VER:-"master"}} # Patchset version
	: ${SPL_SRC:=${SPL_SRC:-"git://github.com/zfsonlinux/spl.git"}} # Patchset sources url
	: ${SPL_URL:=${SPL_URL:-"http://zfsonlinux.org"}} # Patchset url
	: ${SPL_INF:=${SPL_INF:-"${YELLOW}Integrate Solaris Porting Layer version ${GREEN}${SPL_VER}${YELLOW} from ${GREEN}${SPL_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: SPL_VER=${SPL_VER}"
	debug-print "${FUNCNAME}: SPL_SRC=${SPL_SRC}"
	debug-print "${FUNCNAME}: SPL_URL=${SPL_URL}"
	debug-print "${FUNCNAME}: SPL_INF=${SPL_INF}"
}

spl_init_variables

HOMEPAGE="${HOMEPAGE} ${SPL_URL}"

LICENSE="${LICENSE} GPL-3"

DEPEND="${DEPEND}
	zfs?	( dev-vcs/git )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
spl_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CTD="${T}/spl"
	local CSD="${GEEK_STORE_DIR}/spl"
	local CWD="${T}/spl"
	shift

	echo
	einfo "Prepare kernel sources"
	cd "${S}" || die "${RED}cd ${S} failed${NORMAL}"
	export PORTAGE_ARCH="${ARCH}"
	case ${ARCH} in
		x86) export ARCH="i386";;
		amd64) export ARCH="x86_64";;
		*) export ARCH="${ARCH}";;
	esac
	`zcat /proc/config.gz > .config && yes "" | make oldconfig && make prepare && make scripts` > /dev/null 2>&1

	if [ -d ${CSD} ]; then
	cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"
		if [ -e ".git" ]; then # git
			git fetch --all && git pull --all
		fi
	else
		git clone "${SPL_SRC}" "${CSD}" > /dev/null 2>&1; cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"; git_get_all_branches
	fi

	copy "${CSD}" "${CWD}"
	
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"

	git_checkout "${SPL_VER}" > /dev/null 2>&1 git pull > /dev/null 2>&1

	rm -rf "${CWD}"/.git || die "${RED}rm -rf ${CWD}/.git failed${NORMAL}"
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
spl_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	local CWD="${T}/spl"
	shift

	einfo "${SPL_INF}"
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
	[ -e autogen.sh ] && ./autogen.sh > /dev/null 2>&1
	./configure \
		--prefix=${PREFIX}/ \
		--libdir=${PREFIX}/lib \
		--includedir=/usr/include \
		--datarootdir=/usr/share \
		--enable-linux-builtin=yes \
		--with-linux=${S} \
		--with-linux-obj=${S} > /dev/null 2>&1 || die "${RED}spl ./configure failed${NORMAL}"
	./copy-builtin ${S} > /dev/null 2>&1 || die "${RED}spl ./copy-builtin ${S} failed${NORMAL}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
spl_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${SPL_INF}"
}

fi
