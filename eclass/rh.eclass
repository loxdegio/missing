# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: rh.eclass
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
# https://github.com/init6/init_6/blob/master/eclass/rh.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "rh.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_RH} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_RH="recur -_+^+_- spank"

inherit patch utils rpm vars

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
rh_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${KMV} = "2.6" ]]; then
		: ${RH_VER:=${RH_VER:-"19"}} # Patchset version based on kernel-2.6.32-19.el6.src.rpm
		: ${RH_NAME:=${RH_NAME:-kernel-${VERSION}.${PATCHLEVEL}.${SUBLEVEL}-${RH_VER/KMV/$KMV}.el6}}
		SRC_URI_PREFIX="http://ftp.redhat.com/pub/redhat/linux/enterprise"
		: ${RH_SRC:=${RH_SRC:-"${SRC_URI_PREFIX}/6Client/en/os/SRPMS/${RH_NAME}.src.rpm
		${SRC_URI_PREFIX}/6ComputeNode/en/os/SRPMS/${RH_NAME}.src.rpm
		${SRC_URI_PREFIX}/6Server/en/os/SRPMS/${RH_NAME}.src.rpm
		${SRC_URI_PREFIX}/6Workstation/en/os/SRPMS/${RH_NAME}.src.rpm"}} # Patchset sources url
	fi
	: ${RH_URL:=${RH_URL:-"http://www.redhat.com"}} # Patchset url
	: ${RH_INF:="${YELLOW}Red Hat Enterprise Linux kernel patches version ${GREEN}${RH_VER}${YELLOW} from ${GREEN}${RH_URL}${NORMAL}"}

	debug-print "${FUNCNAME}: RH_VER=${RH_VER}"
	debug-print "${FUNCNAME}: RH_NAME=${RH_NAME}"
	debug-print "${FUNCNAME}: RH_SRC=${RH_SRC}"
	debug-print "${FUNCNAME}: RH_URL=${RH_URL}"
	debug-print "${FUNCNAME}: RH_INF=${RH_INF}"
}

rh_init_variables

HOMEPAGE="${HOMEPAGE} ${RH_URL}"

SRC_URI="${SRC_URI}
	rh?	( ${RH_SRC} )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
rh_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/rh"
	local CWD="${T}/rh"
	local CTD="${T}/rh"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"

	if [[ ${KMV} = "2.6" ]]; then
		rpm_unpack "${RH_NAME}.src.rpm" || die

		if [ -e "${WORKDIR}/${RH_NAME}.tar.bz2" ]; then
			tar -xpf "${WORKDIR}/${RH_NAME}.tar.bz2" || die
			mv "${RH_NAME}" "${S}" || die
			rm -f "${WORKDIR}/${RH_NAME}.tar.bz2" || die
		fi

		# Delete crap patches from rh patchset
		local rh_crap_patch="linux-2.6.32.tar.bz2 redhat-Include-FIPS-required-checksum-of-the-kernel-image.patch redhat-Silence-tagging-messages-by-rh-release.patch redhat-Disabling-debug-options-for-beta.patch redhat-updating-lastcommit-for-2-6-31-50.patch redhat-fix-BZ-and-CVE-info-printing-on-changelog-when-HIDE_REDHAT-is-enabled.patch redhat-updating-lastcommit-for-2-6-31-51.patch redhat-Fix-version-passed-to-update_changelog-sh.patch redhat-updating-lastcommit-for-2-6-32-0-52.patch redhat-fix-STAMP-version-on-rh-release-commit-phase.patch redhat-enable-debug-builds-also-on-s390x-and-ppc64.patch redhat-updating-lastcommit-for-2-6-32-0-53.patch redhat-fixing-wrong-bug-number-536759-536769.patch redhat-adding-top-makefile-to-enable-rh-targets.patch redhat-updating-lastcommit-for-2-6-32-0-54.patch redhat-updating-lastcommit-for-2-6-32-1.patch redhat-update-build-targets-in-Makefile.patch redhat-include-missing-System-map-file-for-debug-only-builds.patch redhat-updating-lastcommit-for-2-6-32-2.patch redhat-force-to-run-rh-key-target-when-compiling-the-kernel-locally-without-RPM.patch redhat-fixing-lastcommit-contents-for-2-6-32-2-el6.patch redhat-updating-lastcommit-for-2-6-32-3.patch redhat-excluding-Reverts-from-changelog-too.patch redhat-updating-lastcommit-for-2-6-32-4.patch redhat-updating-lastcommit-for-2-6-32-5.patch redhat-check-if-patchutils-is-installed-before-creating-patches.patch redhat-do-a-basic-sanity-check-to-verify-the-modules-are-being-signed.patch redhat-updating-lastcommit-for-2-6-32-6.patch redhat-updating-lastcommit-for-2-6-32-7.patch redhat-updating-lastcommit-for-2-6-32-8.patch redhat-updating-lastcommit-for-2-6-32-9.patch redhat-updating-lastcommit-for-2-6-32-10.patch redhat-updating-lastcommit-for-2-6-32-11.patch redhat-updating-lastcommit-for-2-6-32-12.patch redhat-updating-lastcommit-for-2-6-32-13.patch redhat-updating-lastcommit-for-2-6-32-14.patch redhat-updating-lastcommit-for-2-6-32-15.patch redhat-updating-lastcommit-for-2-6-32-16.patch redhat-updating-lastcommit-for-2-6-32-17.patch redhat-updating-lastcommit-for-2-6-32-18.patch linux-kernel-test.patch"
		for file in $(echo "${rh_crap_patch}" | tr ' ' '\n'); do
			[ -e "${CWD}/${file}" ] && rm -rf "${CWD}/${file}" # >/dev/null 2>&1
		done;

		rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"

		cat kernel.spec | sed '1,/make -f %{SOURCE20} VERSION=%{version} configs/d; /ApplyOptionalPatch linux-kernel-test.patch/,$d' | sed 's/ApplyPatch //' > "${CWD}"/patch_list
		for file in $(echo "${rh_crap_patch}" | tr ' ' '\n'); do
			sed -i "/$file/d" "${CWD}"/patch_list;
		done
	fi
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
rh_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${KMV} = "2.6" ]]; then
		# now 2.6.32
		ApplyPatch "${T}/rh/patch_list" "${RH_INF}"
		# now 2.6.32.18
		move "${T}/rh" "${WORKDIR}/linux-${KV_FULL}-patches/rh"
#	elif [[ ${KMV} = "3.10" ]]; then
	fi

	# Comment out EXTRAVERSION added by rh patch:
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" "Makefile" || die
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
rh_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${RH_INF}"
}

fi
