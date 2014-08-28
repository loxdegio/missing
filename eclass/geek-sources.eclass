# Copyright 2011-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# @ECLASS: geek-sources.eclass
# This file is part of sys-kernel/geek-sources project.
# @MAINTAINER:
# Andrey Ovcharov <sudormrfhalt@gmail.com>
# @AUTHOR:
# Original author: Andrey Ovcharov <sudormrfhalt@gmail.com> (09 Jan 2013)
# @LICENSE: http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
# @BLURB: Eclass for building geek kernel.
# @DESCRIPTION:
# This eclass provides functionality and default ebuild variables for building
# geek kernel with any patches easily.

# The latest version of this software can be obtained here:
# https://github.com/init6/init_6/blob/master/eclass/geek-sources.eclass
# Bugs: https://github.com/init6/init_6/issues
# Wiki: https://github.com/init6/init_6/wiki/geek-sources

case ${EAPI} in
	5)	: ;;
	*)	die "geek-sources.eclass: unsupported EAPI=${EAPI:-0}" ;;
esac

if [[ ${___ECLASS_ONCE_GEEK_SOURCES} != "recur -_+^+_- spank" ]]; then
___ECLASS_ONCE_GEEK_SOURCES="recur -_+^+_- spank"

inherit src-vanilla utils fix upatch squeue vars

KNOWN_USES="aufs bfq bld brand build cjktty ck deblob exfat fedora gentoo grsec hardened ice lqx mageia openelec openvz openwrt optimize pax pf reiser4 rh rt rsbac suse symlink uek uksm zen zfs"

# internal function
#
# @FUNCTION: USEKnown
# @USAGE:
# @DESCRIPTION:
USEKnown() {
	debug-print-function ${FUNCNAME} "$@"

	[[ ${#} -ne 1 ]] && die "Invalid number of args to ${FUNCNAME}()";

	local USE=$1
	[ "${USE}" == "" ] && die "${RED}Feature not defined!${NORMAL}"

	expr index "${SUPPORTED_USES}" "${USE}" >/dev/null || die "${RED}${USE}${NORMAL} ${BLUE}is not supported in current kernel${NORMAL}"
	expr index "${KNOWN_USES}" "${USE}" >/dev/null || die "${RED}${USE}${NORMAL} ${BLUE}is not known${NORMAL}"
	IUSE="${IUSE} ${USE}"
}

for I in ${SUPPORTED_USES}; do
	USEKnown "${I}"
done

for use_flag in ${IUSE}; do
	case ${use_flag} in
		aufs		)	inherit aufs ;;
		bfq		)	inherit bfq ;;
		bld		)	inherit bld ;;
		brand		)	inherit brand ;;
		build		)	inherit build ;;
		cjktty		)	inherit cjktty ;;
		ck		)	inherit ck ;;
		deblob		)	inherit deblob ;;
		exfat		)	inherit exfat ;;
		fedora		)	inherit fedora ;;
		gentoo		)	inherit gentoo ;;
		grsec		)	inherit grsec ;;
		hardened	)	inherit hardened ;;
		ice		)	inherit ice ;;
		lqx		)	inherit lqx ;;
		mageia		)	inherit mageia ;;
		openelec	)	inherit openelec ;;
		openvz		)	inherit openvz ;;
		openwrt		)	inherit openwrt ;;
		optimize	)	inherit optimize ;;
		pax		)	inherit pax ;;
		pf		)	inherit pf ;;
		reiser4		)	inherit reiser4 ;;
		rh		)	if [[ ${KMV} = "2.6" ]]; then
						inherit rh
					elif [[ ${KMV} = "3.10" ]]; then
						inherit src-rh
					fi ;;
		rsbac		)	inherit rsbac ;;
		rt		)	inherit rt ;;
		suse		)	inherit suse ;;
		uek		)	inherit src-uek ;;
		uksm		)	inherit uksm ;;
		zen		)	inherit zen ;;
		zfs		)	inherit spl zfs ;;
	esac
done

