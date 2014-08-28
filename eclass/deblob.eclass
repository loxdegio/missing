# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: deblob.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building deblobbed kernel.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# deblobbed easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/deblob.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "deblob.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_DEBLOB} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_DEBLOB="recur -_+^+_- spank"

inherit vars

EXPORT_FUNCTIONS src_unpack src_compile pkg_postinst

if [[ ${DEBLOB_AVAILABLE} == "1" ]]; then
	: ${IUSE:="${IUSE} deblob"}
	# Reflect that kernels contain firmware blobs unless otherwise
	# stripped
	: ${LICENSE:="${LICENSE} !deblob? ( freedist )"}

	if [[ -n PATCHLEVEL ]]; then
		DEBLOB_PV="${VERSION}.${PATCHLEVEL}.${SUBLEVEL}"
	else
		DEBLOB_PV="${VERSION}.${SUBLEVEL}"
	fi

	if [[ "${VERSION}" -ge 3 ]]; then
		DEBLOB_PV="${VERSION}.${PATCHLEVEL}"
	fi

	DEBLOB_A="deblob-${DEBLOB_PV}"
	DEBLOB_CHECK_A="deblob-check-${DEBLOB_PV}"
	DEBLOB_HOMEPAGE="http://linux-libre.fsfla.org/pub/linux-libre"
	DEBLOB_URI_PATH="releases/LATEST-${DEBLOB_PV}.N"
	if ! has "${EAPI:-0}" 0 1; then
		DEBLOB_CHECK_URI="${DEBLOB_HOMEPAGE}/${DEBLOB_URI_PATH}/deblob-check -> ${DEBLOB_CHECK_A}"
	else
		DEBLOB_CHECK_URI="mirror://gentoo/${DEBLOB_CHECK_A}"
	fi
	DEBLOB_URI="${DEBLOB_HOMEPAGE}/${DEBLOB_URI_PATH}/${DEBLOB_A}"
	: ${HOMEPAGE:="${HOMEPAGE} ${DEBLOB_HOMEPAGE}"}

	: ${SRC_URI:="${SRC_URI}
		deblob? (
			${DEBLOB_URI}
			${DEBLOB_CHECK_URI}
		)"}
else
	# We have no way to deblob older kernels, so just mark them as
	# tainted with non-libre materials.
	: ${LICENSE:="${LICENSE} freedist"}
fi

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
deblob_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob; then
		cp "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/${DEBLOB_A}" "${T}" || die "${RED}cp ${DEBLOB_A} failed${NORMAL}"
		cp "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/${DEBLOB_CHECK_A}" "${T}/deblob-check" || die "${RED}cp ${DEBLOB_CHECK_A} failed${NORMAL}"
		chmod +x "${T}/${DEBLOB_A}" "${T}/deblob-check" || die "${RED}chmod deblob scripts failed${NORMAL}"
	fi
}

# @FUNCTION: src_compile
# @USAGE:
# @DESCRIPTION: Configure and build the package.
deblob_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob; then
		echo ">>> Running deblob script ..."
		sh "${T}/${DEBLOB_A}" --force || \
			die "${RED}Deblob script failed to run!!!${NORMAL}"
	fi
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
deblob_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo " ${BLUE}Deblobbed kernels are UNSUPPORTED by Gentoo Security.${NORMAL}"
}

fi
