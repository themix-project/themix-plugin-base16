# pylint: disable=wrong-import-position,import-error
import os
import sys

SCRIPT_DIR = "/".join(__file__.split("/")[:-1])
THEMIX_GUI_PATH: str
if os.environ.get("THEMIX_GUI_PATH"):
    THEMIX_GUI_PATH = os.environ["THEMIX_GUI_PATH"]
else:
    THEMIX_GUI_PATH = f"{SCRIPT_DIR}/../../"
sys.path.append(THEMIX_GUI_PATH)
sys.path.append(SCRIPT_DIR)

from oomox_gui.theme_file_parser import read_colorscheme_from_path  # noqa[E402]
from oomox_gui.theme_file import ThemeT  # noqa[E402]

from oomox_plugin import render_base16_template, convert_oomox_to_base16  # noqa[E402]


def print_help() -> None:
    print(f"Usage: {sys.argv[0]} BASE16_TEMPLATE_PATH THEMIX_THEME_PATH")


def main() -> None:
    if len(sys.argv) < 3:
        print_help()
        sys.exit(1)
    mustache_path = sys.argv[1]
    themix_theme_path = sys.argv[2]
    result: list[ThemeT] = []
    read_colorscheme_from_path(themix_theme_path, callback=result.append)
    for item in result:
        themix_theme = item
    base16_theme = convert_oomox_to_base16(colorscheme=themix_theme)
    print(
        render_base16_template(mustache_path, base16_theme),
    )


if __name__ == "__main__":
    main()
