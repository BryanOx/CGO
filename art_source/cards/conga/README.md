# Conga card sources (not exported)

Editable sources stay in the read-only `congauy` repository. The source pack at
`assets/cards-src/pack/` contains 49 SVGs of about 90 MB, pinned to commit
`907391d14b2b2d2fe41ec61207186ed64a838886` and checksummed in
`assets/cards-src/sources.sha256`. The separate `assets/cards-src/joker.svg` is
user-provided without a formal license grant.

These sources are excluded from the Godot export. CGO copies only the already
optimized 50 PNGs from `public/cards/` into `client/assets/cards/conga/classic_red/`,
together with the manifest, attribution, and provenance README. No source file
is modified, moved, or regenerated inside CGO.

Licensed audio is likewise not part of this tree; all source audio stays
excluded until a license decision is made. Catalog stable IDs are defined in
resources and are never filenames.
