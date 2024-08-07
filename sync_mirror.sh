#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(readlink -e "$(dirname "${0}")")

SCHEMES_INDEX_URL=https://raw.githubusercontent.com/chriskempson/base16-schemes-source/master/list.yaml
TEMPLATES_INDEX_URL=https://raw.githubusercontent.com/chriskempson/base16-templates-source/master/list.yaml

SCHEMES_INDEX="${SCRIPT_DIR}"/schemes.yaml
SCHEMES_EXTRA_INDEX="${SCRIPT_DIR}"/schemes_extra.yaml
SCHEMES_EXTRA_DIR="${SCRIPT_DIR}"/schemes_extra
SCHEMES_WORKDIR="${SCRIPT_DIR}"/schemes.tmp
SCHEMES_RESULT_DIR="${SCRIPT_DIR}"/schemes

TEMPLATES_INDEX="${SCRIPT_DIR}"/templates.yaml
TEMPLATES_EXTRA_INDEX="${SCRIPT_DIR}"/templates_extra.yaml
TEMPLATES_RENAME="${SCRIPT_DIR}"/templates_rename.txt
TEMPLATES_EXTRA_DIR="${SCRIPT_DIR}"/templates_extra
TEMPLATES_WORKDIR="${SCRIPT_DIR}"/templates.tmp
TEMPLATES_RESULT_DIR="${SCRIPT_DIR}"/templates


GET_ASSET="${SCRIPT_DIR}/_get_asset.sh"

if [[ ${1:-} != '--extra-only' ]] ; then

	curl "${SCHEMES_INDEX_URL}" -o "${SCHEMES_INDEX}"
	mkdir -p "${SCHEMES_WORKDIR}"
	if command -v parallel > /dev/null ; then
		grep -hv '^#' "${SCHEMES_INDEX}" "${SCHEMES_EXTRA_INDEX}" | parallel "${GET_ASSET}" "${SCHEMES_WORKDIR}"
	else
		# shellcheck disable=SC2046
		parallel-moreutils "${GET_ASSET}" "${SCHEMES_WORKDIR}" -- $(grep -hv '^#' "${SCHEMES_INDEX}" "${SCHEMES_EXTRA_INDEX}" )
	fi

	rsync -rv \
		--delete \
		--exclude=".git" \
		--exclude=".github" \
		--exclude=".travis.yml" \
		--exclude="output" \
		--exclude="circus/circus" \
		--include="*/" \
		--include="*/*.yml" \
		--include="*/*.yaml" \
		--exclude="*" \
		"$SCHEMES_WORKDIR"/ "$SCHEMES_RESULT_DIR"
	sync
	sleep 0.001
	echo 'Clean-up empty-dirs:'
	find "$SCHEMES_RESULT_DIR" -type d -empty -print0 | xargs --null rmdir || true
	echo 'Check-up (debug):'
	find "$SCHEMES_RESULT_DIR" -type d -empty -print0 | xargs --null echo
	echo ':: schemes done ::'


	curl "${TEMPLATES_INDEX_URL}" -o "${TEMPLATES_INDEX}"
	mkdir -p "${TEMPLATES_WORKDIR}"
	if command -v parallel ; then
		grep -hv '^#' "${TEMPLATES_INDEX}" "${TEMPLATES_EXTRA_INDEX}" | parallel "${GET_ASSET}" "${TEMPLATES_WORKDIR}"
	else
		# shellcheck disable=SC2046
		parallel-moreutils "${GET_ASSET}" "${TEMPLATES_WORKDIR}" -- $(grep -hv '^#' "${TEMPLATES_INDEX}" "${TEMPLATES_EXTRA_INDEX}")
	fi

	while read -r line ; do
		rename_from=$(cut -d: -f1 <<< "$line")
		rename_to=$(cut -d: -f2 <<< "$line")
		rm -r "${TEMPLATES_WORKDIR:?}/${rename_to}" || true
		mv "${TEMPLATES_WORKDIR}/${rename_from}" "${TEMPLATES_WORKDIR}/${rename_to}"
	done < <(sed -e 's/ -> /:/g' < "$TEMPLATES_RENAME")

	rsync -rv \
		--delete \
		--exclude=".git" \
		--include="*/" \
		--include="*/templates/*" \
		--exclude="*" \
		"$TEMPLATES_WORKDIR"/ "$TEMPLATES_RESULT_DIR"

fi

if [[ -d "$SCHEMES_EXTRA_DIR" ]] ; then
	echo ":: extra schemes:"
	rsync -rv \
		"$SCHEMES_EXTRA_DIR"/ "$SCHEMES_RESULT_DIR"
fi

echo ":: extra templates:"
for pre_build_script in "$TEMPLATES_EXTRA_DIR"/*/templates/pre_build.sh ; do
	"${pre_build_script}"
done
rsync -rv \
	"$TEMPLATES_EXTRA_DIR"/ "$TEMPLATES_RESULT_DIR"

sync

sleep 0.001
echo 'Clean-up empty dirs:'
find "$TEMPLATES_RESULT_DIR" -type d -empty -print0 | xargs --null rmdir || true
echo 'Check-up (debug):'
find "$TEMPLATES_RESULT_DIR" -type d -empty -print0 | xargs --null echo
echo ':: templates done ::'

