#!/usr/bin/env bash
set -ueo pipefail
set -x

SCRIPT_DIR="$(readlink -e "$(dirname "${0}")")"

GIT_CLONE_ROOT="$HOME/tmp"
mkdir -p "$GIT_CLONE_ROOT"
cd "$GIT_CLONE_ROOT"
if [[ ! -d "$GIT_CLONE_ROOT/adw-gtk3" ]] ; then
	git clone https://github.com/lassekongo83/adw-gtk3
else
	cd adw-gtk3
	git pull origin main
fi

ADW_GTK3_DIR="$(readlink -e ~/tmp/adw-gtk3)"
BASE_CSS_PATH="${SCRIPT_DIR}/gtk.css"

BASE_TEMPLATE_PATH="${SCRIPT_DIR}/themix.mustache.in"
TEMPLATE_PATH_BUTTONS="${SCRIPT_DIR}/themix_buttons.mustache.in"
TEMPLATE_PATH_CHECKRADIO="${SCRIPT_DIR}/themix_checkradio.mustache.in"

RESULT_TEMPLATE_PATH="${SCRIPT_DIR}/gtk.mustache"


cd "${ADW_GTK3_DIR}/gtk/src/adw-gtk3/gtk-3.0"
sassc -a -M -t compact ./gtk.scss "$BASE_CSS_PATH"

cd "$SCRIPT_DIR"
cat "$BASE_CSS_PATH" "$BASE_TEMPLATE_PATH" "$TEMPLATE_PATH_BUTTONS" "$TEMPLATE_PATH_CHECKRADIO" \
| sed \
	-e '/.*infobar.*:hover.*:hover.*:hover.*{.*alpha(currentColor.*}.*/d' \
	-e '/popover.*{ background\(-color\|\): alpha(currentColor,[0-9.]\+); }/d' \
	-e '/.*{ background-color: alpha(currentColor,[0-9.]\+); box-shadow: none; }/d' \
	-e '/.*assets\/.*}.*/d' \
> "$RESULT_TEMPLATE_PATH"
