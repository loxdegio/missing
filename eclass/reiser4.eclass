# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: reiser4.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with reiser4 patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with reiser4 patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/reiser4.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "reiser4.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_REISER4} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_REISER4="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
reiser4_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${REISER4_VER:=${REISER4_VER:-"${KMV}"}} # Patchset version
	: ${REISER4_SRC:=${REISER4_SRC:-"mirror://sourceforge/project/reiser4/reiser4-for-linux-3.x/reiser4-for-${REISER4_VER/PV/$PV}.patch.gz"}} # Patchset sources url
	: ${REISER4_URL:=${REISER4_URL:-"http://sourceforge.net/projects/reiser4"}} # Patchset url
	: ${REISER4_INF:=${REISER4_INF:-"${YELLOW}ReiserFS v4 version ${GREEN}${REISER4_VER}${YELLOW} from ${GREEN}${REISER4_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: REISER4_VER=${REISER4_VER}"
	debug-print "${FUNCNAME}: REISER4_SRC=${REISER4_SRC}"
	debug-print "${FUNCNAME}: REISER4_URL=${REISER4_URL}"
	debug-print "${FUNCNAME}: REISER4_INF=${REISER4_INF}"
}

reiser4_init_variables

HOMEPAGE="${HOMEPAGE} ${REISER4_URL}"

DEPEND="${RDEPEND}
	reiser4?        ( >=sys-fs/reiser4progs-1.0.6 )"

SRC_URI="${SRC_URI}
	reiser4?	( ${REISER4_SRC} )"

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
reiser4_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/reiser4-for-${REISER4_VER}.patch.gz" "${REISER4_INF}"

	ApplyUserPatch "reiser4"
}


# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
reiser4_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	if ! has_version sys-fs/reiser4progs; then
		ewarn
		ewarn "${BLUE}In order to use Reiser4 FS you need to install${NORMAL} ${RED}sys-fs/reiser4progs${NORMAL}"
		ewarn
	fi
}

fi
