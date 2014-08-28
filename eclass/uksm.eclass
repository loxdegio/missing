# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: uksm.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with uksm patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with uksm patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/uksm.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "uksm.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_UKSM} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_UKSM="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
uksm_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${UKSM_VER:=${UKSM_VER:-"${KMV}"}} # Patchset version
	: ${UKSM_NAME:=${UKSM_NAME:-uksm-${UKSM_VER}-for-v${KMV}.ge.1}}
	: ${UKSM_SRC:=${UKSM_SRC:-"http://kerneldedup.org/download/uksm/${UKSM_VER}/${UKSM_NAME}.patch"}} # Patchset sources url
	: ${UKSM_URL:=${UKSM_URL:-"http://kerneldedup.org"}} # Patchset url
	: ${UKSM_INF:=${UKSM_INF:-"${YELLOW}Ultra Kernel Samepage Merging version ${GREEN}${UKSM_NAME}${YELLOW} from ${GREEN}${UKSM_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: UKSM_VER=${UKSM_VER}"
	debug-print "${FUNCNAME}: UKSM_NAME=${UKSM_NAME}"
	debug-print "${FUNCNAME}: UKSM_SRC=${UKSM_SRC}"
	debug-print "${FUNCNAME}: UKSM_URL=${UKSM_URL}"
	debug-print "${FUNCNAME}: UKSM_INF=${UKSM_INF}"
}

uksm_init_variables

HOMEPAGE="${HOMEPAGE} ${UKSM_URL}"

SRC_URI="${SRC_URI}
	uksm?	( ${UKSM_SRC} )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
uksm_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/uksm"
	local CWD="${T}/uksm"
	local CTD="${T}/uksm"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	wget "${UKSM_SRC}" -O "${CWD}/${UKSM_NAME}.patch" > /dev/null 2>&1
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
	ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
uksm_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/uksm/patch_list" "${UKSM_INF}"
	move "${T}/uksm" "${WORKDIR}/linux-${KV_FULL}-patches/uksm"

	ApplyUserPatch "uksm"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
uksm_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${UKSM_INF}"
}

fi
