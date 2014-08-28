# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: zen.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with zen patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with zen patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/zen.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "zen.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_ZEN} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_ZEN="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
zen_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${ZEN_VER:=${ZEN_VER:-"${KMV}"}} # Patchset version
	: ${ZEN_SRC:=${ZEN_SRC:-"https://github.com/damentz/zen-kernel/compare/torvalds:v${ZEN_VER/KMV/$KMV}...${ZEN_VER/KMV/$KMV}/master.diff"}} # Patchset sources url
	: ${ZEN_URL:=${ZEN_URL:-"https://github.com/damentz/zen-kernel"}} # Patchset url
	: ${ZEN_INF:=${ZEN_INF:-"${YELLOW}The Zen Kernel version ${GREEN}${ZEN_VER}${YELLOW} from ${GREEN}${ZEN_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: ZEN_VER=${ZEN_VER}"
	debug-print "${FUNCNAME}: ZEN_SRC=${ZEN_SRC}"
	debug-print "${FUNCNAME}: ZEN_URL=${ZEN_URL}"
	debug-print "${FUNCNAME}: ZEN_INF=${ZEN_INF}"
}

zen_init_variables

HOMEPAGE="${HOMEPAGE} ${ZEN_URL}"

#SRC_URI="${SRC_URI}
#	zen?	( ${ZEN_SRC} )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
zen_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/zen"
	local CWD="${T}/zen"
	local CTD="${T}/zen"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	dest="${CWD}"/zen-kernel-"${PV}"-`date +"%Y%m%d"`.patch
	wget "${ZEN_SRC}" -O "${dest}" > /dev/null 2>&1
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
	ls -1 | grep ".patch" | xargs -I{} cp "{}" "${CWD}"
	ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
zen_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/zen/patch_list" "${ZEN_INF}"
	move "${T}/zen" "${WORKDIR}/linux-${KV_FULL}-patches/zen"

	ApplyUserPatch "zen"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
zen_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${ZEN_INF}"
}

fi
