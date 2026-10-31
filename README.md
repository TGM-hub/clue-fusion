# Clue Fusion

GeoGuessr drill: two or three clues from the same country (a plate, a bollard, a sign in its language). Each clue alone fits several countries; together they fit only one. Pick it among six.

Live: https://tgm-hub.github.io/clue-fusion/ · direct link to a country: `#pl`, `#jp`…

## How a round is built
- **Plate** (from [plate-trainer](https://github.com/TGM-hub/plate-trainer)): fits its country, its listed look-alikes and the countries whose plates have the same look tags.
- **Bollard** (from [bollards-trainer](https://github.com/TGM-hub/bollards-trainer), photos geohints): fits every country with the same colours and material.
- **Sign** (from [Sign Reader](https://github.com/TGM-hub/script-identifier-geoguessr)): two place names in the language; fits the countries of that language and of its look-alike languages.
- A round only uses clues that fit 2+ countries each, of different kinds, whose countries have exactly one in common. Phone codes are left out (the country calling code gives the answer away).
- Options: the answer, then the countries fitting the most clues. After answering, each clue lists the countries it fits and each option shows ✓ for the clues it fits.
- Which country comes up: tier (Atlas `countries.json`), Leitner box, and (option) countries mixed up in any trainer (`tgm.confusions`).

## Data
- Plates and bollards are read at run time from the two sibling repos (`../plate-trainer/`, `../bollards-trainer/`): same site on GitHub Pages, sibling folders locally. Nothing is copied here. Opened from `file://`, bollards cannot load (browser rule on `fetch`): use the GitHub Pages site or a local server over the parent folder.
- Languages: `data/langs.js`, generated from Sign Reader by `py tools\sync_langs.py` (re-run after changing Sign Reader's languages).
- `tgm-core.js`: copy of the Atlas core (refreshed by the Atlas `build.cmd`).

## Progress
- `cluefusion.hist` (per country: seen, right, box), `cluefusion.prefs`.
- Shared with the Atlas: `tgm.stats.clue-fusion` (daily review) and `tgm.confusions` (mix-ups page).

## Publish
`publish.cmd`: preview, confirmation, commit, push (first run: creates the local git repo and links it to GitHub). Also part of the Atlas `publish-all.cmd`, after the smoke tests.
