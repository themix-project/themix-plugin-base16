#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'


get_asset() {(
	destination="$1"
	line="$2"
	name=$(cut -d: -f1 <<< "${line}" | tr -d '[:space:]')
	url=$(cut -d: -f2-999 <<< "${line}" | tr -d '[:space:]')
	test -z "${url}" && return

	echo
	cd "$destination"
	if [[ -d "$name" ]] ; then
		cd "$name"
		git pull origin master
	else
		git clone "$url" "$name"
	fi
)}

get_asset "$@"
