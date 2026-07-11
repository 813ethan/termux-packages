TERMUX_PKG_HOMEPAGE="https://github.com/btpf/Alexandria"
TERMUX_PKG_DESCRIPTION="A minimalistic cross-platform eBook reader built with Tauri, Epub.js, and Typescript"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.13.2"
TERMUX_PKG_SRCURL=git+https://github.com/btpf/Alexandria
TERMUX_PKG_GIT_BRANCH="v$TERMUX_PKG_VERSION"
TERMUX_PKG_DEPENDS="webkit2gtk-4.1"

termux_step_post_get_source() {
	git submodule update --init --recursive --depth=1
}

termux_step_make() {
	termux_setup_rust
	termux_setup_nodejs

	# to let rust find the built libmobi-rs later
	cd $TERMUX_PKG_SRCDIR/libmobi-rs
	mkdir libmobi-rs/libs/android
	sed -i \
	-e 's|linux|android|g' build-linux.sh \
	-e "s|./configure|./configure --host=$TERMUX_HOST_PLATFORM|g"
	./build-linux.sh

	# fix some linker errors on non-device builds???
	cp ./libmobi/tools/libmobitoolmod.a ./libmobi-rs/libs/linux/

	cd $TERMUX_PKG_SRCDIR/src-tauri
	cargo clean
	cargo vendor vendor/

	echo "" >> Cargo.toml
	echo '[patch.crates-io]' >> Cargo.toml
	crates_to_patch=(
		tauri
		tauri-runtime
		tauri-plugin
		tauri-plugin-fs
		tauri-plugin-os
		tauri-runtime-wry
		muda
		wry
		tao
		reqwest
		rfd
		tauri-plugin-shell
		tauri-plugin-dialog
		tauri-plugin-notification
		tauri-plugin-http
		tauri-plugin-clipboard-manager
		arboard
		tauri-plugin-global-shortcut
		x11rb-protocol
	)
	# # If there is an issue with the automated patching, uncomment these to make it save the patches in src-tauri/patches. You can simply git am this dir.
	# git add -A && git commit -m "add vendored folders" && git tag -d unpatched
	# git tag unpatched
	for crate in "${crates_to_patch[@]}"; do
			echo "termuxifying '$crate'..."
			find "vendor/$crate" -type f | \
					xargs -n 1 sed -i \
					-e 's|"android"|"disabling_this_because_it_is_for_building_an_apk"|g' \
					-e "s|ANDROID|DISABLING_THIS_BECAUSE_IT_IS_FOR_BUILDING_AN_APK|g" \
					-e 's|"linux"|"android"|g' \
					-e "s|libxkbcommon.so.0|libxkbcommon.so|g" \
					-e "s|libxkbcommon-x11.so.0|libxkbcommon-x11.so|g" \
					-e "s|libxcb.so.1|libxcb.so|g" \
					-e "s|/tmp/|$TERMUX_PREFIX/tmp/|g" \
					-e "s|/var/|$TERMUX_PREFIX/var/|g"

			echo "$crate = { path = \"./vendor/$crate\" }" >> Cargo.toml

			# git add -A && git commit -m "automated termux patch for $crate"
	done

	# required to fix
	# error[E0609]: no field `appimage` on type `&Env
	# # --> vendor/tauri/src/process.rs:51:39
	sed -i 's|"android"|"disabling_this_as_we_dont_have_appimage"|g' vendor/tauri/src/process.rs

	# git format-patch unpatched -o patches

	# Generates the dist folder. Required else build fails.
	npm install @tauri-apps/plugin-cli @tauri-apps/plugin-fs @tauri-apps/plugin-dialog @tauri-apps/plugin-os @tauri-apps/plugin-clipboard-manager @tauri-apps/plugin-shell @tauri-apps/plugin-process
	npm install && npm run build && npm run start
	cd $TERMUX_PKG_SRCDIR/src-tauri
	if [[ "$TERMUX_DEBUG_BUILD" == "true" ]]; then
		# CMAKE_POLICY_VERSION_MINIMUM=3.5 required by freetype
		CMAKE_POLICY_VERSION_MINIMUM=3.5 cargo build --bins --features tauri/custom-protocol --target $CARGO_TARGET_NAME
	else
		CMAKE_POLICY_VERSION_MINIMUM=3.5 cargo build --bins --features tauri/custom-protocol --release --target $CARGO_TARGET_NAME
	fi
}

termux_step_make_install() {
	if [[ "$TERMUX_DEBUG_BUILD" == "true" ]]; then
		install -Dm700 -t $TERMUX_PREFIX/bin $TERMUX_PKG_SRCDIR/src-tauri/target/$CARGO_TARGET_NAME/debug/alexandria
	else
		install -Dm700 -t $TERMUX_PREFIX/bin $TERMUX_PKG_SRCDIR/src-tauri/target/$CARGO_TARGET_NAME/release/alexandria
	fi
		install -Dm644 -t "${TERMUX_PREFIX}/share/applications" "${TERMUX_PKG_BUILDER_DIR}/alexandria.desktop"
		for i in 32 128; do
			install -Dvm644 "${TERMUX_PKG_BUILDER_DIR}/icons/hicolor/${i}x${i}/apps/alexandria.png" \
				"$TERMUX_PREFIX/share/icons/hicolor/${i}x${i}/apps/alexandria.png"
		done
		install -Dvm644 "${TERMUX_PKG_BUILDER_DIR}/icons/hicolor/256x256@2/apps/alexandria.png" \
			"$TERMUX_PREFIX/share/icons/hicolor/256x256@2/apps/alexandria.png"
}
