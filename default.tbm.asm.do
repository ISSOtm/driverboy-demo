#!/usr/bin/env bash
set -euo pipefail

TBM="src/${2#obj/}.tbm"
redo-ifchange "$TBM"

mkdir -p "${2%/*}"
if [[ -z "${TBC-}" ]]; then
	TBC=src/driverboy/target/release/assemboy
	# Unconditionally build the assemboy binary. I don't know what the overhead of that is.
	env -C src/driverboy/assemboy/ cargo build --quiet --release
	# Rebuild the scripts if the compiler itself changes.
	# This is a little tricky, because Cargo outputs absolute paths, which can contain spaces...
	# but the Make syntax also separates elements with spaces!
	# So we try splitting on the path up to the repo itself; the rest shouldn't contain spaces.
	SPLIT=$(printf 's,%s/,\\n,g\n' "$(realpath . | sed 's!,!\,!')")
	cut -d : -f 2- src/driverboy/target/release/assemboy.d | sed "$SPLIT" | xargs redo-ifchange
fi
exec "$TBC" -t ROM0 -n "Music track from ${TBM//[\\\"]/\\&}" -d "Music_$(basename "$TBM" .tbm)" "$TBM" "$3"
