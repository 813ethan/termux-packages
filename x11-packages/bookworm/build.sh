TERMUX_PKG_HOMEPAGE=https://github.com/babluboy/bookworm
TERMUX_PKG_DESCRIPTION="A simple, focused eBook reader"
TERMUX_PKG_LICENSE="LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.1.2"
TERMUX_PKG_SRCURL=git+https://github.com/jbicha/bookworm
TERMUX_PKG_GIT_BRANCH="webkit4.1"
TERMUX_PKG_DEPENDS="libgranite, libsqlite, libxml2, poppler, pango, gobject-introspection, gtk3, glib, libgee, webkit2gtk-4.1, html2text, jq"
TERMUX_PKG_BUILD_DEPENDS="valac, gettext, appstream"
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_EXTRA_CONFIGURE_ARGS=""

termux_step_pre_configure() {
	termux_setup_gir
	termux_setup_glib_cross_pkg_config_wrapper
}
