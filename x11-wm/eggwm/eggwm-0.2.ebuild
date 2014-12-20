# Copyright 2014 Loxdegio
# Distributed under the terms of the GNU General Public License v3
# $Header: x11-wm/eggwm/eggwm-0.2.ebuild,v 1.1 2014/11/14 15:19:50 $

EAPI=5

inherit qt4-r2

DESCRIPTION="Egg Lightweight Window Manager written in C++ and Qt"
HOMEPAGE="https://code.google.com/p/eggwm/"
MY_P=${P/_}
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-qt/qtcore:4
	dev-qt/qtgui:4
"

S=${WORKDIR}/${MY_P}
DOCS=(AUTHORS Changelog README.md TODO)

src_configure() {
	eqmake4
}

src_install() {
	exeinto /usr/bin
	doexe ${S}/eggwm
	
	dodir /usr/share/eggwm
	insinto /usr/share/eggwm
	doins ${S}/installation/eggwm.conf
	
	dodir /usr/share/eggwm/themes
	
	dodir /usr/share/eggwm/themes/oxygegg
	insinto /usr/share/eggwm/themes/oxygegg
	doins ${S}/installation/themes/oxygegg/style.qss
	doins ${S}/installation/themes/oxygegg/theme.inf
	dodir /usr/share/eggwm/themes/oxygegg/images
	insinto /usr/share/eggwm/themes/oxygegg/images
	doins ${S}/installation/themes/oxygegg/images/exit_button.png       
	doins ${S}/installation/themes/oxygegg/images/maximize_button.png       
	doins ${S}/installation/themes/oxygegg/images/minimize_button.png
	doins ${S}/installation/themes/oxygegg/images/exit_button_over.png  
	doins ${S}/installation/themes/oxygegg/images/maximize_button_over.png  
	doins ${S}/installation/themes/oxygegg/images/minimize_button_over.png	
	
	dodir /usr/share/eggwm/themes/testtheme
	doins ${S}/installation/themes/testtheme/style.qss
	doins ${S}/installation/themes/testtheme/theme.inf
	dodir /usr/share/eggwm/themes/testtheme/images
	insinto /usr/share/eggwm/themes/testtheme/images
	doins ${S}/installation/themes/testtheme/images/exit_button.png       
	doins ${S}/installation/themes/testtheme/images/maximize_button.png       
	doins ${S}/installation/themes/testtheme/images/minimize_button.png
	doins ${S}/installation/themes/testtheme/images/exit_button_over.png  
	doins ${S}/installation/themes/testtheme/images/maximize_button_over.png  
	doins ${S}/installation/themes/testtheme/images/minimize_button_over.png	
}
