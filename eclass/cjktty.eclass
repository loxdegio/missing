# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: cjktty.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (19 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with cjktty patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with cjktty patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/cjktty.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "cjktty.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_CJKTTY} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_CJKTTY="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
cjktty_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${CJKTTY_VER:=${CJKTTY_VER:-"${KMV}"}} # Patchset version
	: ${CJKTTY_SRC:=${CJKTTY_SRC:-"https://github.com/Gentoo-zh/linux-cjktty/compare/torvalds:v${CJKTTY_VER/KMV/$KMV}...${CJKTTY_VER/KMV/$KMV}-utf8.diff"}} # Patchset sources url
	: ${CJKTTY_URL:=${CJKTTY_URL:-"https://github.com/Gentoo-zh/linux-cjktty"}}  # Patchset url
	: ${CJKTTY_INF:=${CJKTTY_INF:-"${YELLOW}CJK support for tty framebuffer vt version ${GREEN}${CJKTTY_VER}${YELLOW} from ${GREEN}${CJKTTY_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: CJKTTY_VER=${CJKTTY_VER}"
	debug-print "${FUNCNAME}: CJKTTY_SRC=${CJKTTY_SRC}"
	debug-print "${FUNCNAME}: CJKTTY_URL=${CJKTTY_URL}"
	debug-print "${FUNCNAME}: CJKTTY_INF=${CJKTTY_INF}"
}

cjktty_init_variables

HOMEPAGE="${HOMEPAGE} ${CJKTTY_URL}"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
cjktty_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/cjktty"
	local CWD="${T}/cjktty"
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	dest="${CWD}"/cjktty-"${PV}"-`date +"%Y%m%d"`.patch
	wget "${CJKTTY_SRC}" -O "${dest}" > /dev/null 2>&1
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
	ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
cjktty_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/cjktty/patch_list" "${CJKTTY_INF}"
	move "${T}/cjktty" "${WORKDIR}/linux-${KV_FULL}-patches/cjktty"

	ApplyUserPatch "cjktty"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
cjktty_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${CJKTTY_INF}"
}

fi
