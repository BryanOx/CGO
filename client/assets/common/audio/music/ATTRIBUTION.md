# Music attribution

Music by HoliznaCC0 (Holizna).

Declared CC0 1.0 by the asset owner: http://creativecommons.org/publicdomain/zero/1.0/

The four MP3 files in this folder are verbatim copies from
`congauy/public/sounds/music/`. Their original filenames were:

- `01 HoliznaCC0 - Dreams.mp3` → `dreams.mp3`
- `02 HoliznaCC0 - Day Jobs.mp3` → `day-jobs.mp3`
- `03 HoliznaCC0 - Childhood.mp3` → `childhood.mp3`
- `04 HoliznaCC0 - Dancing.mp3` → `dancing.mp3`

## Evidence and limits

`congauy/src/lib/audio.test.ts:5` quotes the shipped name
`01 HoliznaCC0 - Dreams.mp3`. Commit `7cb791d` ("chore(sounds): rename music
tracks to URL-safe slugs") records the rename of the four tracks, and the
archived task list `openspec/changes/archive/2026-09-25-screen-shell-audio/tasks.md:80`
records the full four-name mapping above.

No separate license file for these tracks was found in either source repository
or in Downloads. The Kenney `effects/LICENSE.txt` covers the 13 OGG effects
only; it does not cover this music. The CC0 status recorded here is a user
declaration as the asset owner, not an externally verified license. SHA-256 and
byte counts for the four files are pinned in `manifest.json` and checked by
`python3 client/tools/verify_audio_assets.py`.
