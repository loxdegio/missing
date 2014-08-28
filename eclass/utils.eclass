# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: utils.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (12 Aug 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass with utils for building kernel.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# kernel.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/utils.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "utils.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_UTILS} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_UTILS="recur -_+^+_- spank"

EXPORT_FUNCTIONS use_if_iuse get_from_url git_get_all_branches git_checkout find_crap rm_crap get_config copy move rand_element

# @FUNCTION: in_iuse
# @USAGE: <flag>
# @DESCRIPTION:
# Determines whether the given flag is in IUSE. Strips IUSE default prefixes
# as necessary.
#
# Note that this function should not be used in the global scope.
in_iuse() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${#} -eq 1 ]] || die "Invalid args to ${FUNCNAME}()"

	local flag=${1}
	local liuse=( ${IUSE} )

	has "${flag}" "${liuse[@]#[+-]}"
}

# @FUNCTION: use_if_iuse
# @USAGE: <flag>
# @DESCRIPTION:
# Return true if the given flag is in USE and IUSE.
#
# Note that this function should not be used in the global scope.
utils_use_if_iuse() {
	debug-print-function ${FUNCNAME} "$@"

	[[ ${#} -ne 1 ]] && die "Invalid number of args to ${FUNCNAME}()";

	in_iuse $1 || return 1
	use $1
}

# @FUNCTION: get_from_url
# @USAGE:
# @DESCRIPTION:
utils_get_from_url() {
	debug-print-function ${FUNCNAME} "$@"

	[[ ${#} -ne 2 ]] && die "Invalid number of args to ${FUNCNAME}()";

	local url="$1"
	local release="$2"
	shift
	wget -nd --no-parent --level 1 -r -R "*.html*" --reject "$release" \
	"$url/$release" > /dev/null 2>&1
}

# @FUNCTION: git_get_all_branches
# @USAGE:
# @DESCRIPTION:
utils_git_get_all_branches(){
	debug-print-function ${FUNCNAME} "$@"

	for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master`; do
		git branch --track ${branch##*/} ${branch} > /dev/null 2>&1
	done
}

# @FUNCTION: git_checkout
# @USAGE:
# @DESCRIPTION:
utils_git_checkout(){
	debug-print-function ${FUNCNAME} "$@"

	local branch_name=${1:-master}

	pushd "${EGIT_SOURCEDIR}" > /dev/null

	debug-print "${FUNCNAME}: git checkout ${branch_name}"
	git checkout ${branch_name}

	popd > /dev/null
}

# iternal function
#
# @FUNCTION: find_crap
# @USAGE:
# @DESCRIPTION: Find *.orig or *.rej files
utils_find_crap() {
	debug-print-function ${FUNCNAME} "$@"

	if [ $(find "${S}" \( -name \*.orig -o -name \*.rej \) | wc -c) -eq 0 ]; then
		crap="0"
	else
		crap="1"
	fi
}

# iternal function
#
# @FUNCTION: rm_crap
# @USAGE:
# @DESCRIPTION: Remove *.orig or *.rej files
utils_rm_crap() {
	debug-print-function ${FUNCNAME} "$@"

	find "${S}" \( -name \*~ -o -name \.gitignore -o -name \*.orig -o -name \.*.orig -o -name \*.rej -o -name \*.old -o -name \.*.old \) -delete
}

# @FUNCTION: get_config
# @USAGE:
# @DESCRIPTION:
utils_get_config() {
	debug-print-function ${FUNCNAME} "$@"

	ebegin "Searching for best availiable kernel config"
		if [ -r "/proc/config.gz" ]; then test -d .config >/dev/null 2>&1 || zcat /proc/config.gz > .config
			einfo " ${BLUE}Found config from running kernel, updating to match target kernel${NORMAL}"
		elif [ -r "/boot/config-${FULLVER}" ]; then test -d .config >/dev/null 2>&1 || cat "/boot/config-${FULLVER}" > .config
			einfo " ${BLUE}Found${NORMAL} ${RED}/boot/config-${FULLVER}${NORMAL}"
		elif [ -r "/etc/portage/savedconfig/${CATEGORY}/${PN}/config" ]; then test -d .config >/dev/null 2>&1 || cat /etc/portage/savedconfig/${CATEGORY}/${PN}/config > .config
			einfo " ${BLUE}Found${NORMAL} ${RED}/etc/portage/savedconfig/${CATEGORY}/${PN}/config${NORMAL}"
		elif [ -r "/usr/src/linux/.config" ]; then test -d .config >/dev/null 2>&1 || cat /usr/src/linux/.config > .config
			einfo " ${BLUE}Found${NORMAL} ${RED}/usr/src/linux/.config${NORMAL}"
		elif [ -r "/usr/src/linux-${KV_FULL}/.config" ]; then test -d .config >/dev/null 2>&1 || cat /usr/src/linux-${KV_FULL}/.config > .config
			einfo " ${BLUE}Found${NORMAL} ${RED}/usr/src/linux-${KV_FULL}/.config${NORMAL}"
		else test -d .config >/dev/null 2>&1 || cp arch/${ARCH}/defconfig .config \
			einfo " ${BLUE}No suitable custom config found, defaulting to defconfig${NORMAL}"
		fi
	eend $?
}

# @FUNCTION: copy
# @USAGE:
# @DESCRIPTION:
utils_copy() {
	debug-print-function ${FUNCNAME} "$@"

	[[ ${#} -ne 2 ]] && die "Invalid number of args to ${FUNCNAME}()";

	local src=${1}
	local dst=${2}

#	cp "${src}" "${dst}" || die "${RED}cp ${src} ${dst} failed${NORMAL}"
#	rsync -avhW --no-compress --progress "${src}" "${dst}" || die "${RED}rsync -avhW --no-compress --progress ${src} ${dst} failed${NORMAL}"
	test -d "${dst}" >/dev/null 2>&1 || mkdir -p "${dst}"; (cd "${src}"; tar cf - .) | (cd "${dst}"; tar xpf -) || die "${RED}cp ${src} ${dst} failed${NORMAL}"
}

# @FUNCTION: move
# @USAGE:
# @DESCRIPTION:
utils_move() {
	debug-print-function ${FUNCNAME} "$@"

	[[ ${#} -ne 2 ]] && die "Invalid number of args to ${FUNCNAME}()";

	local src=${1}
	local dst=${2}

	(copy ${src} ${dst} >/dev/null 2>&1 && rm -rf "${src}") || die "${RED}mv ${src} ${dst} failed${NORMAL}"
}

# @FUNCTION: rand
# @USAGE:
# @DESCRIPTION:
# Return random number.
#
# Note that this function should not be used in the global scope.
utils_rand() {
	printf $(($1*RANDOM/32767))
}

# @FUNCTION: rand_element
# @USAGE:
# @DESCRIPTION:
# Print fortune like random msg.
utils_rand_element () {
	local -a th=("$@")
	unset th[0]
	printf $'%s\n' "${th[$(($(utils_rand "${#th[*]}")+1))]}"
}

fi