EXPORT_FUNCTIONS src_unpack src_prepare src_compile src_install pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-sources_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	# Remove duplicates patches
#	local rm_duplicates_cfg=$(source $cfg_file 2>/dev/null; echo ${rm_duplicates})
#	: ${rm_duplicates:=${rm_duplicates_cfg:-yes}} # rm_duplicates=yes/no
#	einfo "${BLUE}Remove duplicates patches -->${NORMAL} ${RED}$rm_duplicates${NORMAL}"

	: ${SKIP_KERNEL_PATCH_UPDATE:="lqx openvz pf rh uek zen"}
	: ${DEFAULT_GEEKSOURCES_PATCHING_ORDER:="zfs optimize pax lqx pf zen bfq ck cjktty gentoo grsec hardened rsbac ice rh uek openvz openwrt reiser4 exfat rt bld uksm aufs mageia fedora suse openelec brand fix upatch squeue"}

	local xUserOrder=""
	local xDefOder=""
	if [ -e "${cfg_file}" ]; then
		source "${cfg_file}"
		if [ ! -z "$GEEKSOURCES_PATCHING_ORDER" ]; then
			xUserOrder="$(echo -n "$GEEKSOURCES_PATCHING_ORDER" | tr '\n' ' ' | tr -s ' ' | tr ' ' '\n' | sort | tr '\n' ' ' | sed -e 's,^\s*,,' -e 's,\s*$,,')"
			xDefOrder="$(echo -n "$DEFAULT_GEEKSOURCES_PATCHING_ORDER" | tr '\n' ' ' | tr -s ' ' | tr ' ' '\n' | sort | tr '\n' ' ' | sed -e 's,^\s*,,' -e 's,\s*$,,')"

			if [ "x${xUserOrder}" = "x${xDefOrder}" ]; then
				ewarn "${BLUE}Use${NORMAL} ${RED}GEEKSOURCES_PATCHING_ORDER=\"${GEEKSOURCES_PATCHING_ORDER}\"${NORMAL} ${BLUE}from${NORMAL} ${GREEN}${cfg_file}${NORMAL}"
			else
				difference=$(echo "${xDefOrder} ${xUserOrder}" | awk '{for(i=1;i<=NF;i++){_a[$i]++}for(i in _a){if(_a[i]==1)print i}}' ORS=" ")
				ewarn "${BLUE}Use${NORMAL} ${RED}GEEKSOURCES_PATCHING_ORDER=\"${GEEKSOURCES_PATCHING_ORDER}\"${NORMAL} ${BLUE}from${NORMAL} ${GREEN}${cfg_file}${NORMAL}${BR}
${BLUE}Not all USE flag present in GEEKSOURCES_PATCHING_ORDER from${NORMAL} ${GREEN}${cfg_file}${NORMAL}${BR}
${BLUE}The following flags are missing:${NORMAL} ${RED}${difference}${NORMAL}${BR}
${BLUE}Probably that"\'"s the plan. In that case, never mind.${NORMAL}${BR}"
			fi
		fi
	fi

	if [ -z "$GEEKSOURCES_PATCHING_ORDER" ]; then
		GEEKSOURCES_PATCHING_ORDER="${DEFAULT_GEEKSOURCES_PATCHING_ORDER}"
		ewarn "${BLUE}The order of patching is defined in file${NORMAL} ${GREEN}${cfg_file}${NORMAL} ${BLUE}with the variable GEEKSOURCES_PATCHING_ORDER is its default value:${NORMAL}
${RED}GEEKSOURCES_PATCHING_ORDER=\"${GEEKSOURCES_PATCHING_ORDER}\"${NORMAL}
${BLUE}You are free to choose any order of patching.${NORMAL}
${BLUE}For example, if you like the alphabetical order of patching you must set the variable:${NORMAL}
${RED}echo 'GEEKSOURCES_PATCHING_ORDER=\"`echo ${GEEKSOURCES_PATCHING_ORDER} | sed "s/ /\n/g" | sort | sed ':a;N;$!ba;s/\n/ /g'`\"' > ${cfg_file}${NORMAL}
${BLUE}Otherwise i will use the default value of GEEKSOURCES_PATCHING_ORDER!${NORMAL}
${BLUE}And may the Force be with you…${NORMAL}"
	fi

