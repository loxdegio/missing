# Copyright 2014 loxdegio
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit linux-info linux-mod eutils

DESCRIPTION="Linux Wacom Tablet Project"
HOMEPAGE="http://sourceforge.net/projects/linuxwacom"
SRC_URI="http://sourceforge.net/projects/linuxwacom/files/xf86-${PN}/${PN}/${P}.tar.bz2/download -> ${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="input_devices_wacom tools X multilib +kernel_linux"

KERNEL_VERSION=`uname -r`

CONFIG_CHECK="~HID_WACOM
			  ~TABLET_USB_WACOM
			  ~TOUCHSCREEN_WACOM_W8001"
ERROR_HID_WACOM="CONFIG_HID_WACOM has to be enabled to use wacom tablets"
ERROR_TABLET_USB_WACOM="CONFIG_TABLET_USB_WACOM has to be enabled to use wacom tablets"
ERROR_TOUCHSCREEN_WACOM_W8001="CONFIG_TOUCHSCREEN_WACOM_W8001 has to be enabled to use wacom touch tablets"

MODULE_NAMES="wacom()
			  wacom_w8001()"
BUILD_PARAMS="KERNELSRC=\"${KERNEL_DIR}\" -j1"
BUILD_TARGETS="all"

DEPEND="tools? ( x11-libs/libX11
				 x11-libs/libXext
				 virtual/libudev
		)
		X? ( x11-base/xorg-server
			 x11-drivers/xf86-input-wacom 
			 multilib? (
			 || (
				 (
					>=x11-libs/libX11-1.6.2[abi_x86_32]
					>=x11-libs/libXext-1.3.2[abi_x86_32]
				 )
				app-emulation/emul-linux-x86-xlibs
			 )
		     )
		)
		kernel_linux? ( virtual/linux-sources )"

src_install() {
	linux-info_pkg_setup
	
	if (kernel_is ge 2 6 30) &&  (kernel_is lt 2 6 36); then
		if linux_config_exists \
				linux_chkconfig_present TABLET_USB_WACOM \
				&& linux_chkconfig_present INPUT_EVDEV; then
			if [ ! -d /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet ]; then
				dodir /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet;
			fi
		
			insinto /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet;
			insopts -m644;
			doins 2.6.30/wacom.ko;
		fi
		
		if linux_config_exists \
				&& linux_chkconfig_present TOUCHSCREEN_WACOM_W8001; then
			if [ ! -d /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen ]; then
				dodir /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen;
			fi
				
			insinto /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen;
			insopts -m644;
			doins 2.6.30/wacom_w8001.ko;
		fi
	fi
	
	if (kernel_is ge 2 6 36) &&  (kernel_is lt 2 6 38); then
		if linux_config_exists \
				linux_chkconfig_present TABLET_USB_WACOM \
				&& linux_chkconfig_present INPUT_EVDEV; then
		if [ ! -d /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet ]; then
			dodir /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet;
		fi
		
			insinto /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet;
			insopts -m644;
			doins 2.6.36/wacom.ko;
		fi
		
		if linux_config_exists \
				&& linux_chkconfig_present TOUCHSCREEN_WACOM_W8001; then
			if [ ! -d /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen ]; then
				dodir /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen;
			fi
				
			insinto /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen;
			insopts -m644;
			doins 2.6.36/wacom_w8001.ko;
		fi
	fi
	
	if (kernel_is ge 2 6 38) &&  (kernel_is lt 3 7); then
		if linux_config_exists \
				linux_chkconfig_present TABLET_USB_WACOM \
				&& linux_chkconfig_present INPUT_EVDEV; then
		if [ ! -d /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet ]; then
			dodir /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet;
		fi
		
			insinto /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet;
			insopts -m644;
			doins 2.6.38/wacom.ko;
		fi
		
		if linux_config_exists \
				&& linux_chkconfig_present TOUCHSCREEN_WACOM_W8001; then
			if [ ! -d /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen ]; then
				dodir /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen;
			fi
				
			insinto /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen;
			insopts -m644;
			doins 2.6.38/wacom_w8001.ko;
		fi
	fi
	
	if (kernel_is ge 3 7) &&  (kernel_is lt 3 17); then
		if linux_config_exists \
				linux_chkconfig_present TABLET_USB_WACOM \
				&& linux_chkconfig_present INPUT_EVDEV; then
			if [ ! -d /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet ]; then
				dodir /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet;
			fi
		
			insinto /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet;
			insopts -m644;
			doins 3.7/wacom.ko;
		fi
		
		if linux_config_exists \
				&& linux_chkconfig_present TOUCHSCREEN_WACOM_W8001; then
			if [ ! -d /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen ]; then
				dodir /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen;
			fi
				
			insinto /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen;
			insopts -m644;
			doins 3.7/wacom_w8001.ko;
		fi
	fi
	
	if kernel_is ge 3 17; then
		if linux_config_exists \
					linux_chkconfig_present HID_WACOM \
					&& linux_chkconfig_present INPUT_EVDEV; then
			if [ ! -d /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet ]; then
				dodir /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet;
			fi
			
			insinto /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet;
			insopts -m644;
			doins 3.17/wacom.ko;
		fi
				
		if linux_config_exists \
					&& linux_chkconfig_present TOUCHSCREEN_WACOM_W8001; then
			if [ ! -d /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen ]; then
				dodir /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen;
			fi		
			
			insinto /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen;
			insopts -m644;
			doins 3.17/wacom_w8001.ko;
		fi
	fi
}

pkg_postrm() {
	if [ -f /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet/wacom.ko ]; then
		rm /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/tablet/wacom.ko;
	fi
	if [ -f /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen/wacom_w8001.ko ]; then
		rm /lib/modules/${KERNEL_VERSION}/kernel/drivers/input/touchscreen/wacom_w8001.ko;
	fi
}

pkg_pretend() {
	linux-info_pkg_setup
	
	if kernel_is lt 3 17 ; then
		if ! linux_config_exists \
				|| ! linux_chkconfig_present TABLET_USB_WACOM \
				|| ! linux_chkconfig_present INPUT_EVDEV; then
			echo
			ewarn "If you use a USB Wacom tablet, you need to enable support in your kernel"
			ewarn "  Device Drivers --->"
			ewarn "    Input device support --->"
			ewarn "      <*>   Event interface"
			ewarn "      [*]   Tablets  --->"
			ewarn "        <*>   Wacom Intuos/Graphire tablet support (USB)"
			echo
		fi
	else 
		if ! linux_config_exists \
				|| ! linux_chkconfig_present HID_WACOM; then
			echo
			ewarn "If you use a USB Wacom tablet, you need to enable support in your kernel"
			ewarn "  Device Drivers  --->"
			ewarn "    HID support  --->"  
			ewarn "      {*} HID bus support"  
			ewarn "			 Special HID drivers  --->"
			ewarn "			   <*> Wacom Intuos/Graphire tablet support (USB)"
			echo
		fi
	fi
	
	if ! linux_config_exists \
				|| ! linux_chkconfig_present TOUCHSCREEN_WACOM_W8001; then
			echo
			ewarn "If you use a USB Wacom tablet, you need to enable support in your kernel"
			ewarn "  Device Drivers --->"
			ewarn "    Input device support --->"
			ewarn "      -*- Generic input layer (needed for keyboard, mouse, ...)"
			ewarn "      [*]   Touchscreens  --->"
			ewarn "        <*>   Wacom W8001 penabled serial touchscreen"
			echo
	fi
	
}
