# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: ice.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with ice patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with ice patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/ice.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "ice.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_ICE} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_ICE="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
ice_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${ICE_VER:=${ICE_VER:-"${KMV}"}} # Patchset version
#	: ${ICE_SRC:=${ICE_SRC:-"https://github.com/NigelCunningham/tuxonice-kernel/compare/vanilla-${ICE_VER/KMV/$KMV}...tuxonice-${ICE_VER/KMV/$KMV}.diff"}} # Patchset sources url
#	: ${ICE_SRC:=${ICE_SRC:-"git://github.com/NigelCunningham/tuxonice-kernel.git"}} # Patchset sources url
	: ${ICE_SRC:=${ICE_SRC:-"http://tuxonice.net/downloads/all/tuxonice-${ICE_VER/KMV/$KMV}.patch.bz2"}} # Patchset sources url
	: ${ICE_URL:=${ICE_URL:-"http://tuxonice.net"}} # Patchset url
	: ${ICE_INF:=${ICE_INF:-"${YELLOW}TuxOnIce version ${GREEN}${ICE_VER}${YELLOW} from ${GREEN}${ICE_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: ICE_VER=${ICE_VER}"
	debug-print "${FUNCNAME}: ICE_SRC=${ICE_SRC}"
	debug-print "${FUNCNAME}: ICE_URL=${ICE_URL}"
	debug-print "${FUNCNAME}: ICE_INF=${ICE_INF}"
}

ice_init_variables

HOMEPAGE="${HOMEPAGE} ${ICE_URL}"

SRC_URI="${SRC_URI}
	ice?	( ${ICE_SRC} )"

DEPEND="${DEPEND}
	ice?	( >=sys-apps/tuxonice-userui-1.0
		|| ( >=sys-power/hibernate-script-2.0 sys-power/pm-utils ) )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
ice_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/ice"
	local CWD="${T}/ice"
#	local CTD="${T}/ice"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
#	if [ -d "${CSD}" ]; then
#		cd "${CSD}"
#		if [ -e ".git" ]; then # git
#			git fetch --all && git pull --all
#		fi
#	else
#		git clone "${ICE_SRC}" "${CSD}"
#		cd "${CSD}"
#		git_get_all_branches
#	fi

#	git_checkout "vanilla-${ICE_VER}" > /dev/null 2>&1 git pull > /dev/null 2>&1
#	git_checkout "tuxonice-${ICE_VER}" > /dev/null 2>&1 git pull > /dev/null 2>&1

#	dest="${CWD}"/tuxonice-kernel-"${PV}"-`date +"%Y%m%d"`.patch
	dest="${CWD}"/tuxonice-kernel-"${PV}"-`date +"%Y%m%d"`.patch.bz2
	wget "${ICE_SRC}" -O "${dest}" > /dev/null 2>&1
#	git diff "vanilla-${ICE_VER}" "tuxonice-${ICE_VER}" > "$dest";
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
	bunzip2 -dc tuxonice-kernel-"${PV}"-`date +"%Y%m%d"`.patch.bz2 >> tuxonice-kernel-"${PV}"-`date +"%Y%m%d"`.patch && rm -rf tuxonice-kernel-"${PV}"-`date +"%Y%m%d"`.patch.bz2
	ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
ice_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/ice/patch_list" "${ICE_INF}"
	move "${T}/ice" "${WORKDIR}/linux-${KV_FULL}-patches/ice"

	ApplyUserPatch "ice"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
ice_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	ewarn "${RED}${P}${NORMAL} ${BLUE}has the following optional runtime dependencies:${NORMAL}${BR}
  ${RED}sys-apps/tuxonice-userui${NORMAL}${BR}
    ${BLUE}provides minimal userspace progress information related to${NORMAL}${BR}
    ${BLUE}suspending and resuming process${NORMAL}${BR}
  ${RED}sys-power/hibernate-script${NORMAL} ${BLUE}or${NORMAL} ${RED}sys-power/pm-utils${NORMAL}${BR}
    ${BLUE}runtime utilites for hibernating and suspending your computer${NORMAL}${BR}
${BR}
${BLUE}If there are issues with this kernel, please direct any${NORMAL}${BR}
${BLUE}queries to the tuxonice-users mailing list:${NORMAL}${BR}
${RED}http://lists.tuxonice.net/mailman/listinfo/tuxonice-users/${NORMAL}${BR}"
}

fi