#	debug-print "${FUNCNAME}: rm_duplicates=$rm_duplicates"
	debug-print "${FUNCNAME}: SKIP_KERNEL_PATCH_UPDATE=${SKIP_KERNEL_PATCH_UPDATE}"
	debug-print "${FUNCNAME}: DEFAULT_GEEKSOURCES_PATCHING_ORDER=${DEFAULT_GEEKSOURCES_PATCHING_ORDER}"
}

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-sources_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${BLUE}Crap patch -->${NORMAL} ${RED}$crap_patch${NORMAL}"
	einfo "${BLUE}Disable fixes -->${NORMAL} ${RED}$disable_fixes${NORMAL}"
	einfo "${BLUE}Remove unneeded architectures -->${NORMAL} ${RED}$rm_unneeded_arch${NORMAL}"
	einfo "${BLUE}Compile ${RED}gen_init_cpio${NORMAL} ${BLUE}-->${NORMAL} ${RED}$gen_init_cpio${NORMAL}"
	einfo "${BLUE}Running ${RED}make oldconfig${NORMAL} ${BLUE}-->${NORMAL} ${RED}$oldconfig${NORMAL}"
	einfo "${BLUE}Skip stable-queue -->${NORMAL} ${RED}$skip_squeue${NORMAL}"

	geek-sources_init_variables

	for Current_Patch in $SKIP_KERNEL_PATCH_UPDATE; do
		if use_if_iuse "${Current_Patch}"; then
		case "${Current_Patch}" in
			*) SKIP_UPDATE="1" skip_squeue="yes" ;;
		esac
		else continue
		fi
	done

	if use_if_iuse "rh"; then
		[[ ${KMV} = "3.10" ]] && src-rh_src_unpack
	elif use_if_iuse "uek"; then
		src-uek_src_unpack
	else
		src-vanilla_src_unpack
	fi

	test -d "${WORKDIR}/linux-${KV_FULL}-patches" >/dev/null 2>&1 || mkdir -p "${WORKDIR}/linux-${KV_FULL}-patches"
	for Current_Patch in $GEEKSOURCES_PATCHING_ORDER; do
		if use_if_iuse "${Current_Patch}" || [ "${Current_Patch}" = "fix" ] || [ "${Current_Patch}" = "upatch" ] || [ "${Current_Patch}" = "squeue" ]; then
			einfo "Unpack - ${Current_Patch}"
			case "${Current_Patch}" in
				aufs		)	aufs_src_unpack ;;
				bfq		)	bfq_src_unpack ;;
				bld		)	bld_src_unpack ;;
				cjktty		)	cjktty_src_unpack ;;
				exfat		)	exfat_src_unpack ;;
				fedora		)	fedora_src_unpack ;;
				gentoo		)	gentoo_src_unpack ;;
				hardened	)	hardened_src_unpack ;;
				ice		)	ice_src_unpack ;;
				mageia		)	mageia_src_unpack ;;
				openelec	)	openelec_src_unpack ;;
				openwrt		)	openwrt_src_unpack ;;
				optimize	)	optimize_src_unpack ;;
				pf		)	pf_src_unpack ;;
				rh		)	[[ ${KMV} = "2.6" ]] && rh_src_unpack ;;
				squeue		)	squeue_src_unpack ;;
				suse		)	suse_src_unpack ;;
				uksm		)	uksm_src_unpack ;;
				zen		)	zen_src_unpack ;;
				zfs		)	spl_src_unpack; zfs_src_unpack ;;
			esac
		else continue
		fi
	done

	# Now find and remove all duplicates patches
#	einfo "${YELLOW}Find and remove all duplicates patches ...${NORMAL}"
#	for dubl_file in $(find ${T} -not -empty -type f -printf "%s\n" | sort -rn | uniq -d | xargs -I{} -n1 find -type f -size {}c -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate | cut -f3-100 -d ' ' | tr '\n.' '\t.' | sed 's/\t\t/\n/g' | cut -f2-100 | tr '\t' '\n' | perl -i -pe 's/([ (){}-])/\\$1/g' | perl -i -pe 's/'\''/\\'\''/g' | tr '\n' ' '); do
#		if [ "${rm_duplicates}" = "yes" ]; then
#			einfo "Remove - $dubl_file"
#			rm -v "$dubl_file" >/dev/null 2>&1
#			debug-print "${FUNCNAME}: $dubl_file"
#		elif [ "${rm_duplicates}" = "no" ]; then
#			debug-print "${FUNCNAME}: $dubl_file"
#		fi
#	done
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-sources_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	for Current_Patch in $GEEKSOURCES_PATCHING_ORDER; do
		if use_if_iuse "${Current_Patch}" || [ "${Current_Patch}" = "fix" ] || [ "${Current_Patch}" = "upatch" ] || [ "${Current_Patch}" = "squeue" ]; then
