# Sound effect attribution

The 13 OGG files in this folder are verbatim copies from
`congauy/public/sounds/cards/`. They originate from the Casino Audio (1.1)
pack by Kenney Vleugels (Kenney.nl), distributed under Creative Commons Zero
(CC0) 1.0: http://creativecommons.org/publicdomain/zero/1.0/

Credit is not mandatory under CC0; it is recorded here for provenance. The
Kenney license applies to these 13 effects only; the MP3 music in `../music/`
is covered by a separate owner declaration.

## Verification method

1. The pack license is copied verbatim to `LICENSE.txt` from
   `/home/bryan/Descargas/kenney_casino-audio/License.txt` (487 bytes).
2. Each OGG was copied with `cp` from `congauy/public/sounds/cards/` and
   compared byte-for-byte with the matching file in
   `/home/bryan/Descargas/kenney_casino-audio/Audio/`.
3. `manifest.json` pins the SHA-256 and byte count of every copied file.
   `python3 client/tools/verify_audio_assets.py` checks those values, the
   license and attribution text, and the absence of audio outside this folder.
4. The original files in both source repositories were left unchanged.
