# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: pf.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with pf patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with pf patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/pf.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "pf.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_PF} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_PF="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
pf_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${PF_VER:=${PF_VER:-"${KMV}"}} # Patchset version
	: ${PF_SRC:=${PF_SRC:-"https://github.com/pfactum/pf-kernel/compare/mirrors:v${KMV}...pf-${PF_VER/KMV/$KMV}.diff"}} # Patchset sources url
	: ${PF_URL:=${PF_URL:-"http://pf.natalenko.name"}} # Patchset url
	: ${PF_INF:=${PF_INF:-"${YELLOW}pf-kernel patches version ${GREEN}${PF_VER}${YELLOW} from ${GREEN}${PF_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: PF_VER=${PF_VER}"
	debug-print "${FUNCNAME}: PF_SRC=${PF_SRC}"
	debug-print "${FUNCNAME}: PF_URL=${PF_URL}"
	debug-print "${FUNCNAME}: PF_INF=${PF_INF}"
}

pf_init_variables

HOMEPAGE="${HOMEPAGE} ${PF_URL}"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
pf_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CWD="${T}/pf"
	local CTD="${T}/pf"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	dest="${CWD}"/pf-kernel-"${PV}"-`date +"%Y%m%d"`.patch
	wget "${PF_SRC}" -O "${dest}" > /dev/null 2>&1
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
	ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
pf_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/pf/patch_list" "${PF_INF}"
	move "${T}/pf" "${WORKDIR}/linux-${KV_FULL}-patches/pf"

	ApplyUserPatch "pf"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
pf_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${BLUE}Linux kernel fork with new features, including the -ck patchset (BFS), BFQ, TuxOnIce and UKSM${NORMAL}"
}

fi