#			einfo "Prepare - ${Current_Patch}"
			case "${Current_Patch}" in
				aufs		)	aufs_src_prepare ;;
				bfq		)	bfq_src_prepare ;;
				bld		)	bld_src_prepare ;;
				brand		)	brand_src_prepare ;;
				cjktty		)	cjktty_src_prepare ;;
				ck		)	ck_src_prepare ;;
				exfat		)	exfat_src_prepare ;;
				fedora		)	fedora_src_prepare ;;
				fix		)	fix_src_prepare ;;
				gentoo		)	gentoo_src_prepare ;;
				grsec		)	grsec_src_prepare ;;
				hardened	)	hardened_src_prepare ;;
				ice		)	ice_src_prepare ;;
				lqx		)	lqx_src_prepare ;;
				mageia		)	mageia_src_prepare ;;
				openelec	)	openelec_src_prepare ;;
				openvz		)	openvz_src_prepare ;;
				openwrt		)	openwrt_src_prepare ;;
				optimize	)	optimize_src_prepare ;;
				pax		)	pax_src_prepare ;;
				pf		)	pf_src_prepare ;;
				reiser4		)	reiser4_src_prepare ;;
				rh		)	rh_src_prepare ;;
				rsbac		)	rsbac_src_prepare ;;
				rt		)	rt_src_prepare ;;
				squeue		)	squeue_src_prepare ;;
				suse		)	suse_src_prepare ;;
				uksm		)	uksm_src_prepare ;;
				upatch		)	upatch_src_prepare ;;
				zen		)	zen_src_prepare ;;
				zfs		)	spl_src_prepare; zfs_src_prepare ;;
			esac
		else continue
		fi
	done

	if use_if_iuse "rh"; then
		[[ ${KMV} = "3.10" ]] && src-rh_src_prepare
	elif use_if_iuse "uek"; then
		src-uek_src_prepare
	else
		src-vanilla_src_prepare
	fi
}

# @FUNCTION: src_compile
# @USAGE:
# @DESCRIPTION: Configure and build the package.
geek-sources_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	src-vanilla_src_compile
}

# @FUNCTION: src_install
# @USAGE:
# @DESCRIPTION: Install a package to ${D}
geek-sources_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	src-vanilla_src_install
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-sources_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	src-vanilla_pkg_postinst

	einfo "${BR}${BLUE}Wiki:${NORMAL} ${RED}https://github.com/init6/init_6/wiki/geek-sources${NORMAL}${BR}
${BLUE}Bugs:${NORMAL} ${RED}https://github.com/init6/init_6/issues${NORMAL}${BR}
${BLUE}Donate:${NORMAL} ${RED}https://github.com/init6/init_6/wiki/donate${NORMAL}${BR}
${BLUE}For more info about patchset’s, and how to report problems, see:${NORMAL}${BR}"
	for Current_Patch in $GEEKSOURCES_PATCHING_ORDER; do
		if use_if_iuse "${Current_Patch}" || [[ "${Current_Patch}" == "fix" ]] || [[ "${Current_Patch}" == "upatch" ]]; then
			case "${Current_Patch}" in
				aufs		) aufs_pkg_postinst ;;
				bfq		) bfq_pkg_postinst ;;
				bld		) bld_pkg_postinst ;;
				brand		) brand_pkg_postinst ;;
				cjktty		) cjktty_pkg_postinst ;;
				ck		) ck_pkg_postinst ;;
				deblob		) deblob_pkg_postinst ;;
				exfat		) exfat_pkg_postinst ;;
				fedora		) fedora_pkg_postinst ;;
				gentoo		) gentoo_pkg_postinst ;;
				grsec		) grsec_pkg_postinst ;;
				hardened	) hardened_pkg_postinst ;;
				ice		) ice_pkg_postinst ;;
				lqx		) lqx_pkg_postinst ;;
				mageia		) mageia_pkg_postinst ;;
				openelec	) openelec_pkg_postinst ;;
				openvz		) openvz_pkg_postinst ;;
				openwrt		) openwrt_pkg_postinst ;;
				optimize 	) optimize_pkg_postinst ;;
				pax		) pax_pkg_postinst ;;
				pf		) pf_pkg_postinst ;;
				reiser4		) reiser4_pkg_postinst ;;
				rh		) rh_pkg_postinst ;;
				rsbac		) rsbac_pkg_postinst ;;
				rt		) rt_pkg_postinst ;;
				squeue		) squeue_pkg_postinst ;;
				suse		) suse_pkg_postinst ;;
				uksm		) uksm_pkg_postinst ;;
				zen		) zen_pkg_postinst ;;
				zfs		) spl_pkg_postinst; zfs_pkg_postinst ;;
			esac
			else continue
		fi
	done
}

fi
