# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: patch.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for do all work with patches.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for work
# with patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/patch.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "patch.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_PATCH} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_PATCH="recur -_+^+_- spank"

inherit vars

EXPORT_FUNCTIONS ApplyPatch ApplyUserPatch

DEPEND="${DEPEND}
	app-arch/bzip2
	app-arch/gzip
	app-arch/lrzip
	app-arch/unzip
	app-arch/xz-utils"

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
patch_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${patch_cmd:=${patch_cmd:-"patch -p1 -g1 --no-backup-if-mismatch"}}

	local crap_patch_cfg=$(source $cfg_file 2>/dev/null; echo ${crap_patch})
	: ${crap_patch:=${crap_patch_cfg:-ignore}} # crap_patch=ignore/will_not_pass

	debug-print "${FUNCNAME}: patch_cmd=${patch_cmd}"
	debug-print "${FUNCNAME}: crap_patch=${crap_patch}"
}

patch_init_variables

# iternal function
#
# @FUNCTION: get_patch_cmd
# @USAGE: get_patch_cmd
# @DESCRIPTION: Get argument to patch
get_patch_cmd () {
	debug-print-function ${FUNCNAME} "$@"

	case "$crap_patch" in
	ignore) patch_cmd="patch -p1 -g1 --no-backup-if-mismatch" ;;
	will_not_pass) patch_cmd="patch -p1 -g1" ;;
	esac

	debug-print "$FUNCNAME: crap_patch=$crap_patch"
	debug-print "$FUNCNAME: patch_cmd=$patch_cmd"
}

# iternal function
#
# @FUNCTION: get_test_patch_cmd
# @USAGE: get_test_patch_cmd
# @DESCRIPTION: Get test argument to patch
get_test_patch_cmd () {
	debug-print-function ${FUNCNAME} "$@"

	case "$crap_patch" in # test argument to patch
	ignore) patch_cmd="patch -p1 -g1 --dry-run --no-backup-if-mismatch" ;;
	will_not_pass) patch_cmd="patch -p1 -g1 --dry-run" ;;
	esac

	debug-print "$FUNCNAME: crap_patch=$crap_patch"
	debug-print "$FUNCNAME: patch_cmd=$patch_cmd"
}

# iternal function
#
# @FUNCTION: ExtractApply
# @USAGE: ExtractApply "<patch>"
# @DESCRIPTION: Extract patch from *.gz, *.bz, *.bz2, *.lrz, *.xz, *.zip, *.Z
# *.gz       -> gunzip -dc    -> app-arch/gzip
# *.bz|*.bz2 -> bunzip -dc    -> app-arch/bzip2
# *.lrz      -> lrunzip -dc   -> app-arch/lrzip
# *.xz       -> xz -dc        -> app-arch/xz-utils
# *.zip      -> unzip -d      -> app-arch/unzip
# *.Z        -> uncompress -c -> app-arch/gzip
ExtractApply() {
	debug-print-function ${FUNCNAME} "$@"

	[[ ${#} -ne 1 ]] && die "Invalid number of args to ${FUNCNAME}()";

	local patch=$1

	shift
	case "$patch" in
	*.gz)       gunzip -dc    < "$patch" | $patch_cmd ${1+"$@"} ;; # app-arch/gzip
	*.bz|*.bz2) bunzip2 -dc   < "$patch" | $patch_cmd ${1+"$@"} ;; # app-arch/bzip2
	*.lrz)      lrunzip -dc   < "$patch" | $patch_cmd ${1+"$@"} ;; # app-arch/lrzip
	*.xz)       xz -dc        < "$patch" | $patch_cmd ${1+"$@"} ;; # app-arch/xz-utils
	*.zip)      unzip -d      < "$patch" | $patch_cmd ${1+"$@"} ;; # app-arch/unzip
	*.Z)        uncompress -c < "$patch" | $patch_cmd ${1+"$@"} ;; # app-arch/gzip
	*) $patch_cmd ${1+"$@"} < "$patch" ;;
	esac

	debug-print "$FUNCNAME: patch=$patch"
	debug-print "$FUNCNAME: patch_cmd=$patch_cmd"
}

