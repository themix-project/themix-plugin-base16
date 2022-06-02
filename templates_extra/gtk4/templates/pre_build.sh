#!/usr/bin/env bash
set -ueo pipefail

set -x

LIBADWAITA_DIR="$(readlink -e ~/tmp/libadwaita)"
SCRIPT_DIR="$(readlink -e "$(dirname "${0}")")"
BASE_CSS_PATH="${SCRIPT_DIR}/libadwaita.css"
BASE_TEMPLATE_PATH="${SCRIPT_DIR}/themix.mustache"
RESULT_TEMPLATE_PATH="${SCRIPT_DIR}/default.mustache"

cd "${LIBADWAITA_DIR}/src/stylesheet"
sassc -a -M -t compact ./base.scss "$BASE_CSS_PATH"

cd "$SCRIPT_DIR"
cat "$BASE_CSS_PATH" "$BASE_TEMPLATE_PATH" > "$RESULT_TEMPLATE_PATH"
