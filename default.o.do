#!/usr/bin/env bash
set -euo pipefail

INCPATHS=(src/ src/lib/fortISSimO/include/) # `src/` is required for the "VPATH"-like functionality.
WARNINGS=(all  extra  no-unmapped-char)
ASFLAGS=(-p 0xFF  "${INCPATHS[@]/#/-I}"  "${WARNINGS[@]/#/-W}")

# Look for sources in `src/`, but if not found, try in `obj/` as they might be auto-generated.
SRC="src/${2#obj/}"
if ! [[ -e "$SRC" ]]; then
	SRC="obj/${SRC#src/}"
fi
redo-ifchange "$SRC"

mkdir -p "${2%/*}" # Create the output directory.

# RGBASM exits with status 0 if either it completed successfully, or it encountered a missing dependency.
# To distinguish the two, we check for the output file, which is only produced in the former case.
# But if the output already exists, we may take the latter for the former; so, delete it.
rm -rf "$3"

# Add the already-discovered dependencies. This enables redoing them before attempting to assemble
# the file, which is sometimes required to avoid build failures (e.g. a constant defined by an
# included file is required by the new file).
if [[ -e "$2.mk" ]]; then
	while IFS= read -r dep; do
		dep=${dep##*: }
		# Don't require something that doesn't exist, as it may be a stale dependency whose redo
		# rule has been deleted; Redo would abort as "no rule to redo <stale dep>".
		# If it doesn't exist yet but is actually required, it will be picked up during the
		# automatic dependency discovery, which will work fine.
		[[ ! -e "$dep" ]] || echo "$dep"
	done <"$2.mk" | xargs redo-ifchange
fi

until [[ -e "$3" ]]; do
	# Attempt to build and discover dependencies, passing each of them to `redo-ifchange` via `-M`.
	# Redirect RGBASM's stdout (which `PRINTLN` & co. write to) to a file,
	# since stdout points at the output file ($3), and we don't want to corrupt it
	# by adding text to it...
	# Additionally, some commands may want to do something with that output.
	rgbasm >"$2.out" "${ASFLAGS[@]}" "$SRC" -o "$3" -M "$2.mk.tmp" -MG
	# On build failure, the dep file might contain gibberish.
	# Don't treat it as worth considering if the build failed, otherwise the next attempt might get
	# stuck looking for a bogus dependency, even before entering this loop!
	mv "$2.mk"{.tmp,}
	# Dependencies are passed via a file so we can wait for `redo-ifchange` to complete
	# (`> >(cmd)` spawns `cmd` as a background process), and because we can't use a pipe
	# (stdout would conflict with e.g. `println`).
	cut -d : -f 2- "$2.mk" | xargs redo-ifchange
	# We will keep retrying until all dependencies have been built, since then RGBASM will have generated the output file.
done

# Generate the debugfile.
rgbasm -DPRINT_DEBUGFILE >"$2.dbg" "${ASFLAGS[@]}" "$SRC"
