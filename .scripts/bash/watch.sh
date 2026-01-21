#!/bin/sh

set -e

if [ ! -d "roblox_packages" ]; then
    pesde install
fi

rojo sourcemap default.project.json -o sourcemap.json --watch \
    & pesde run generate_signals \
    & pesde run generate_interfaces \