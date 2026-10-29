# 动感101 time-shift radio

[中文](README.md) · English

Open it at 7 am in New York and you hear what Shanghai's 动感101 (FM 101.7) played at 7 am Shanghai time.

A server records the live stream around the clock. When your phone opens the page, the server plays back
the recording whose Shanghai wall-clock time matches your local wall-clock time. One Python file, standard
library only, a $4/month server is enough.

<p align="center">
  <img src="docs/shot-bund-night.jpg" width="230" alt="The Bund at night">
  <img src="docs/shot-zhouzhuang.jpg" width="230" alt="Zhouzhuang canal">
  <img src="docs/shot-wukang-road.jpg" width="230" alt="Wukang Road">
</p>

## How it works

- The server pulls the live stream continuously, stores it as one-minute MP3 chunks and keeps the last 48 hours.
- The page sends your time zone; the server finds the moment where "Shanghai clock = your clock" and streams
  from there at real-time pace. Playback continues with the screen locked, with lock-screen controls.
- New York is 12 or 13 hours behind Shanghai, so what you want to hear is always already recorded. East of
  Shanghai there is nothing to shift to, so the page falls back to the live stream and says so.
- No ffmpeg, no database, no third-party packages, about 20MB of RAM.

## Features

- "My time / Shanghai live" toggle.
- Now-playing card with host, progress and the next show (weekday schedule from Qingting FM).
- −30s / start of show / +30s in shifted mode; lock-screen seek buttons work too.
- Sleep timer (15 / 30 / 60 / 90 min), share sheet, listener count (deduplicated per device).
- Backgrounds: 30 freely licensed photos of Shanghai and Kunshan from Wikimedia Commons (credits on the page and
  in `photos/CREDITS.md`), with weather animations (neon bokeh, fireflies, sun motes, rain and lightning, cherry
  petals, falling leaves, snow) and a WebGL aurora. Random shuffle every 30 seconds, or pin a scene.
- Clear-glass cards; after 7 seconds of untouched playback the UI fades to 16% so the photo shows through.

## Deploy to a server (recommended)

1. Create a small Ubuntu 24.04 server (the cheapest DigitalOcean droplet, $4/month, 512MB, is enough).
2. Authenticate with an SSH key. The script uses `~/.ssh/radio1017_ed25519` by default; create one with
   `ssh-keygen -t ed25519 -f ~/.ssh/radio1017_ed25519` and paste the `.pub` into the provider's console, or point
   it elsewhere with `RADIO_SSH_KEY=~/.ssh/id_ed25519 ./deploy.sh ...`.
3. From this folder:

```bash
./deploy.sh <server-ip> America/New_York
```

The second argument is the time zone used for "my time". The script installs a systemd service and Caddy, gets
an https certificate automatically, opens the firewall and prints the URL for your phone, like
`https://1-2-3-4.sslip.io/key/`. The random key in the path keeps strangers out. Re-run the same command after
changing the code; the key stays. Pass a third argument to rotate it.

Open the URL in Safari and use "Share → Add to Home Screen".

## Run on a Mac instead

`./install.sh` installs a launchd background service (program and recordings under
`~/Library/Application Support/radio1017`) and prints the LAN URL. `./uninstall.sh` removes it
(`--purge` also deletes recordings). Or just run `python3 radio1017.py` and open http://localhost:8017.
Environment variables: `RADIO_PORT`, `RADIO_BIND`, `RADIO_KEY` (path prefix), `RADIO_LOCAL_TZ`, `RADIO_DATA`.

## Another station

`STREAMS` at the top of `radio1017.py` is the stream URL, `STATION_TZ` the station's time zone, `SCHEDULE` in
the page is the programme guide, and `LOGO_B64` / `ICON_B64` hold the logo. Change those and it works for any
station with a plain MP3 stream.

## License

Code: MIT. Photos: Wikimedia Commons, individual CC licenses and authors in `photos/CREDITS.md`.
The 动感101 logo and programmes belong to Shanghai Media Group; this is a personal, non-commercial listening tool
and is not affiliated with the station.

Author: zht
