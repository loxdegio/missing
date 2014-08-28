# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: mageia.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with mageia patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with mageia patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/mageia.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "mageia.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_MAGEIA} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_MAGEIA="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
mageia_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${MAGEIA_VER:=${MAGEIA_VER:-"releases/${KSV}/1.mga4"}} # Patchset version
	: ${MAGEIA_SRC:=${MAGEIA_SRC:-"svn://svn.mageia.org/svn/packages/cauldron/kernel"}} # Patchset sources url
	: ${MAGEIA_URL:=${MAGEIA_URL:-"http://www.mageia.org"}} # Patchset url
	: ${MAGEIA_INF:=${MAGEIA_INF:-"${YELLOW}Mageia version ${GREEN}${MAGEIA_VER}${YELLOW} from ${GREEN}${MAGEIA_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: MAGEIA_VER=${MAGEIA_VER}"
	debug-print "${FUNCNAME}: MAGEIA_SRC=${MAGEIA_SRC}"
	debug-print "${FUNCNAME}: MAGEIA_URL=${MAGEIA_URL}"
	debug-print "${FUNCNAME}: MAGEIA_INF=${MAGEIA_INF}"
}

mageia_init_variables

HOMEPAGE="${HOMEPAGE} ${MAGEIA_URL}"

DEPEND="${DEPEND}
	mageia?	( dev-vcs/subversion )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
mageia_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/mageia"
	local CWD="${T}/mageia"
	local CTD="${T}/mageia"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	if [ -d ${CSD} ]; then
	cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"
		if [ -e ".svn" ]; then # subversion
			svn up
		fi
	else
		svn co "${MAGEIA_SRC}" "${CSD}" > /dev/null 2>&1
	fi

	copy "${CSD}" "${CTD}"
	cd "${CTD}"/"${MAGEIA_VER}"/PATCHES || die "${RED}cd ${CTD}/${MAGEIA_VER}/PATCHES failed${NORMAL}"

	find . -name "*.patch" | xargs -i cp "{}" "${CWD}"

	awk '{gsub(/3rd/,"#3rd") ;print $0}' patches/series > "${CWD}"/patch_list

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
mageia_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/mageia/patch_list" "${MAGEIA_INF}"
	move "${T}/mageia" "${WORKDIR}/linux-${KV_FULL}-patches/mageia"

	ApplyUserPatch "mageia"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
mageia_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${MAGEIA_INF}"
}

fi
