#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ARGS=("$@")

get_asset() {(
	destination="$1"
	line="$2"
	name=$(cut -d: -f1 <<< "${line}" | tr -d '[:space:]')
	path=$(cut -d: -f2-999 <<< "${line}")
	test -z "${path}" && return

	url=$(cut -d' ' -f2 <<< "${path}" | tr -d '[:space:]')
	dir=$(cut -d' ' -f3-999 <<< "${path}" | tr -d '[:space:]')

	echo
	echo "======== $name ($url) ========"

	cd "$destination"
	if [[ -d "$name" ]] ; then
		(
		cd "$name"
		git pull origin master
		)
	else
		git clone "$url" "$name"
	fi

	if [[ -n "${dir}" ]] ; then
		cd "$name"
		git clean -f -d -x
		git checkout -- '*'
		mv "$dir"/* ./ || echo "can't move: ${ARGS[*]}"
	fi
)}

get_asset "${ARGS[@]}" || echo "smth wen't wrong: ${ARGS[*]}"
