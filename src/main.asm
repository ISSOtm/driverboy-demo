
SECTION "Entry point", ROM0

EntryPoint:
	; TODO

SECTION "Header", ROM0[$100]

	jp EntryPoint
	ds $150 - @, 0
