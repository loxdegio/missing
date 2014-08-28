# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: src-uek.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (26 Feb 2014)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with uek patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel based on Oracle’s Unbreakable Enterprise Linux Kernel.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/src-uek.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "src-uek.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_SRC_UEK} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_SRC_UEK="recur -_+^+_- spank"

inherit patch utils rpm vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
src-uek_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${KMV} = "2.6" ]]; then
		: ${UEK_VER:=${UEK_VER:-"400.34.3"}} # Patchset version based on kernel-uek-2.6.32-400.34.3.el6uek.src.rpm
		: ${UEK_NAME:=${UEK_NAME:-kernel-uek-${KSV}-${UEK_VER/KMV/$KMV}.el6uek}}
		SRC_URI_PREFIX="https://oss.oracle.com/ol6"
		: ${UEK_SRC:=${UEK_SRC:-"${SRC_URI_PREFIX}/SRPMS-updates/${UEK_NAME}.src.rpm"}} # Patchset sources url
	#elif [[ ${KMV} = "3.8" ]]; then
	fi
	: ${UEK_URL:=${UEK_URL:-"https://linux.oracle.com/pls/apex/f?p=101:3"}} # Patchset url
	: ${UEK_INF:="${YELLOW}Oracle’s Unbreakable Enterprise Linux Kernel version ${GREEN}${UEK_VER}${YELLOW} from ${GREEN}${UEK_URL}${NORMAL}"}

	debug-print "${FUNCNAME}: UEK_VER=${UEK_VER}"
	debug-print "${FUNCNAME}: UEK_NAME=${UEK_NAME}"
	debug-print "${FUNCNAME}: UEK_SRC=${UEK_SRC}"
	debug-print "${FUNCNAME}: UEK_URL=${UEK_URL}"
	debug-print "${FUNCNAME}: UEK_INF=${UEK_INF}"
}

src-uek_init_variables

HOMEPAGE="${HOMEPAGE} ${UEK_URL}"

SRC_URI="${SRC_URI}
	uek?	( ${UEK_SRC} )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
src-uek_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/uek"
	local CWD="${T}/uek"
	local CTD="${T}/uek"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"

	if [[ ${KMV} = "2.6" ]]; then
		test -d "${WORKDIR}/linux-${KV_FULL}" >/dev/null 2>&1 || mkdir -p "${WORKDIR}/linux-${KV_FULL}"

		rpm_unpack "${UEK_NAME}.src.rpm" || die

		if [ -e "linux-${KSV}.tar.bz2" ]; then
			tar -xpf "linux-${KSV}.tar.bz2" || die
			move "linux-${KSV}" "${S}"
		fi

		rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
	#elif [[ ${KMV} = "3.8" ]]; then
	fi
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
src-uek_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	# Comment out EXTRAVERSION added by uek patch:
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" "Makefile" || die
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
src-uek_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${UEK_INF}"
}

fi
