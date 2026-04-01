## Objective

Phase E complete: all critical bugs fixed in `scripts/user.sh`. Phase B launcher scripts are next. Extended tool inventory compiled from book v11, Telegram OSINT channels (Cyber Detective, OSINTops) and Deep Dive PDF.

## Modified Files

- `scripts/user.sh` — v2.0.0, Phase E bug fixes (see Logical State)
- `tests/test_speculator_install.sh` — automated test suite, 24 tests (commit 0b0b984)
- `.git/config` — core.eol=lf, core.autocrlf=false

## Logical State

- Completed:
  - `speculator_install.sh` v8.0 stable (commit d8b946f)
  - Automated test suite: 24 tests, all passing (commit 0b0b984)
  - `scripts/user.sh` v2.0.0 — Phase E fixes:
    - Bug 1: Recursive `main()` replaced with `while true` loop (line 370)
    - Bug 2: Maigret venv path removed — now calls `maigret` directly via pipx; added `-P` flag
    - Bug 3: Eyes path corrected from `eyes/Eyes` to `$HOME/Downloads/Programs/Eyes`
    - All `pushd` calls now have `|| { zenity --error; return 1; }` error handling
    - All `~` replaced with `$HOME` (12 instances)
    - BDFR flag corrected: `--all-comments` → `--allcomments`
    - EVIDENCE_DIR changed to `$HOME/Desktop/evidence` (no trailing 's')
    - h8mail config path normalised to `$HOME/Downloads/h8mail_config.ini`
  - Swarm analysis complete: tool inventory from book v11 (2025), Cyber Detective TG (3393 msgs), OSINTops TG (3552 msgs), Deep Dive PDF

- Open for Phase B (launcher scripts to create):
  - `scripts/domain.sh` — Amass, Sublist3r, theHarvester, Photon, HTTrack
  - `scripts/video.sh` — yt-dlp, streamlink, gallery-dl
  - `scripts/image.sh` — ExifTool, MAT2, Sherloq, xeuledoc
  - `scripts/metadata.sh` — Carbon14, metagoofil, mediainfo
  - `scripts/api.sh` — SpiderFoot (web UI), Recon-ng, shodan, censys
  - `scripts/instagram.sh` — Instaloader, Toutatis, Osintgram
  - `scripts/reddit.sh` — BDFR, redditsfinder
  - `scripts/archives.sh` — waybackpy, archivebox, internetarchive
  - `scripts/update.sh` — pipx upgrade-all, git pull on all clones

- Additional tools identified for future phases (from Telegram/PDF analysis):
  HIGH priority: Nuclei + OSINT templates, PhoneNumber-OSINT (CLI), Bellingcat OSM Search,
    Turboholehe (enhanced holehe), sn0int (lightweight Recon-ng alt), Aleph/OCCRP
  MEDIUM: Mailcat, Terra, Profil3r, Zeeschuimer, TikTok Scraper, Spyse CLI, EagleEye
  DEPRECATED: Twint (Twitter API v2 broke it)

- Pending decisions for Phase B:
  - Language: single script with runtime selection (IT/EN/RU/ZH) or separate files?
  - Output format: plain .txt for Phase B, JSON for Phase C, or implement together?

## Next Action

Commit Phase E fix:
```bash
git add scripts/user.sh
git commit -m "Phase E: fix critical bugs in user.sh (v2.0.0)"
```

Then start Phase B — begin with `scripts/domain.sh` as first new launcher script.
CLI syntax confirmed from book v11:
- `./amass intel -o output.txt -active -ip -whois -d DOMAIN`
- `python3 sublist3r.py -d DOMAIN -o output.txt`
- `python3 theHarvester.py -d DOMAIN -f output.json -b duckduckgo`
- `python3 photon.py -u URL -l 3 -t 100`
- `webhttrack` (GUI) or `httrack` (CLI)
