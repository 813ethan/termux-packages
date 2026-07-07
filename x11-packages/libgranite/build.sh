TERMUX_PKG_HOMEPAGE=https://github.com/elementary/granite
TERMUX_PKG_DESCRIPTION="A companion library for GTK3 and GLib"
TERMUX_PKG_LICENSE="LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="6.2.0"
TERMUX_PKG_SRCURL=git+https://github.com/elementary/granite
TERMUX_PKG_GIT_BRANCH="$TERMUX_PKG_VERSION"
TERMUX_PKG_DEPENDS="libgee, gobject-introspection, gtk3"
TERMUX_PKG_BUILD_DEPENDS="valac"
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_EXTRA_CONFIGURE_ARGS=""

termux_step_pre_configure() {
	termux_setup_gir
	termux_setup_glib_cross_pkg_config_wrapper
}
