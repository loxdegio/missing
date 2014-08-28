# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: aufs.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with aufs3 patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with aufs3 patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/aufs.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "aufs.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_AUFS} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_AUFS="recur -_+^+_- spank"

inherit patch utils vars

EXPORT_FUNCTIONS pkg_setup src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
aufs_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${AUFS_VER:=${AUFS_VER:-"${KMV}"}} # Patchset version
	: ${AUFS_SRC:=${AUFS_SRC:-"git://git.code.sf.net/p/aufs/aufs3-standalone"}} # Patchset sources url
	: ${AUFS_URL:=${AUFS_URL:-"http://aufs.sourceforge.net"}} # Patchset url
	: ${AUFS_INF:="${YELLOW}Another UnionFS version ${GREEN}${AUFS_VER}${YELLOW} from ${GREEN}${AUFS_URL}${NORMAL}"}

	debug-print "${FUNCNAME}: AUFS_VER=${AUFS_VER}"
	debug-print "${FUNCNAME}: AUFS_SRC=${AUFS_SRC}"
	debug-print "${FUNCNAME}: AUFS_URL=${AUFS_URL}"
	debug-print "${FUNCNAME}: AUFS_INF=${AUFS_INF}"
}

aufs_init_variables

HOMEPAGE="${HOMEPAGE} ${AUFS_URL}"

DEPEND="${DEPEND}
	aufs?	( dev-vcs/git )"

# @FUNCTION: pkg_setup
# @USAGE:
# @DESCRIPTION: Pre-build environment configuration and checks.
aufs_pkg_setup() {
	debug-print-function ${FUNCNAME} "$@"

}

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
aufs_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/aufs"
	local CWD="${T}/aufs"
	local CTD="${T}/aufs"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	if [ -d "${CSD}" ]; then
		cd "${CSD}"
		if [ -e ".git" ]; then # git
			git fetch --all && git pull --all
		fi
	else
		git clone "${AUFS_SRC}" "${CSD}"
		cd "${CSD}"
		git_get_all_branches
	fi

	copy "${CSD}" "${CTD}"
	cd "${CTD}"

	dir=( "Documentation" "fs" "include" )
	local dest="${CWD}"/aufs3-${AUFS_VER}-`date +"%Y%m%d"`.patch

	git_checkout "origin/aufs${AUFS_VER}" > /dev/null 2>&1 git pull > /dev/null 2>&1

	mkdir ../a ../b || die "${RED}mkdir ../a ../b failed${NORMAL}"
	cp -r {Documentation,fs,include} ../b || die "${RED}cp -r {Documentation,fs,include} ../b failed${NORMAL}"
	if [ ${KMV} == "3.0" -o ${KMV} == "3.2" -o ${KMV} == "3.4" ]; then
		rm ../b/include/linux/Kbuild || die "${RED}rm ../b/include/linux/Kbuild failed${NORMAL}"
	else
		rm ../b/include/uapi/linux/Kbuild || die "${RED}rm ../b/include/uapi/linux/Kbuild failed${NORMAL}"
	fi
	cd .. || die "${RED}cd .. failed${NORMAL}"

	for i in "${dir[@]}"; do
		diff -U 3 -dHrN -- a/ b/"${i}"/ >> "${dest}"
		sed -i "s:a/:a/"${i}"/:" "${dest}"
		sed -i "s:b:b:" "${dest}"
	done
	rm -rf a b || die "${RED}rm -rf a b failed${NORMAL}"

	[[ -r "${CTD}/aufs3-base.patch" ]] && (cp "${CTD}"/aufs3-base.patch "${CWD}"/aufs3-base-${AUFS_VER}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-base.patch ${CWD}/aufs3-base-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}")
	[[ -r "${CTD}/aufs3-standalone.patch" ]] && (cp "${CTD}"/aufs3-standalone.patch "${CWD}"/aufs3-standalone-${AUFS_VER}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-standalone.patch ${CWD}/aufs3-standalone-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}")
	[[ -r "${CTD}/aufs3-kbuild.patch" ]] && (cp "${CTD}"/aufs3-kbuild.patch "${CWD}"/aufs3-kbuild-${AUFS_VER}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-kbuild.patch ${CWD}/aufs3-kbuild-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}")
	[[ -r "${CTD}/aufs3-proc_map.patch" ]] && (cp "${CTD}"/aufs3-proc_map.patch "${CWD}"/aufs3-proc_map-${AUFS_VER}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-proc_map.patch ${CWD}/aufs3-proc_map-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}")
	[[ -r "${CTD}/aufs3-mmap.patch" ]] && (cp "${CTD}"/aufs3-mmap.patch "${CWD}"/aufs3-mmap-${AUFS_VER}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-mmap.patch ${CWD}/aufs3-mmap-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}")
	[[ -r "${CTD}/aufs3-loopback.patch" ]] && (cp "${CTD}"/aufs3-loopback.patch "${CWD}"/aufs3-loopback-${AUFS_VER}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-loopback.patch ${CWD}/aufs3-loopback-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}")

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"

	ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
aufs_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/aufs/patch_list" "${AUFS_INF}"
	move "${T}/aufs" "${WORKDIR}/linux-${KV_FULL}-patches/aufs"

	ApplyUserPatch "aufs"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
aufs_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${AUFS_INF}"
	has_version sys-fs/aufs-util && \
		einfo "${YELLOW}In order to use vars FS you need to install ${NORMAL}${RED}sys-fs/aufs-util${NORMAL}"
	has_version sys-fs/squashfs-tools && \
		einfo "${YELLOW}In order to use rw vars FS you need to install ${NORMAL}${RED}sys-fs/squashfs-tools${NORMAL}"
}

fi
