# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/knetattach/knetattach-4.3.4.ebuild,v 1.1 2009/12/01 10:49:45 wired Exp $

EAPI="2"

KMNAME="kdebase-runtime"
inherit kde4-meta

DESCRIPTION="KDE network wizard"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="debug +handbook"

PATCHES=(
	"${FILESDIR}/01_knetattach_use_sftp.patch"
	"${FILESDIR}/02_oxygenify_knetattach_icon.patch"
)

