#!/usr/bin/env bash
set -ueo pipefail
set -x

SCRIPT_DIR="$(readlink -e "$(dirname "${0}")")"

if [[ ! -d "$HOME/tmp/libadwaita" ]] ; then
	cd "$HOME/tmp/"
	git clone https://gitlab.gnome.org/GNOME/libadwaita
fi

LIBADWAITA_DIR="$(readlink -e ~/tmp/libadwaita)"
BASE_CSS_PATH="${SCRIPT_DIR}/libadwaita.css"

BASE_TEMPLATE_PATH="${SCRIPT_DIR}/themix.mustache.in"
BUTTONS_TEMPLATE_PATH="${SCRIPT_DIR}/themix_buttons.mustache.in"

RESULT_TEMPLATE_PATH="${SCRIPT_DIR}/gtk.mustache"


cd "${LIBADWAITA_DIR}/src/stylesheet"
sassc -a -M -t compact ./base.scss "$BASE_CSS_PATH"

cd "$SCRIPT_DIR"
cat "$BASE_CSS_PATH" "$BASE_TEMPLATE_PATH" "$BUTTONS_TEMPLATE_PATH" \
| sed \
	-e '/.*infobar.*:hover.*:hover.*:hover.*{.*alpha(currentColor.*}.*/d' \
	-e '/popover.*{ background\(-color\|\): alpha(currentColor,[0-9.]\+); }/d' \
	-e '/.*{ background-color: alpha(currentColor,[0-9.]\+); box-shadow: none; }/d' \
> "$RESULT_TEMPLATE_PATH"
