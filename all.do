#!/usr/bin/env bash
set -euo pipefail

VERSION=0
LDFLAGS=(-p 0xFF -dt)
FIXFLAGS=(-p 0xFF
	-j -c
	-i DBOY
	-k SF # Stoneface ;)
	-l 0x33
	-m ROM_only
	-n "$VERSION"
	-r 0 # No SRAM.
	-t 'Banger 🤘')

# We do this before the `OBJS` detection, to ensure that it is picked up, only once, and from `src/`.
redo obj/build_date.asm.o # Unconditionally re-compute the build date.

mapfile -d '' OBJS < <(find src -name '*.asm' -printf 'obj/%P.o\0' \
                             -o -name '*.tbm' -printf 'obj/%P.asm.o\0')
redo-ifchange "${OBJS[@]}"

mkdir -p bin/
rgblink "${LDFLAGS[@]}"  -o - -m bin/banger.map -n bin/banger.sym  "${OBJS[@]}" | rgbfix - >bin/banger.gb  -v "${FIXFLAGS[@]}"


printf '@debugfile 1.0.0\n' >bin/banger.dbg
printf '@include "../%s.dbg"\n' "${OBJS[@]%.o}" >>bin/banger.dbg
