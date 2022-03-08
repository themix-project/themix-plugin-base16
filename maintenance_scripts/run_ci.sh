#!/usr/bin/env bash
set -ueo pipefail

if [[ -z "${DISPLAY:-}" ]] ; then
	# we need it as we're a GTK app:
	Xvfb :99 -ac -screen 0 1920x1080x16 -nolisten tcp 2>&1  &
	xvfb_pid="$!"

	clean_up() {
		echo -e "\n== Killing Xvfb..."
		kill ${xvfb_pid}
		echo "== Done."
	}
	trap clean_up EXIT SIGHUP SIGINT SIGTERM

	echo '== Started Xvfb'
	export DISPLAY=:99
	sleep 3
fi

export PYTHONWARNINGS='default,error:::oomox_gui[.*],error:::plugins[.*]'
if [[ -n "${THEMIX_GUI_PATH:-}" ]] ; then
	export PYTHONPATH="$THEMIX_GUI_PATH"
	export MYPYPATH="./maintenance_scripts/mypy_stubs:${THEMIX_GUI_PATH}:${THEMIX_GUI_PATH}/maintenance_scripts/mypy_stubs"
else
	export PYTHONPATH=../../
fi
echo "PYTHONPATH=${PYTHONPATH}"
echo "MYPYPATH=${MYPYPATH:-}"

TARGETS=(
	'./maintenance_scripts/gtk_init_for_pylint_sigh.py'
	'oomox_plugin.py'
	'cli.py'
)

echo '== Running on system python'
python3 --version

echo -e "\n== Running python compile:"
python3 -O -m compileall "${TARGETS[@]}" | (grep -v -e '^Listing' -e '^Compiling' || true)
echo ':: python compile passed ::'

echo -e "\n== Running flake8:"
flake8 "${TARGETS[@]}"
echo ':: flake8 passed ::'

echo -e "\n== Running pylint:"
#pylint --jobs="$(nproc)" "${TARGETS[@]}" --score no
pylint "${TARGETS[@]}" --score no
echo ':: pylint passed ::'


if [[ "${SKIP_MYPY:-}" = "1" ]] ; then
	echo -e "\n!! WARNING !! skipping mypy"
else
	echo -e "\n== Running mypy:"
	python -m mypy "${TARGETS[@]}"
	echo ':: mypy passed ::'
fi


if false ; then
	if [[ "${SKIP_VULTURE:-}" = "1" ]] ; then
		echo -e "\n!! WARNING !! skipping vulture"
	else
		echo -e "\n== Running vulture:"
		vulture "${TARGETS[@]}" \
			./maintenance_scripts/vulture_whitelist.py \
			--min-confidence=1 \
			--sort-by-size
		echo ':: vulture passed ::'
	fi
fi


if [[ "${SKIP_SHELLCHECK:-}" = "1" ]] ; then
	echo -e "\n!! WARNING !! skipping shellcheck"
else
	echo -e "\n== Running shellcheck:"
	TEST_DIR=$(readlink -e "$(dirname "${0}")")
	SCRIPT_DIR="$(readlink -e "${TEST_DIR}"/..)"

	(
		cd "${SCRIPT_DIR}"
		# shellcheck disable=SC2046
		shellcheck $(find . \
			-name '*.sh' \
			-not -path './*.tmp/*' \
			-or -path './packaging/bin/*' \
		)
	)

	echo ':: shellcheck passed ::'
fi


echo -e "\n"'$$ All checks have been passed successfully $$'
