#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(readlink -e "$(dirname "${0}")")

SCHEMES_INDEX_URL=https://raw.githubusercontent.com/chriskempson/base16-schemes-source/master/list.yaml
TEMPLATES_INDEX_URL=https://raw.githubusercontent.com/chriskempson/base16-templates-source/master/list.yaml

SCHEMES_INDEX="${SCRIPT_DIR}"/schemes.yaml
SCHEMES_WORKDIR="${SCRIPT_DIR}"/schemes.tmp
SCHEMES_RESULT_DIR="${SCRIPT_DIR}"/schemes

TEMPLATES_INDEX="${SCRIPT_DIR}"/templates.yaml
TEMPLATES_EXTRA_DIR="${SCRIPT_DIR}"/templates_extra
TEMPLATES_WORKDIR="${SCRIPT_DIR}"/templates.tmp
TEMPLATES_RESULT_DIR="${SCRIPT_DIR}"/templates


GET_ASSET="${SCRIPT_DIR}/_get_asset.sh"

get_template() {
	get_asset "$1" "$TEMPLATES_WORKDIR"
}


curl "${SCHEMES_INDEX_URL}" -o "${SCHEMES_INDEX}"
mkdir -p "${SCHEMES_WORKDIR}"
grep -v '^#' "${SCHEMES_INDEX}" | parallel "${GET_ASSET}" "${SCHEMES_WORKDIR}"

rsync -rv \
	--exclude=".git" \
	--exclude="output" \
	--exclude="circus/circus" \
	--include="*/" \
	--include="*.yml" \
	--include="*.yaml" \
	--exclude="*" \
	"$SCHEMES_WORKDIR"/ "$SCHEMES_RESULT_DIR"
sync
sleep 0.001
echo 'Clean-up:'
find "$SCHEMES_RESULT_DIR" -type d -empty -print0 | xargs --null rmdir || true
echo 'Check-up:'
find "$SCHEMES_RESULT_DIR" -type d -empty -print0 | xargs --null echo
echo ':: schemes done ::'


curl "${TEMPLATES_INDEX_URL}" -o "${TEMPLATES_INDEX}"
grep -v '^#' "${TEMPLATES_INDEX}" | parallel "${GET_ASSET}" "${TEMPLATES_WORKDIR}"

rsync -rv \
	--exclude=".git" \
	--include="*/" \
	--include="*/templates/*" \
	--exclude="*" \
	"$TEMPLATES_WORKDIR"/ "$TEMPLATES_RESULT_DIR"
rsync -rv \
	"$TEMPLATES_EXTRA_DIR"/ "$TEMPLATES_RESULT_DIR"
sync
sleep 0.001
echo 'Clean-up:'
find "$TEMPLATES_RESULT_DIR" -type d -empty -print0 | xargs --null rmdir || true
echo 'Check-up:'
find "$TEMPLATES_RESULT_DIR" -type d -empty -print0 | xargs --null echo
echo ':: templates done ::'

