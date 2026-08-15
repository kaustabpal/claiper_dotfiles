# claiper_dotfiles

i3 setup for caliper-01 (DGX Spark, Ubuntu 24.04, aarch64, NVIDIA GB10, X11).

Restore this repo after a reinstall. It does **not** contain Firefox cookies, passwords, or SSH keys.

## What is included

- i3 + i3status + rofi + dunst + gsimplecal
- lock/power, volume, screenshots, wallpaper
- isolated GTK themes for WiFi and calendar
- Firefox launch wrapper and `user.js` (software render + fonts)
- display-safety notes for GNOME ↔ i3

## Fresh install

1. Install Ubuntu 24.04 desktop, create user `kaustab`, enable SSH.
2. Clone:

```bash
git clone git@github.com:kaustabpal/claiper_dotfiles.git ~/Developer/claiper_dotfiles
cd ~/Developer/claiper_dotfiles
```

3. Packages:

```bash
sudo apt-get update
sudo apt-get install -y $(grep -v '^#' packages.txt | xargs)
```

4. Restore files:

```bash
chmod +x install.sh
./install.sh
```

5. Log out. At GDM, choose **i3** (uses `~/.local/bin/i3-session`, `Xft.dpi=96`).
6. First login checks:
   - Super+Enter = Ghostty
   - Super+Space = rofi
   - Super+Shift+x = lock
   - clock click = calendar
   - WiFi tray = dark menu
7. Firefox: start once, then copy `firefox/user.js` into the new profile if chrome text is missing.
8. If GNOME looks scaled after switching back:

```bash
~/.local/bin/restore-gnome-display.sh
```

## Key map (Super = $mod)

| Key | Action |
| --- | --- |
| Super+Enter | terminal (Ghostty) |
| Super+Space | app launcher |
| Super+Shift+s | area screenshot |
| Super+Shift+v | area record / stop |
| Super+Shift+x | lock |
| Super+Shift+e | power menu |
| Super+= / Super+- | volume |
| Super+Shift+m | mute |
| Ctrl+Left / Right | Firefox back / forward |

## Safety rules

Read `reference/i3_gnome_display.md`.

- i3-only commands stay in `~/.config/i3/config`
- do not set `GDK_SCALE` / `QT_SCALE_FACTOR` in shell rc
- keep GNOME installed as fallback
- do not start `xsettingsd` while using snap Firefox

## Update this repo after local changes

```bash
cd ~/Developer/claiper_dotfiles
# copy changed files from ~ into this tree, then:
git add -A
git status
git commit -m "i3: describe change"
git push
```

## Not backed up here

- Firefox profile (logins, cookies)
- SSH private keys
- GNOME keyring
- `/etc/X11/xorg.conf`
