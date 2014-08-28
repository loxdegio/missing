# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: suse.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with suse patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with suse patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/suse.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "suse.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_SUSE} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_SUSE="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
suse_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${SUSE_VER:=${SUSE_VER:-"stable"}} # Patchset version
	: ${SUSE_SRC:=${SUSE_SRC:-"git://kernel.opensuse.org/kernel-source.git"}} # Patchset sources url
	: ${SUSE_URL:=${SUSE_URL:-"http://www.opensuse.org"}} # Patchset url
	: ${SUSE_INF:=${SUSE_INF:-"${YELLOW}OpenSuSE patches version ${GREEN}${SUSE_VER}${YELLOW} from ${GREEN}${SUSE_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: SUSE_VER=${SUSE_VER}"
	debug-print "${FUNCNAME}: SUSE_SRC=${SUSE_SRC}"
	debug-print "${FUNCNAME}: SUSE_URL=${SUSE_URL}"
	debug-print "${FUNCNAME}: SUSE_INF=${SUSE_INF}"
}

suse_init_variables

HOMEPAGE="${HOMEPAGE} ${SUSE_URL}"

DEPEND="${DEPEND}
	suse?	( dev-vcs/git )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
suse_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/suse"
	local CWD="${T}/suse"
	local CTD="${T}/suse"$$
	shift
	cd "${CSD}" >/dev/null 2>&1
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	if [ -d ${CSD} ]; then
	cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"
		if [ -e ".git" ]; then # git
			git fetch --all && git pull --all
		fi
	else
		git clone "${SUSE_SRC}" "${CSD}" > /dev/null 2>&1; cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"; git_get_all_branches
	fi

	copy "${CSD}" "${CTD}"

	cd "${CTD}" || die "${RED}cd ${CTD} failed${NORMAL}"

	git_checkout "${SUSE_VER}" > /dev/null 2>&1 git pull > /dev/null 2>&1

	[ -d "patches.kernel.org" ] && rm -rf "patches.kernel.org" > /dev/null 2>&1
	[ -d "patches.rpmify" ] && rm -rf "patches.rpmify" > /dev/null 2>&1

	awk '!/(#|^$)/ && !/^(\+(needs|tren|trenn|hare|xen|jbeulich|jeffm|agruen|still|philips|disabled|olh))|patches\.(kernel|rpmify|xen).*/{gsub(/[ \t]/,"") ; print $1}' series.conf > patch_list
	grep patches.xen series.conf > spatch_list

	cp -r /usr/portage/distfiles/geek/suse/patches.*/ "${CWD}" || die "${RED}cp -r /usr/portage/distfiles/geek/suse/patches.*/ ${CWD} failed${NORMAL}"
	cp patch_list "${CWD}" || die "${RED}cp patch_list ${CWD} failed${NORMAL}"
	cp spatch_list "${CWD}" || die "${RED}cp spatch_list ${CWD} failed${NORMAL}"

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
suse_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/suse/patch_list" "${SUSE_INF}"
	ApplyPatch "${T}/suse/spatch_list" "${YELLOW}OpenSuSE xen - ${SUSE_URL}${NORMAL}"
	move "${T}/suse" "${WORKDIR}/linux-${KV_FULL}-patches/suse"

	ApplyUserPatch "suse"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
suse_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${SUSE_INF}"
}

fi
