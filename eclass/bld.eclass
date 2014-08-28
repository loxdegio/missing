# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: bld.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with bld patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with bld patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/bld.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "bld.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_BLD} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_BLD="recur -_+^+_- spank"

inherit patch vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
bld_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${BLD_VER:=${BLD_VER:-"${KMV}"}} # Patchset version
	: ${BLD_SRC:=${BLD_SRC:-"https://bld.googlecode.com/files/BLD-${BLD_VER}.patch"}} # Patchset sources url
	: ${BLD_URL:=${BLD_URL:-"http://code.google.com/p/bld"}} # Patchset url
	: ${BLD_INF:=${BLD_INF:-"${YELLOW}Alternate CPU load distribution technique for Linux kernel scheduler version ${GREEN}${BLD_VER}${YELLOW} from ${GREEN}${BLD_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: BLD_VER=${BLD_VER}"
	debug-print "${FUNCNAME}: BLD_SRC=${BLD_SRC}"
	debug-print "${FUNCNAME}: BLD_URL=${BLD_URL}"
	debug-print "${FUNCNAME}: BLD_INF=${BLD_INF}"
}

bld_init_variables

HOMEPAGE="${HOMEPAGE} ${BLD_URL}"

SRC_URI="${SRC_URI}
	bld?	( ${BLD_SRC} )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
bld_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CWD="${T}/bld"
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	dest="${CWD}"/bld-"${PV}"-`date +"%Y%m%d"`.patch
	wget "${BLD_SRC}" -O "${dest}" > /dev/null 2>&1
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
	ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
bld_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/bld/patch_list" "${BLD_INF}"
	move "${T}/bld" "${WORKDIR}/linux-${KV_FULL}-patches/bld"

	ApplyUserPatch "bld"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
bld_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${BLD_INF}"
}

fi
