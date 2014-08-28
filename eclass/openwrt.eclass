# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: openwrt.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (11 Dec 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with openwrt patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with openwrt patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/openwrt.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "openwrt.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_OPENWRT} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_OPENWRT="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
openwrt_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${OPENWRT_VER:=${OPENWRT_VER:-"${KMV}"}} # Patchset version
	: ${OPENWRT_SRC:=${OPENWRT_SRC:-"svn://svn.openwrt.org/openwrt/trunk/target/linux/generic"}} # Patchset sources url
	: ${OPENWRT_URL:=${OPENWRT_URL:-"https://openwrt.org"}} # Patchset url
	: ${OPENWRT_INF:=${OPENWRT_INF:-"${YELLOW}OpenWrt patches version ${GREEN}${OPENWRT_VER}${YELLOW} from ${GREEN}${OPENWRT_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: OPENWRT_VER=${OPENWRT_VER}"
	debug-print "${FUNCNAME}: OPENWRT_SRC=${OPENWRT_SRC}"
	debug-print "${FUNCNAME}: OPENWRT_URL=${OPENWRT_URL}"
	debug-print "${FUNCNAME}: OPENWRT_INF=${OPENWRT_INF}"
}

openwrt_init_variables

HOMEPAGE="${HOMEPAGE} ${OPENWRT_URL}"

DEPEND="${DEPEND}
	openwrt?	( dev-vcs/subversion )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
openwrt_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/openwrt"
	local CWD="${T}/openwrt"
	local CTD="${T}/openwrt"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	if [ -d ${CSD} ]; then
		cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"
		if [ -e ".svn" ]; then
			svn up
		fi
	else
		svn co "${OPENWRT_SRC}" "${CSD}" > /dev/null 2>&1
	fi

	copy "${CSD}" "${CTD}"
	copy "${CTD}/files" "${WORKDIR}/linux-${KV_FULL}"
	cd "${CTD}/patches-${OPENWRT_VER}" || die "${RED}cd ${CTD}/patches-${OPENWRT_VER} failed${NORMAL}"

	find . -type f -name "2*" -exec rm -rf "{}" \;
	find . -type f -name "8*" -exec rm -rf "{}" \;
	find . -type f -name "9*" -exec rm -rf "{}" \;

	ls -1 | grep ".patch" > "$CWD"/patch_list

	copy "${CTD}/patches-${OPENWRT_VER}" "${CWD}"

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
openwrt_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/openwrt/patch_list" "${OPENWRT_INF}"
	move "${T}/openwrt" "${WORKDIR}/linux-${KV_FULL}-patches/openwrt"

	ApplyUserPatch "openwrt"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
openwrt_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${OPENWRT_INF}"
}

fi