# internal function
#
# @FUNCTION: Handler
# @USAGE:
# @DESCRIPTION:
# Check the availability of a patch on the path passed
# Check that the patch was not an empty
# Test run patch with 'patch -p1 --dry-run'
# All tests completed successfully? run ExtractApply
Handler() {
	debug-print-function ${FUNCNAME} "$@"

	[[ ${#} -ne 1 ]] && die "Invalid number of args to ${FUNCNAME}()";

	local patch="${1}"
	local patch_base_name=$(basename "$patch")
	debug-print "$FUNCNAME: patch=$patch"
	debug-print "$FUNCNAME: patch_base_name=$patch_base_name"

	shift
	if [ ! -f "$patch" ]; then
		ewarn "${BLUE}Patch${NORMAL} ${RED}$patch${NORMAL} ${BLUE}does not exist.${NORMAL}"
		debug-print "$FUNCNAME: $patch does not exist."
	fi
	case "$patch" in
	*.gz|*.bz|*.bz2|*.lrz|*.xz|*.zip|*.Z)
		if [[ -s "$patch" ]]; then # !=0
			get_test_patch_cmd
			if ExtractApply "$patch" &>/dev/null; then
				get_patch_cmd
				ExtractApply "$patch" &>/dev/null
			else
				ewarn "${BLUE}Skipping patch -->${NORMAL} ${RED}$patch_base_name${NORMAL}"
				debug-print "$FUNCNAME: $patch_base_name has been skipped."
				return 1
			fi
		else
			ewarn "${BLUE}Skipping missing or empty patch -->${NORMAL} ${RED}$patch_base_name${NORMAL}"
		fi ;;
	*)	if [[ $(grep -c ^ "$patch") -gt 8 ]]; then # 8 lines
			get_test_patch_cmd
			if ExtractApply "$patch" &>/dev/null; then
				get_patch_cmd
				ExtractApply "$patch" &>/dev/null
			else
				ewarn "${BLUE}Skipping patch -->${NORMAL} ${RED}$patch_base_name${NORMAL}"
				debug-print "$FUNCNAME: $patch_base_name has been skipped."
				return 1
			fi
		else
			ewarn "${BLUE}Skipping empty patch -->${NORMAL} ${RED}$patch_base_name${NORMAL}"
			debug-print "$FUNCNAME: $patch_base_name contains "$(grep -c ^ $patch)" lines. A should be at least 8 lines."
		fi ;;
	esac

	case "$crap_patch" in
	will_not_pass) find_crap
		if [[ "${crap}" == 1 ]]; then
			ebegin "${BLUE}Reversing crap patch <--${NORMAL} ${RED}$patch_base_name${NORMAL}"
				patch_cmd="patch -p1 -g1 -R"; # reverse argument to patch
				ExtractApply "$patch" &>/dev/null
				rm_crap
				debug-print "$FUNCNAME: Crap patch $patch_base_name has been reversed."
			eend
		fi ;;
	esac

	get_patch_cmd
}

