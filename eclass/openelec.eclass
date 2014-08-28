# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: openelec.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (11 Apr 2014)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with OpenELEC patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with OpenELEC patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/openelec.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "openelec.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_OPENELEC} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_OPENELEC="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
openelec_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${OPENELEC_VER:=${OPENELEC_VER:-"${KSV}"}} # Patchset version
	: ${OPENELEC_SRC:=${OPENELEC_SRC:-"https://github.com/OpenELEC/OpenELEC.tv/trunk/packages/linux"}} # Patchset sources url
	: ${OPENELEC_URL:=${OPENELEC_URL:-"http://openelec.tv"}} # Patchset url
	: ${OPENELEC_INF:=${OPENELEC_INF:-"${YELLOW}OpenELEC version ${GREEN}${OPENELEC_VER}${YELLOW} from ${GREEN}${OPENELEC_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: OPENELEC_VER=${OPENELEC_VER}"
	debug-print "${FUNCNAME}: OPENELEC_SRC=${OPENELEC_SRC}"
	debug-print "${FUNCNAME}: OPENELEC_URL=${OPENELEC_URL}"
	debug-print "${FUNCNAME}: OPENELEC_INF=${OPENELEC_INF}"
}

openelec_init_variables

HOMEPAGE="${HOMEPAGE} ${OPENELEC_URL}"

DEPEND="${DEPEND}
	openelec?	( dev-vcs/subversion )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
openelec_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/openelec"
	local CWD="${T}/openelec"
	local CTD="${T}/openelec"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	if [ -d ${CSD} ]; then
	cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"
		if [ -e ".svn" ]; then # subversion
			svn up
		fi
	else
		svn co "${OPENELEC_SRC}" "${CSD}" > /dev/null 2>&1
	fi

	copy "${CSD}" "${CTD}"
	
	cd "${CTD}"/patches || die "${RED}cd ${CTD}/patches failed${NORMAL}"
	cp *.patch "${CWD}"

	cd "${CTD}"/patches/"${OPENELEC_VER}" || die "${RED}cd ${CTD}/patches/${OPENELEC_VER} failed${NORMAL}"
	find . -name "*.patch" | xargs -i cp "{}" "${CWD}"

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"

	ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
openelec_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/openelec/patch_list" "${OPENELEC_INF}"
	move "${T}/openelec" "${WORKDIR}/linux-${KV_FULL}-patches/openelec"

	ApplyUserPatch "openelec"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
openelec_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${OPENELEC_INF}"
}

fi
