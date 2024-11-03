#!/bin/sh

set -euo pipefail

# Backup existing osu-lazer pin
old_osu_pin=$(mktemp)
jq '.pins.osu' npins/sources.json > $old_osu_pin

nix run nixpkgs#npins update

fetched_osu_tag="$(jq -r '.pins.osu.version' npins/sources.json)"
url="https://github.com/ppy/osu/releases/download/${fetched_osu_tag}/osu.AppImage"

if ! nix store prefetch-file "$url" --json 2>&1 >/dev/null; then
    echo "Latest osu!lazer tag is NOT a release, reverting npins' attempt to update it"
    jq -s '.[0].pins.osu = .[1] | .[0]' npins/sources.json "$old_osu_pin" > npins/fixed_sources.json
    rm npins/sources.json
    mv npins/fixed_sources.json npins/sources.json
fi
