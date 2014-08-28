# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: rt.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with rt patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with rt patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/rt.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "rt.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_RT} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_RT="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
rt_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${RT_VER:=${RT_VER:-"${KMV}"}} # Patchset version
	: ${RT_SRC:=${RT_SRC:-"mirror://kernel/linux/kernel/projects/rt/${KMV}/patch-${RT_VER/KMV/$KMV}.patch.xz"}} # Patchset sources url
	: ${RT_URL:=${RT_URL:-"http://www.kernel.org/pub/linux/kernel/projects/rt"}} # Patchset url
	: ${RT_INF:=${RT_INF:-"${YELLOW}Ingo Molnar"\'"s realtime preempt patches version ${GREEN}${RT_VER}${YELLOW} from ${GREEN}${RT_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: RT_VER=${RT_VER}"
	debug-print "${FUNCNAME}: RT_SRC=${RT_SRC}"
	debug-print "${FUNCNAME}: RT_URL=${RT_URL}"
	debug-print "${FUNCNAME}: RT_INF=${RT_INF}"
}

rt_init_variables

HOMEPAGE="${HOMEPAGE} ${RT_URL}"

SRC_URI="${SRC_URI}
	rt?	( ${RT_SRC} )"

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
rt_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/patch-${RT_VER}.patch.xz" "${RT_INF}"

	ApplyUserPatch "rt"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
rt_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${RT_INF}"
}

fi
