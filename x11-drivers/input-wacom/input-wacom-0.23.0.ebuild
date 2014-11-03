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

CONFIG_CHECK="~TABLET_USB_WACOM
			  ~TOUCHSCREEN_WACOM_W8001"
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
		
src_prepare(){
	./configure
}

src_install() {
	if [ -d /lib/modules/`uname -r`/kernel/drivers/input/tablet ]; then
		insinto /lib/modules/`uname -r`/kernel/drivers/input/tablet;
		doins 3.7/wacom.ko;
	fi
	if [ -d /lib/modules/`uname -r`/kernel/drivers/input/touchscreen ]; then
		insinto /lib/modules/`uname -r`/kernel/drivers/input/touchscreen;
		doins 3.7/wacom_w8001.ko;
	fi
}

pkg_postrm() {
	if [ -f /lib/modules/`uname -r`/kernel/drivers/input/tablet/wacom.ko ]; then
		rm /lib/modules/`uname -r`/kernel/drivers/input/tablet/wacom.ko;
	fi
	if [ -f /lib/modules/`uname -r`/kernel/drivers/input/touchscreen/wacom_w8001.ko ]; then
		rm /lib/modules/`uname -r`/kernel/drivers/input/touchscreen/wacom_w8001.ko;
	fi
}
