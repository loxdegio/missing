# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: rsbac.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (10 Oct 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with rsbac patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with rsbac patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/rsbac.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "rsbac.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_RSBAC} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_RSBAC="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
rsbac_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${RSBAC_VER:=${RSBAC_VER:-"${KMV}"}} # Patchset version
	: ${RSBAC_NAME:=${RSBAC_NAME:-patch-linux-${PV}-rsbac-${RSBAC_VER/KMV/$KMV}.diff.xz}}
	: ${RSBAC_SRC:=${RSBAC_SRC:-"http://download.rsbac.org/patches/${RSBAC_VER/KMV/$KMV}/${RSBAC_NAME}"}} # Patchset sources url
	: ${RSBAC_URL:=${RSBAC_URL:-"http://www.rsbac.org"}} # Patchset url
	: ${RSBAC_INF:=${RSBAC_INF:-"${YELLOW}RSBAC (Rule Set Based Access Control) patches version ${GREEN}${RSBAC_VER}${YELLOW} from ${GREEN}${RSBAC_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: RSBAC_VER=${RSBAC_VER}"
	debug-print "${FUNCNAME}: RSBAC_NAME=${RSBAC_NAME}"
	debug-print "${FUNCNAME}: RSBAC_SRC=${RSBAC_SRC}"
	debug-print "${FUNCNAME}: RSBAC_URL=${RSBAC_URL}"
	debug-print "${FUNCNAME}: RSBAC_INF=${RSBAC_INF}"
}

rsbac_init_variables

HOMEPAGE="${HOMEPAGE} ${RSBAC_URL}"

SRC_URI="${SRC_URI}
	rsbac?	( ${RSBAC_SRC} )"

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
rsbac_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/${RSBAC_NAME}" "${RSBAC_INF}"

	ApplyUserPatch "rsbac"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
rsbac_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${RSBAC_INF}"
}

fi
