#!/usr/bin/env bash
set -ueo pipefail
set -x


VERSIONS=(1.7.2 1.6.0 1.5.2)

SCRIPT_DIR="$(readlink -e "$(dirname "${0}")")"
CONFIG_PATH="${SCRIPT_DIR}/config.yaml"

echo -ne > "$CONFIG_PATH"

for version in "${VERSIONS[@]}" ; do

	GIT_CLONE_ROOT="$HOME/tmp"
	LIBADWAITA_DIR="$GIT_CLONE_ROOT/libadwaita-${version}"
	mkdir -p "$GIT_CLONE_ROOT"
	cd "$GIT_CLONE_ROOT"
	if [[ ! -d "$LIBADWAITA_DIR" ]] ; then
		git clone https://gitlab.gnome.org/GNOME/libadwaita.git "libadwaita-${version}"
	else
		cd "$LIBADWAITA_DIR"
		git checkout main
		git pull origin main
		git fetch --tags
		git checkout "$version"
	fi

	BASE_CSS_PATH="${SCRIPT_DIR}/libadwaita${version}.css"

	BASE_TEMPLATE_PATH="${SCRIPT_DIR}/themix.mustache.in"
	TEMPLATE_PATH_BUTTONS="${SCRIPT_DIR}/themix_buttons.mustache.in"
	TEMPLATE_PATH_CHECKRADIO="${SCRIPT_DIR}/themix_checkradio.mustache.in"

	RESULT_TEMPLATE_PATH="${SCRIPT_DIR}/gtk4-libadwaita${version}.mustache"


	cd "${LIBADWAITA_DIR}/src/stylesheet"
	sassc -a -M -t compact ./base.scss "$BASE_CSS_PATH"

	cd "$SCRIPT_DIR"
	cat "$BASE_CSS_PATH" "$BASE_TEMPLATE_PATH" "$TEMPLATE_PATH_BUTTONS" "$TEMPLATE_PATH_CHECKRADIO" \
	| sed \
		-e '/.*infobar.*:hover.*:hover.*:hover.*{.*alpha(currentColor.*}.*/d' \
		-e '/popover.*{ background\(-color\|\): alpha(currentColor,[0-9.]\+); }/d' \
		-e '/.*{ background-color: alpha(currentColor,[0-9.]\+); box-shadow: none; }/d' \
		-e '/.*assets\/.*}.*/d' \
	> "$RESULT_TEMPLATE_PATH"

	echo "gtk4-libadwaita${version}:
  extension: /gtk-4.0/gtk.css
  output: .themes/
  force_filename:" >> "$CONFIG_PATH"

done
