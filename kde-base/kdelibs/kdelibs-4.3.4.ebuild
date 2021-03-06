# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kdelibs/kdelibs-4.3.4.ebuild,v 1.4 2009/12/04 17:51:54 scarabeus Exp $

EAPI="2"

CPPUNIT_REQUIRED="optional"
OPENGL_REQUIRED="optional"
WEBKIT_REQUIRED="always"
inherit kde4-base fdo-mime

DESCRIPTION="KDE libraries needed by all KDE programs."
HOMEPAGE="http://www.kde.org/"

KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
LICENSE="LGPL-2.1"
IUSE="3dnow acl alsa altivec bindist +bzip2 debug doc fam +handbook jpeg2k kerberos
lzma mmx nls openexr +semantic-desktop spell sse sse2 ssl zeroconf"

# needs the kate regression testsuite from svn
RESTRICT="test"

COMMONDEPEND="
	>=app-misc/strigi-0.6.3[dbus,qt4]
	dev-libs/libpcre
	dev-libs/libxml2
	dev-libs/libxslt
	>=kde-base/automoc-0.9.87
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/giflib
	media-libs/jpeg
	media-libs/libpng
	>=media-sound/phonon-4.3.49[xcb]
	sys-apps/dbus[X]
	sys-libs/libutempter
	sys-libs/zlib
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXcursor
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXft
	x11-libs/libXpm
	x11-libs/libXrender
	x11-libs/libXtst
	>=x11-misc/shared-mime-info-0.60
	acl? ( virtual/acl )
	alsa? ( media-libs/alsa-lib )
	bzip2? ( app-arch/bzip2 )
	fam? ( virtual/fam )
	jpeg2k? ( media-libs/jasper )
	kerberos? ( virtual/krb5 )
	lzma? ( app-arch/xz-utils )
	openexr? (
		media-libs/openexr
		media-libs/ilmbase
	)
	semantic-desktop? ( >=dev-libs/soprano-2.3.0[dbus] )
	spell? (
		app-dicts/aspell-en
		app-text/aspell
		app-text/enchant
	)
	ssl? ( dev-libs/openssl )
	zeroconf? (
		|| (
			net-dns/avahi[mdnsresponder-compat]
			!bindist? ( net-misc/mDNSResponder )
		)
	)
"
DEPEND="${COMMONDEPEND}
	doc? ( app-doc/doxygen )
	nls? ( virtual/libintl )
"
RDEPEND="${COMMONDEPEND}
	!<=kde-misc/kdnssd-avahi-0.1.2:0
	!x11-libs/qt-phonon
	>=app-crypt/gnupg-2.0.11
	x11-apps/iceauth
	x11-apps/rgb
	>=x11-misc/xdg-utils-1.0.2-r3
"
PDEPEND="
	$(add_kdebase_dep kde-env)
	$(add_kdebase_dep kdebase-runtime-meta 'handbook?,semantic-desktop?')
"

# Blockers added due to packages from old versions, removed in the meanwhile
# as well as for file collisions
add_blocker kitchensync 4.1.50
add_blocker knewsticker 4.1.50
add_blocker kpercentage 4.1.50
add_blocker ktnef 4.1.50
add_blocker libkworkspace 4.2.50
add_blocker libplasma
# Block some old versions of KDE-3.5 packages that don't work well with KDE-4
add_blocker kdebase 0 3.5.9-r4:3.5
add_blocker kdebase-startkde 0 3.5.10:3.5
add_blocker kdelibs 0 '<3.5.10'

PATCHES=(
	"${FILESDIR}/01_kdemod_tag.patch"
	"${FILESDIR}/02_kde_applications_menu.patch"
	"${FILESDIR}/04_add_arch_filetypes_to_kate_syntax_highlighting.patch"
	"${FILESDIR}/05_no_indent_kickoff_subtext.patch"
	"${FILESDIR}/06_use_bitstream_as_default_font.patch"
	"${FILESDIR}/backport_fdo_notifications.patch"
	"${FILESDIR}/fix_remove_applet_confirmation.patch"
	"${FILESDIR}/dist/01_gentoo_set_xdg_menu_prefix.patch"
	"${FILESDIR}/dist/02_gentoo_append_xdg_config_dirs.patch"
	"${FILESDIR}/dist/23_solid_no_double_build.patch"
)

