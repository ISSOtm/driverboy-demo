#!/usr/bin/env bash
rm -rf bin obj
rm -f src/version.asm
find assets \! \( -name .gitignore -o -name assets.sh -o -name '*.do' \) -type f -delete
