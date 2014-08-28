# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: vars.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (14 Nov 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: The vars eclass defines some default variables.
# @DESCRIPTION:
# The vars eclass defines some default variables.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/vars.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "vars.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_VARS} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_VARS="recur -_+^+_- spank"

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
vars_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	OLDIFS="$IFS"
	VER="${PV}"
	IFS='.'
	set -- ${VER}
	IFS="${OLDIFS}"

	VERSION="${1}" # the kernel version (e.g 3 for 3.4.2)
	PATCHLEVEL="${2}" # the kernel patchlevel (e.g 4 for 3.4.2)
	SUBLEVEL="${3}" # the kernel sublevel (e.g 2 for 3.4.2)
	KMV="${1}.${2}" # the kernel major version (e.g 3.4 for 3.4.2)
	KSV="${1}.${2}.${3}" # the original kernel version (eg 2.6.0 for 2.6.0-test11)

	: ${cfg_file:="/etc/portage/kernel.conf"}

	: ${GEEK_STORE_DIR:=${GEEK_STORE_DIR:-"${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/geek"}}
	addwrite "${GEEK_STORE_DIR}" # Disable the sandbox for this dir

	: ${PATCH_STORE_DIR:=${PATCH_STORE_DIR:-"/etc/portage/patches/sys-kernel"}}
	: ${PATCH_USER_DIR:=${PATCH_USER_DIR:-"${PATCH_STORE_DIR}/${PN}/${PV}"}}

	# Color
	local use_colors_cfg=$(source $cfg_file 2>/dev/null; echo ${use_colors})
	: ${use_colors:=${use_colors_cfg:-yes}} # use_colors=yes/no
	check_for_color

	debug-print "${FUNCNAME}: VERSION=${VERSION}"
	debug-print "${FUNCNAME}: PATCHLEVEL=${PATCHLEVEL}"
	debug-print "${FUNCNAME}: SUBLEVEL=${SUBLEVEL}"
	debug-print "${FUNCNAME}: KMV=${KMV}"
	debug-print "${FUNCNAME}: KSV=${KSV}"
	debug-print "${FUNCNAME}: cfg_file=${cfg_file}"
	debug-print "${FUNCNAME}: GEEK_STORE_DIR=${GEEK_STORE_DIR}"
	debug-print "${FUNCNAME}: PATCH_STORE_DIR=${PATCH_STORE_DIR}"
	debug-print "${FUNCNAME}: PATCH_USER_DIR=${PATCH_USER_DIR}"
	debug-print "${FUNCNAME}: use_colors=${use_colors}"
}

set_color() {
	: ${BR:=${BR:-"\x1b[0;01m"}}
	#: ${BLUEDARK:=${BLUEDARK:-"\x1b[34;0m"}}
	: ${BLUE:=${BLUE:-"\x1b[34;01m"}}
	#: ${CYANDARK:=${CYANDARK:-"\x1b[36;0m"}}
	: ${CYAN:=${CYAN:-"\x1b[36;01m"}}
	#: ${GRAYDARK:=${GRAYDARK:-"\x1b[30;0m"}}
	#: ${GRAY:=${GRAY:-"\x1b[30;01m"}}
	#: ${GREENDARK:=${GREENDARK:-"\x1b[32;0m"}}
	: ${GREEN:=${GREEN:-"\x1b[32;01m"}}
	#: ${LIGHT:=${LIGHT:-"\x1b[37;01m"}}
	#: ${MAGENTADARK:=${MAGENTADARK:-"\x1b[35;0m"}}
	#: ${MAGENTA:=${MAGENTA:-"\x1b[35;01m"}}
	: ${NORMAL:=${NORMAL:-"\x1b[0;0m"}}
	#: ${REDDARK:=${REDDARK:-"\x1b[31;0m"}}
	: ${RED:=${RED:-"\x1b[31;01m"}}
	: ${YELLOW:=${YELLOW:-"\x1b[33;01m"}}
}

set_no_color() {
	: ${BR:=${BR:-"\x1b[0;01m"}}
	#: ${BLUEDARK:=${BLUEDARK:-""}}
	: ${BLUE:=${BLUE:-""}}
	#: ${CYANDARK:=${CYANDARK:-""}}
	: ${CYAN:=${CYAN:-""}}
	#: ${GRAYDARK:=${GRAYDARK:-""}}
	#: ${GRAY:=${GRAY:-""}}
	#: ${GREENDARK:=${GREENDARK:-""}}
	: ${GREEN:=${GREEN:-""}}
	#: ${LIGHT:=${LIGHT:-""}}
	#: ${MAGENTADARK:=${MAGENTADARK:-""}}
	#: ${MAGENTA:=${MAGENTA:-""}}
	: ${NORMAL:=${NORMAL:-""}}
	#: ${REDDARK:=${REDDARK:-""}}
	: ${RED:=${RED:-""}}
	: ${YELLOW:=${YELLOW:-""}}
}

check_for_color() {
	if [[ ! ${use_colors} == no ]]; then
		set_color
	else
		set_no_color
	fi
}

vars_init_variables

fi
