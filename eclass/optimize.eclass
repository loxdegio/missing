# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: optimize.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (19 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with optimize patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with optimize patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/optimize.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "optimize.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_OPTIMIZATION} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_OPTIMIZATION="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
optimize_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${OPTIMIZATION_VER:=${OPTIMIZATION_VER:-""}} # Patchset version
	: ${OPTIMIZATION_SRC:=${OPTIMIZATION_SRC:-"https://github.com/graysky2/kernel_gcc_patch/raw/master/enable_additional_cpu_optimizations_for_gcc.patch"}} # Patchset sources url
	: ${OPTIMIZATION_URL:=${OPTIMIZATION_URL:-"https://github.com/graysky2/kernel_gcc_patch"}} # Patchset url
	: ${OPTIMIZATION_INF:=${OPTIMIZATION_INF:-"${YELLOW}Kernel patch enables gcc optimizations for additional CPUs version ${GREEN}${OPTIMIZATION_VER}${YELLOW} from ${GREEN}${OPTIMIZATION_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: OPTIMIZATION_VER=${OPTIMIZATION_VER}"
	debug-print "${FUNCNAME}: OPTIMIZATION_SRC=${OPTIMIZATION_SRC}"
	debug-print "${FUNCNAME}: OPTIMIZATION_URL=${OPTIMIZATION_URL}"
	debug-print "${FUNCNAME}: OPTIMIZATION_INF=${OPTIMIZATION_INF}"
}

optimize_init_variables

HOMEPAGE="${HOMEPAGE} ${OPTIMIZATION_URL}"

SRC_URI="${SRC_URI}
	optimize?	( ${OPTIMIZATION_SRC} )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
optimize_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/optimize"
	local CWD="${T}/optimize"
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	dest="${CWD}"/enable_additional_cpu_optimizations_for_gcc.patch
	wget "${OPTIMIZATION_SRC}" -O "${dest}" > /dev/null 2>&1
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
	ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
optimize_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/optimize/patch_list" "${OPTIMIZATION_INF}"
	move "${T}/optimize" "${WORKDIR}/linux-${KV_FULL}-patches/optimize"

	ApplyUserPatch "optimize"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
optimize_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${OPTIMIZATION_INF}"
}

fi
