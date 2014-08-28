# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: brand.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building kernel with gentoo branding patchset.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel with gentoo branding patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/brand.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "brand.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_BRAND} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_BRAND="recur -_+^+_- spank"

inherit patch

EXPORT_FUNCTIONS src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
brand_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${IUSE:="${IUSE} brand"}
	: ${BRAND_URL:=${BRAND_URL:-"https://github.com/init6/init_6/wiki/geek-sources"}} # Patchset url
	: ${BRAND_INF:=${BRAND_INF:-"${YELLOW}Branding from ${GREEN}${BRAND_URL}${NORMAL}"}}

	debug-print "${FUNCNAME}: BRAND_URL=${BRAND_URL}"
	debug-print "${FUNCNAME}: BRAND_INF=${BRAND_INF}"
}

brand_init_variables

HOMEPAGE="${HOMEPAGE} ${BRAND_URL}"

DEPEND="${DEPEND}
	brand?	( >=media-fonts/iso_latin_1-0.0.5 )"

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
brand_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${FILESDIR}/${PV}/brand/patch_list" "${BRAND_INF}"

	ApplyUserPatch "brand"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
brand_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${BRAND_INF}"
}

fi
