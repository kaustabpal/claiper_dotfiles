# Agent instructions: claiper i3 restore

Read this file first. Then restore the desktop. Do not improvise around the safety rules.

Repo: https://github.com/kaustabpal/claiper_dotfiles  
SSH: `git@github.com:kaustabpal/claiper_dotfiles.git`  
Owner: Kaustab (`kaustab`). Host family: caliper-01 / DGX Spark, Ubuntu 24.04, aarch64, NVIDIA GB10, X11.

This agent is a tool. Act. Do not chat. After each phase print a short status.

## Goal

Reproduce the working i3 session on a new or wiped Ubuntu user home.

Success means all of these are true:

1. GDM can start an **i3** session via `~/.local/bin/i3-session`.
2. Super is `$mod`. Super+Enter opens a terminal. Super+Space opens rofi.
3. Bar shows GPU temp, date, clock. Clock click opens calendar. WiFi tray is dark.
4. Super+Shift+x opens the console lock. Super+Shift+e opens the rofi power menu.
5. Volume keys or Super+= / Super+- change PipeWire volume.
6. Firefox launched from `~/.local/bin/firefox` can type, show tab labels, and open menus.
7. GNOME remains installed as fallback. Display mode stays `HDMI-0` `2560x1440`.

## Hard rules

1. Read `reference/i3_gnome_display.md` before any display, DPI, scale, or session change.
2. Do not set `GDK_SCALE`, `GDK_DPI_SCALE`, `QT_SCALE_FACTOR`, or `QT_AUTO_SCREEN_SCALE_FACTOR` in `~/.profile`, `~/.bashrc`, `~/.xprofile`, or `~/.xsessionrc`.
3. Do not run `xrandr --scale` except `1x1`.
4. Do not start `xsettingsd` while using snap Firefox.
5. Do not set global gsettings to `Yaru-purple-dark` or `prefer-dark` for Firefox. Keep:
   - `org.gnome.desktop.interface gtk-theme` = `Yaru`
   - `org.gnome.desktop.interface color-scheme` = `default`
6. Do not commit or copy Firefox cookies, passwords, SSH private keys, or GNOME keyring.
7. Do not purge GNOME, gdm, or make i3 the only session.
8. Do not install Hyprland as the daily path on this host.
9. Isolate WiFi and calendar GTK under `~/.config/i3-gtk/`. Do not restyle Firefox with host GTK CSS.
10. If sudo is required, print the exact command and wait. Do not invent passwords.

## Defaults

| Decision | Default |
| --- | --- |
| Clone path | `~/Developer/claiper_dotfiles` |
| User | current `$USER` (expected `kaustab`) |
| Session | i3 via `i3-session` (Xft.dpi=96) |
| Display | `HDMI-0` `2560x1440` |
| Terminal | `ghostty` if present, else `x-terminal-emulator` |
| Firefox | snap + `~/.local/bin/firefox` wrapper |
| Audio | PipeWire `wpctl`, not `pactl` |
| Lock | `~/.local/bin/i3-lock` → console lock |
| Theme for Firefox process | `GTK_THEME=Adwaita:dark` in wrapper only |

## Autonomous restore procedure

Run every step in order. Stop only if a step is blocked (no sudo, no network, no GDM).

### Phase 0 — inspect

```bash
uname -m
. /etc/os-release; echo "$ID $VERSION_ID"
echo "USER=$USER HOME=$HOME"
command -v git sudo apt-get i3 Xorg gdm3
test -d "$HOME/Developer" || mkdir -p "$HOME/Developer"
```

If arch is not `aarch64` or OS is not Ubuntu 24.04, continue but do not change NVIDIA/Xorg blindly.

### Phase 1 — clone

If `~/Developer/claiper_dotfiles/.git` exists: `git -C ~/Developer/claiper_dotfiles pull --ff-only`.

Else:

```bash
git clone git@github.com:kaustabpal/claiper_dotfiles.git ~/Developer/claiper_dotfiles
```

If SSH fails, print this public key and stop:

```bash
cat ~/.ssh/id_ed25519.pub
```

User must add it at GitHub → Settings → SSH keys. Then retry clone.

### Phase 2 — packages

Print, then run if sudo works:

