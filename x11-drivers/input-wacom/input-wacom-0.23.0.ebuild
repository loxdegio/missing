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
IUSE=""

CONFIG_CHECK="TABLET_USB_WACOM"
ERROR_X86_ACPI_CPUFREQ="CONFIG_TABLET_USB_WACOM has to be enabled to use wacom tablets"

MODULE_NAMES="wacom()
			  wacom_w8001()"
BUILD_PARAMS="KERNELSRC=\"${KERNEL_DIR}\" -j1"
BUILD_TARGETS="all"

src_install() {
	if [ -d /lib/modules/`uname -r`/kernel/drivers/input/tablet ]; then
		install -c ${S}/3.7/wacom.ko /lib/modules/`uname -r`/kernel/drivers/input/tablet;
	fi
	if [ -d /lib/modules/`uname -r`/kernel/drivers/input/touchscreen ]; then
		install -c ${S}/3.7/wacom_w8001.ko /lib/modules/`uname -r`/kernel/drivers/input/tablet;
	fi
}
