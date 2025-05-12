Themix Base16 plugin
====================

[![Code Style](https://github.com/themix-project/themix-plugin-base16/actions/workflows/ci.yml/badge.svg)](https://github.com/themix-project/themix-plugin-base16/actions/workflows/ci.yml) [![Commit Activity](https://img.shields.io/github/commit-activity/y/themix-project/themix-plugin-base16?color=pink&logo=amp&logoColor=pink)](https://github.com/themix-project/themix-plugin-base16/graphs/commit-activity)

## Dependencies (for CLI and Themix-plugin)

 - themix-gui [ @TODO: decouple CLI for GUI libs ]
 - pystache
 - python-yaml

## Dependencies (for sync mirror, not plugin itself)

 - grep
 - curl
 - moreutils or parallel
 - git
 - rsync
 - find
 - dart-sass (gtk3 oodwaita)
 - sassc (gtk4 oodwaita)

## FAQ

User templates could be stored in `~/.config/oomox/base16/templates`.

User themes are stored in `~/.config/oomox/colors/__plugin__base16`.
