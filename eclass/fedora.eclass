# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: fedora.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with fedora patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with fedora patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/fedora.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "fedora.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_FEDORA} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_FEDORA="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
fedora_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${FEDORA_VER:=${FEDORA_VER:-"master"}} # Patchset version
	: ${FEDORA_SRC:=${FEDORA_SRC:-"git://pkgs.fedoraproject.org/kernel.git"}} # Patchset sources url
	: ${FEDORA_URL:=${FEDORA_URL:-"http://fedoraproject.org"}} # Patchset url
	: ${FEDORA_INF:=${FEDORA_INF:-"${YELLOW}Fedora version ${GREEN}${FEDORA_VER}${YELLOW} from ${GREEN}${FEDORA_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: FEDORA_VER=${FEDORA_VER}"
	debug-print "${FUNCNAME}: FEDORA_SRC=${FEDORA_SRC}"
	debug-print "${FUNCNAME}: FEDORA_URL=${FEDORA_URL}"
	debug-print "${FUNCNAME}: FEDORA_INF=${FEDORA_INF}"
}

fedora_init_variables

HOMEPAGE="${HOMEPAGE} ${FEDORA_URL}"

DEPEND="${DEPEND}
	fedora?	( dev-vcs/git )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
fedora_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/fedora"
	local CWD="${T}/fedora"
	local CTD="${T}/fedora"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	if [ -d ${CSD} ]; then
		cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"
		if [ -e ".git" ]; then # git
			git fetch --all && git pull --all
		fi
	else
		git clone "${FEDORA_SRC}" "${CSD}" > /dev/null 2>&1; cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"; git_get_all_branches
	fi

	copy "${CSD}" "${CTD}"
	cd "${CTD}" || die "${RED}cd ${CTD} failed${NORMAL}"

	git_checkout "${FEDORA_VER}" > /dev/null 2>&1 git pull > /dev/null 2>&1

	ls -1 | grep ".patch" | xargs -I{} cp "{}" "${CWD}"

	awk '/^Apply.*Patch.*\.patch/{print $2}' kernel.spec > "$CWD"/patch_list

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
fedora_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/fedora/patch_list" "${FEDORA_INF}"
	move "${T}/fedora" "${WORKDIR}/linux-${KV_FULL}-patches/fedora"

	ApplyUserPatch "fedora"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
fedora_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${FEDORA_INF}"
}

fi
