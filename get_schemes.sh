#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(readlink -e "$(dirname "${0}")")

SCHEMES_INDEX_URL=https://raw.githubusercontent.com/chriskempson/base16-schemes-source/master/list.yaml
SCHEMES_INDEX="${SCRIPT_DIR}"/schemes.yaml
SCHEMES_WORKDIR="${SCRIPT_DIR}"/schemes.tmp
SCHEMES_RESULT_DIR="${SCRIPT_DIR}"/schemes


get_scheme() {(
	name="${1//[[:space:]]/}"
	url="${2//[[:space:]]/}"
	echo
	cd "$SCHEMES_WORKDIR"
	if [[ -d "$name" ]] ; then
		cd "$name"
		git pull origin master
	else
		git clone "$url" "$name"
	fi
)}


curl "${SCHEMES_INDEX_URL}" -o "${SCHEMES_INDEX}"
mkdir -p "${SCHEMES_WORKDIR}"
while read -r line ; do
	name=$(cut -d: -f1 <<< "${line}")
	link=$(cut -d: -f2-999 <<< "${line}")
	test -z "${link}" && continue
	get_scheme "$name" "$link"
done < <(grep -v '^#' "${SCHEMES_INDEX}")

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
echo ':: done ::'