src_prepare() {
	kde4-base_src_prepare

	# Rename applications.menu (needs 01_gentoo_set_xdg_menu_prefix.patch to work)
	local menu_prefix="kde-${SLOT}-"
	sed -e "s|FILES[[:space:]]applications.menu|FILES applications.menu RENAME ${menu_prefix}applications.menu|g" \
		-i kded/CMakeLists.txt || die "Sed on CMakeLists.txt for applications.menu failed."
	sed -e "s|@REPLACE_MENU_PREFIX@|${menu_prefix}|" \
		-i kded/vfolder_menu.cpp || die "Sed on vfolder_menu.cpp failed."

	# FIXME Remove experimental folder from CMakeLists - we have
	# kde-base/libknotificationitem for now
	sed -e "/macro_optional_add_subdirectory( experimental )/ s:^:#:" \
		-i CMakeLists.txt || die "Failed to sed-out experimental."
}

src_configure() {
	if use zeroconf; then
		if has_version net-dns/avahi; then
			mycmakeargs="${mycmakeargs} -DWITH_Avahi=ON -DWITH_DNSSD=OFF"
		elif has_version net-misc/mDNSResponder; then
			mycmakeargs="${mycmakeargs} -DWITH_Avahi=OFF -DWITH_DNSSD=ON"
		else
			die "USE=\"zeroconf\" enabled but neither net-dns/avahi nor net-misc/mDNSResponder were found."
		fi
	else
		mycmakeargs="${mycmakeargs} -DWITH_Avahi=OFF -DWITH_DNSSD=OFF"
	fi
	if use kdeprefix; then
		HME=".kde${SLOT}"
	else
		HME=".kde4"
	fi
	mycmakeargs="${mycmakeargs}
		-DWITH_HSPELL=OFF
		-DKDE_DEFAULT_HOME=${HME}
		$(cmake-utils_use_build handbook doc)
		$(cmake-utils_use_has 3dnow X86_3DNOW)
		$(cmake-utils_use_has altivec PPC_ALTIVEC)
		$(cmake-utils_use_has mmx X86_MMX)
		$(cmake-utils_use_has sse X86_SSE)
		$(cmake-utils_use_has sse2 X86_SSE2)
		$(cmake-utils_use_with acl)
		$(cmake-utils_use_with alsa)
		$(cmake-utils_use_with bzip2 BZip2)
		$(cmake-utils_use_with fam)
		$(cmake-utils_use_with jpeg2k Jasper)
		$(cmake-utils_use_with kerberos GSSAPI)
		$(cmake-utils_use_with lzma LibLZMA)
		$(cmake-utils_use_with nls Libintl)
		$(cmake-utils_use_with openexr OpenEXR)
		$(cmake-utils_use_with opengl OpenGL)
		$(cmake-utils_use_with semantic-desktop Soprano)
		$(cmake-utils_use_with spell ASPELL)
		$(cmake-utils_use_with spell ENCHANT)
		$(cmake-utils_use_with ssl OpenSSL)
	"
	kde4-base_src_configure
}

src_compile() {
	kde4-base_src_compile

	# The building of apidox is not managed anymore by the build system
	if use doc; then
		einfo "Building API documentation"
		cd "${S}"/doc/api/
		./doxygen.sh "${S}" || die "APIDOX generation failed"
	fi
}

src_install() {
	kde4-base_src_install

	if use doc; then
		einfo "Installing API documentation. This could take a bit of time."
		cd "${S}"/doc/api/
		docinto /HTML/en/kdelibs-apidox
		dohtml -r ${P}-apidocs/* || die "Install phase of KDE4 API Documentation failed"
	fi
}

pkg_postinst() {
	fdo-mime_mime_database_update
	if use zeroconf; then
		echo
		elog "To make zeroconf support available in KDE make sure that the 'mdnsd' daemon"
		elog "is running."
		echo
		einfo "If you also want to use zeroconf for hostname resolution, emerge sys-auth/nss-mdns"
		einfo "and enable multicast dns lookups by editing the 'hosts:' line in /etc/nsswitch.conf"
		einfo "to include 'mdns', e.g.:"
		einfo "	hosts: files mdns dns"
		echo
	fi
	elog "Your homedir is set to "'${HOME}'"/${HME}"
	elog
	local config_path="${ROOT}usr/share/config"
	[[ ${PREFIX} != "${ROOT}usr" ]] && config_path+=" ${PREFIX}/share/config"
	elog "If you experience weird application behavior (missing texts, etc.) run as root:"
	elog "# chmod go+rX -R ${config_path}"

	kde4-base_pkg_postinst
}

pkg_prerm() {
	# Remove ksycoca4 global database
	rm -f "${PREFIX}"/share/kde4/services/ksycoca4
}

pkg_postrm() {
	fdo-mime_mime_database_update

	kde4-base_pkg_postrm
}
