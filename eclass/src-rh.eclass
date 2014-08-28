# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: src-rh.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (27 Oct 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with rh patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with rh patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/src-rh.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "src-rh.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_SRC_RH} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_SRC_RH="recur -_+^+_- spank"

inherit patch utils rpm vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
src-rh_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${RH_VER:=${RH_VER:-"54.0.1"}} # Patchset version based on kernel-3.10.0-54.0.1.el7.src.rpm
	: ${RH_NAME:=${RH_NAME:-kernel-3.10.0-${RH_VER/KMV/$KMV}.el7}}
	SRC_URI_PREFIX="http://ftp.redhat.com/redhat/rhel/beta"
	: ${RH_SRC:=${RH_SRC:-"${SRC_URI_PREFIX}/7/source/SRPMS/${RH_NAME}.src.rpm"}} # Patchset sources url
	: ${RH_URL:=${RH_URL:-"http://www.redhat.com"}} # Patchset url
	: ${RH_INF:="${YELLOW}Red Hat Enterprise Linux kernel patches version ${GREEN}${RH_VER}${YELLOW} from ${GREEN}${RH_URL}${NORMAL}"}
	SKIP_UPDATE="1"

	debug-print "${FUNCNAME}: RH_VER=${RH_VER}"
	debug-print "${FUNCNAME}: RH_NAME=${RH_NAME}"
	debug-print "${FUNCNAME}: RH_SRC=${RH_SRC}"
	debug-print "${FUNCNAME}: RH_URL=${RH_URL}"
	debug-print "${FUNCNAME}: RH_INF=${RH_INF}"
}

src-rh_init_variables

HOMEPAGE="${HOMEPAGE} ${RH_URL}"

SRC_URI="${SRC_URI}
	rh?	( ${RH_SRC} )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
src-rh_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/rh"
	local CWD="${T}/rh"
	local CTD="${T}/rh"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"

	test -d "${WORKDIR}/linux-${KV_FULL}" >/dev/null 2>&1 || mkdir -p "${WORKDIR}/linux-${KV_FULL}"

	rpm_unpack "${RH_NAME}.src.rpm" || die

	if [ -e "linux-3.10.0-${RH_VER/KMV/$KMV}.el7.tar.xz" ]; then
		tar -xpf "linux-3.10.0-${RH_VER/KMV/$KMV}.el7.tar.xz" || die
		move "linux-3.10.0-${RH_VER/KMV/$KMV}.el7" "${S}"
	fi

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
src-rh_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	# Comment out EXTRAVERSION added by rh patch:
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" "Makefile" || die
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
src-rh_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${RH_INF}"
}

fi