# @FUNCTION: ApplyPatch
# @USAGE:
# ApplyPatch "${FILESDIR}/${PVR}/patch_list" "Patch set description"
# ApplyPatch "${FILESDIR}/${PVR}/spatch_list" "Patch set description"
# ApplyPatch "${FILESDIR}/<patch>" "Patch description"
# @DESCRIPTION:
# Main function
patch_ApplyPatch() {
	debug-print-function ${FUNCNAME} "$@"

	[[ ${#} -ne 2 ]] && die "Invalid number of args to ${FUNCNAME}()";

	local patch=$1
	debug-print "$FUNCNAME: patch=$patch"
	debug-print "$FUNCNAME: patch_cmd=$patch_cmd"
	local msg=$2
	debug-print "$FUNCNAME: msg=$msg"
	shift
	echo
	einfo "${msg}"
	patch_base_name=$(basename "$patch")
	patch_dir_name=$(dirname "$patch")
	debug-print "$FUNCNAME: patch_base_name=$patch_base_name"
	debug-print "$FUNCNAME: patch_dir_name=$patch_dir_name"
	case $patch_base_name in
	patch_list) # list of patches
		while read -r line; do
			[[ -z "$line" ]] && continue # skip empty lines
			[[ $line =~ ^\ {0,}# ]] && continue # skip comments
			ebegin "Applying $line"
				Handler "$patch_dir_name/$line"
			eend $?
		done < "$patch" ;;
	spatch_list) # smart list of patches
		index=1
		for var in $(grep -v '^#' "${patch}"); do
			ebegin "Applying $var"
				Handler "${patch_dir_name}/${var}" || no_luck="1"
				[ "${no_luck}" = "1" ] && break || ok_array[$index]="${var}"; index=$(expr $index + 1)
			eend
		done
		if [ "${no_luck}" = "1" ]; then
			for var in `seq ${#ok_array[@]} -1 1`; do
				ebegin "${BLUE}Reversing patch <--${NORMAL} ${RED}${ok_array[var]}${NORMAL}"
					patch_cmd="patch -p1 -g1 -R" # reverse argument to patch
					ExtractApply "${patch_dir_name}/${ok_array[var]}" &>/dev/null
				eend $?
			done
		fi ;;
	*) # else is patch
		ebegin "Applying $patch_base_name"
			Handler "$patch"
		eend $? ;;
	esac
}

# @FUNCTION: ApplyUserPatch
# @USAGE:
# ApplyUserPatch
# ApplyUserPatch "patch_set_name" # for apply user fix of patch set
# @DESCRIPTION:
# Applies user-provided patches to the source tree. The patches are
# taken from /etc/portage/patches/<CATEGORY>/<PF|P|PN>[:SLOT]/, where the first
# of these three directories to exist will be the one to use, ignoring
# any more general directories which might exist as well.
patch_ApplyUserPatch() {
	debug-print-function ${FUNCNAME} "$@"

	local dir=$1
	debug-print "$FUNCNAME: dir=$dir"

	# don't clobber any EPATCH vars that the parent might want
	local EPATCH_SOURCE check
	[[ ${PORTAGE_CONFIGROOT} == "/" ]] && local base="/etc/portage/patches" || local base="${PORTAGE_CONFIGROOT}/etc/portage/patches";
	for check in ${CATEGORY}/{${P}-${PR},${P},${PN}}{,:${SLOT}}/${dir}; do
		EPATCH_SOURCE=$(echo ${base}/${CTARGET}/${check} | sed 's_//_/_g') # Remove unnecessary slashes from a given path
		[[ -r ${EPATCH_SOURCE} ]] || EPATCH_SOURCE=$(echo ${base}/${CHOST}/${check} | sed 's_//_/_g')
		[[ -r ${EPATCH_SOURCE} ]] || EPATCH_SOURCE=$(echo ${base}/${check} | sed 's_//_/_g')
		if [[ -d ${EPATCH_SOURCE} ]] ; then
			if [ -r "$(echo ${EPATCH_SOURCE}/patch_list | sed 's_//_/_g')" ]; then
				ApplyPatch "$(echo ${EPATCH_SOURCE}/patch_list | sed 's_//_/_g')" "${YELLOW}Applying user patches from ${GREEN}$(echo ${EPATCH_SOURCE}/patch_list | sed 's_//_/_g')${NORMAL} ..."
			else
				ewarn "${BLUE}File${NORMAL} ${RED}$(echo ${EPATCH_SOURCE}/patch_list | sed 's_//_/_g')${NORMAL} ${BLUE}not found!${NORMAL}"
				ewarn "${BLUE}Try to apply the patches if they are there…${NORMAL}"
				for i in `ls ${EPATCH_SOURCE}/*.{patch,gz,bz,bz2,lrz,xz,zip,Z} 2> /dev/null`; do
					ApplyPatch "${i}" "${YELLOW}Applying user patches from ${GREEN}${EPATCH_SOURCE}${NORMAL} ..."
				done
			fi
		fi
	done
}

fi