```bash
cd ~/Developer/claiper_dotfiles
sudo apt-get update
sudo apt-get install -y $(grep -vE '^(#|$)' packages.txt | xargs)
```

If sudo needs a password, give the user that exact command and wait.

Also useful if missing: `ghostty` (snap is acceptable), `fonts-noto-core`.

Do **not** install `xsettingsd` as a required package.

### Phase 3 — install files

```bash
cd ~/Developer/claiper_dotfiles
chmod +x install.sh local-bin/*
./install.sh
chmod +x ~/.local/bin/*
```

Verify these exist and are executable:

- `~/.local/bin/i3-session`
- `~/.local/bin/i3-lock`
- `~/.local/bin/i3-console-lock`
- `~/.local/bin/i3-power-menu`
- `~/.local/bin/i3-volume`
- `~/.local/bin/firefox`
- `~/.local/bin/rofi-drun-recent`
- `~/.local/bin/i3status-with-clicks`
- `~/.local/bin/nm-applet-themed`
- `~/.local/bin/gsimplecal-i3`
- `~/.local/bin/restore-gnome-display.sh`

Verify configs:

- `~/.config/i3/config` contains `set $mod Mod4`
- `~/.config/i3/config` starts i3-session display pin `HDMI-0` `2560x1440`
- `~/.local/share/xsessions/i3.desktop` Exec=`/home/<user>/.local/bin/i3-session`

If the home user is not `kaustab`, rewrite absolute `/home/kaustab/` paths in:

- `~/.config/i3/config`
- `~/.local/share/xsessions/i3.desktop`
- any `local-bin` script that hardcodes `/home/kaustab/`

Use `$HOME` or the actual user.

### Phase 4 — Firefox prefs (no logins)

Do not restore the old Firefox profile from this repo. It is not here.

After first Firefox start (or if `~/.mozilla` / snap profile already exists):

```bash
# snap profile on this host:
# ~/snap/firefox/common/.mozilla/firefox/<profile>/user.js
PROFILE=$(find "$HOME/snap/firefox/common/.mozilla/firefox" "$HOME/.mozilla/firefox" \
  -maxdepth 2 -name prefs.js 2>/dev/null | head -1 | xargs dirname)
if [ -n "$PROFILE" ]; then
  install -m 0644 ~/Developer/claiper_dotfiles/firefox/user.js "$PROFILE/user.js"
fi
```

Keep `~/.local/bin/firefox` on `PATH` ahead of `/snap/bin/firefox` and `/usr/bin/firefox`.

