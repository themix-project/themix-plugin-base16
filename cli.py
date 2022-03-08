# pylint: disable=wrong-import-position,import-error
import os
THEMIX_GUI_PATH: str
if os.environ.get('THEMIX_GUI_PATH'):
    THEMIX_GUI_PATH = os.environ['THEMIX_GUI_PATH']
else:
    import sys
    SCRIPT_DIR = '/'.join(__file__.split('/')[:-1])
    THEMIX_GUI_PATH = f'{SCRIPT_DIR}/../../'
sys.path.append(THEMIX_GUI_PATH)

from oomox_gui.theme_file_parser import read_colorscheme_from_path  # noqa

from oomox_plugin import render_base16_template, convert_oomox_to_base16  # noqa


def main():
    mustache_path = sys.argv[1]
    themix_theme_path = sys.argv[2]
    result = []
    read_colorscheme_from_path(themix_theme_path, callback=result.append)
    for item in result:
        themix_theme = item
    base16_theme = convert_oomox_to_base16(theme_name='test', colorscheme=themix_theme)
    print(
        render_base16_template(mustache_path, base16_theme)
    )


if __name__ == "__main__":
    main()