### Phase 5 — gsettings (Firefox-safe)

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru'
gsettings set org.gnome.desktop.interface color-scheme 'default'
gsettings set org.gnome.desktop.interface font-name 'Ubuntu Sans 11'
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
gsettings set org.gnome.desktop.interface scaling-factor 0
gsettings set org.gnome.desktop.interface cursor-size 24
```

Do not start xsettingsd.

### Phase 6 — session switch

The agent cannot complete GDM login. Tell the user:

1. Save work.
2. Log out fully.
3. At the GDM gear, choose **i3**.
4. Log in.

If i3 is not listed, copy `xsessions/i3.desktop` to `/usr/share/xsessions/i3-session.desktop` with sudo and fix Exec to `i3-session`.

### Phase 7 — verify on the live i3 session

Run or ask the user to confirm:

| Check | Command / action | Pass |
| --- | --- | --- |
| session | `echo $XDG_CURRENT_DESKTOP $XDG_SESSION_TYPE` | `i3` + `x11` |
| dpi | `xrdb -query \| grep dpi` | `Xft.dpi: 96` |
| mode | `xrandr --current \| head` | HDMI-0 `2560x1440` |
| terminal | Super+Enter | terminal opens |
| launcher | Super+Space | rofi opens |
| lock | Super+Shift+x | console lock, stars for password |
| power | Super+Shift+e | rofi Lock/Logout/Reboot/Power off |
| volume | Super+= | wpctl volume rises |
| calendar | click clock | gsimplecal, closes on unfocus |
| wifi | click tray | dark purple menu |
| firefox | Super+Space → Firefox | tabs have labels; address bar accepts type |

If GNOME is later selected and UI scale is wrong:

```bash
~/.local/bin/restore-gnome-display.sh
```

Then full logout/login.

## Known failures and fixes

| Symptom | Cause | Fix |
| --- | --- | --- |
| Black screen / huge chrome after i3 | DPI scaled by X mm | Always start via `i3-session` (`Xft.dpi: 96`) |
| GNOME tiny/huge after return | shared scale env or mode change | `restore-gnome-display.sh`, logout |
| Firefox blank tabs / cannot type | xsettingsd or global Yaru-purple-dark | stop xsettingsd; gsettings Yaru + default; launch `~/.local/bin/firefox` |
| Firefox white context menu | GTK native menus + light theme | leave it; do not force host dark GTK onto Firefox |
| Super+Shift+x does nothing | lock CSS/PAM crash | run `python3 ~/.local/bin/i3-console-lock` in a terminal; read traceback |
| Lock unlocks on any key | locker crashed on Enter | keep `i3-lock` supervisor loop; do not call console lock without it |
| Volume keys dead | no `pactl`; i3 `&&` broken | use `i3-volume` + `wpctl` |
| Calendar stays open / wrong size | isolated XDG hid config | config must live at `~/.config/i3-gtk/gsimplecal/gsimplecal/config` |
| i3 not in GDM list | only user xsession | install `xsessions/i3.desktop` system-wide |
| SSH clone denied | GitHub missing host key | add `~/.ssh/id_ed25519.pub` to GitHub |

## What not to restore from assumption

- Old Firefox profile (`*.default.OLD-*`, `firefox-backup-*`) unless the user explicitly asks.
- Custom Firefox theme XPIs. They hid chrome text on this host.
- Hyprland, Sway, or Wayland as default.
- `dex --autostart --environment i3`.

## Sync local changes back to GitHub

When the user asks to backup i3 again:

```bash
REPO=~/Developer/claiper_dotfiles
cp -a ~/.config/i3/config $REPO/i3/config
cp -a ~/.config/i3status/config $REPO/i3status/config
cp -a ~/.config/rofi/config.rasi $REPO/rofi/config.rasi
cp -a ~/.config/dunst/dunstrc $REPO/dunst/dunstrc
cp -a ~/.config/gsimplecal/config $REPO/gsimplecal/config
cp -a ~/.config/gtk-3.0/settings.ini $REPO/gtk/gtk-3.0/
cp -a ~/.config/gtk-3.0/gtk.css $REPO/gtk/gtk-3.0/
cp -a ~/.config/gtk-4.0/settings.ini $REPO/gtk/gtk-4.0/
cp -a ~/.gtkrc-2.0 $REPO/gtk/gtkrc-2.0
cp -a ~/.config/xsettingsd/xsettingsd.conf $REPO/gtk/xsettingsd/
cp -a ~/.config/i3-gtk/nm-applet/gtk-3.0/* $REPO/i3-gtk/nm-applet/gtk-3.0/
cp -a ~/.config/i3-gtk/gsimplecal/gtk-3.0/* $REPO/i3-gtk/gsimplecal/gtk-3.0/
cp -a ~/.config/i3-gtk/gsimplecal/gsimplecal/config $REPO/i3-gtk/gsimplecal/gsimplecal/
cp -a ~/.local/bin/browser-nav ~/.local/bin/firefox ~/.local/bin/firefox-i3 \
  ~/.local/bin/gsimplecal-i3 ~/.local/bin/i3-* ~/.local/bin/i3status-with-clicks \
  ~/.local/bin/nm-applet-themed ~/.local/bin/restore-gnome-display.sh \
  ~/.local/bin/rofi-drun-recent ~/.local/bin/screen-capture \
  $REPO/local-bin/
cp -a ~/.local/share/wallpapers/caliper.png $REPO/wallpapers/
cp -a ~/.local/share/xsessions/i3.desktop $REPO/xsessions/
cd $REPO
git add -A
git status
git commit -m "i3: snapshot from $HOST $(date -Iseconds)"
git push
```

Do not add `~/.mozilla`, snap Firefox profiles, or SSH keys.

## User prompt that starts this job

If the user says only “restore my i3” or points at this repo, execute Phases 0–7. Do not ask for a plan. Ask only when sudo or GDM login is required.
