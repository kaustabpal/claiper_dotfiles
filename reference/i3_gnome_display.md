# i3 and GNOME Display Safety

Host scope: caliper-01 / DGX Spark (Ubuntu 24.04, aarch64, NVIDIA GB10, X11).
Purpose: keep keyboard-first i3 usable without breaking GNOME scaling on return.
Recorded: 2026-03-22 from local session audit.

## Baseline that must stay stable

| Item | Safe value |
| --- | --- |
| Preferred session for daily work | Ubuntu GNOME on X11 |
| Keyboard-first WM | i3 (second session only) |
| Monitor | Dell S2722QC over HDMI-0 |
| Shared mode for both sessions | `2560x1440` @ ~60 Hz |
| GNOME text scaling | `1.0` |
| GNOME scaling-factor | `0` (auto) |
| Cursor size | `24` |
| Xft.dpi | `96` unless both sessions are retuned together |

Native panel mode is 3840x2160. This host often runs 2560x1440. Do not change mode in one session without a restore path for the other.

## Safe rules

1. Put i3-only commands only in `~/.config/i3/config`.
2. Do not set `GDK_SCALE`, `GDK_DPI_SCALE`, `QT_SCALE_FACTOR`, or `QT_AUTO_SCREEN_SCALE_FACTOR` in shared startup files:
   - `~/.profile`
   - `~/.bashrc`
   - `~/.bash_profile`
   - `~/.xprofile`
   - `~/.xsessionrc`
3. Do not run `xrandr --scale` for normal setup. Prefer exact modes such as `2560x1440`.
4. Pin the same output mode in i3 that GNOME uses. Example:
   - `xrandr --output HDMI-0 --mode 2560x1440 --scale 1x1`
5. Avoid fractional scaling experiments on this NVIDIA X11 stack.
6. Keep the GNOME session packages installed. Never make i3 the only recovery path.
7. Switch sessions with a full logout through GDM. Do not nest i3 inside GNOME.
8. Do not write global DPI or monitor changes through NVIDIA Settings unless the user asks and accepts a GNOME restore step.
9. Treat `~/.config/monitors.xml` as GNOME-owned. Do not hand-edit it for i3 experiments.
10. If an i3 font, bar, or terminal looks small, fix the i3 config only. Do not "fix" it with global toolkit scale.

## Why GNOME broke before

Likely causes when leaving i3 and returning to GNOME:

- display mode or scale changed under i3
- DPI or toolkit scale set in a shared startup file
- GNOME `monitors.xml` or UI scale changed during debug
- session hop without full logout, leaving X half-applied

i3 window manager config alone does not set global GTK/Qt scale. Damage comes from side effects outside i3.

## i3 config constraints on this host

Known paths:

- `~/.config/i3/config`
- `~/.config/i3status/config`
- session files: `/usr/share/xsessions/i3.desktop`

Hardening preferences when editing i3:

- use a readable pango font for bar and titles; avoid tiny `monospace 8` on this monitor
- bind a terminal binary that exists on the host
- pin `HDMI-0` to `2560x1440` on startup
- keep launcher keyboard-first (`dmenu` or `rofi`)
- treat `dex --autostart --environment i3` as optional; it can pull desktop noise into i3

Do not move those settings into shell rc files.

## GNOME restore cheatsheet

Script (preferred):

```bash
~/.local/bin/restore-gnome-display.sh
```

Manual equivalent from a working terminal in GNOME, TTY, or SSH:

```bash
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
gsettings set org.gnome.desktop.interface scaling-factor 0
gsettings set org.gnome.desktop.interface cursor-size 24
xrandr --output HDMI-0 --mode 2560x1440 --scale 1x1
```

Then log out and log in. Reboot if the NVIDIA mode stays wrong.

Overrides for the script:

- `RESTORE_OUTPUT` (default `HDMI-0`)
- `RESTORE_MODE` (default `2560x1440`)
- `RESTORE_TEXT_SCALE` (default `1.0`)
- `RESTORE_SCALING_FACTOR` (default `0`)
- `RESTORE_CURSOR_SIZE` (default `24`)

Optional checks:

```bash
gsettings get org.gnome.desktop.interface text-scaling-factor
gsettings get org.gnome.desktop.interface scaling-factor
xrandr --current | head -n 20
xrdb -query | grep -i dpi
grep -nE 'GDK_SCALE|GDK_DPI|QT_SCALE|xrandr --scale' \
  ~/.profile ~/.bashrc ~/.xprofile ~/.xsessionrc 2>/dev/null
```

## Agent operating rules

When the user asks about i3, tiling WM setup, display scaling, DPI, or GNOME UI size after a session switch:

1. Read this file first.
2. Prefer isolated i3 config changes over shared environment variables.
3. Preserve GNOME restore values above unless the user gives new baselines.
4. Warn before any change that can alter global scale, DPI, or monitor mode.
5. Do not install or enable Hyprland as the default path on this host.
6. Prefer i3 over GNOME Tiling Assistant when the user wants keyboard-only workflow.
7. Prefer GNOME Tiling Assistant only when the user wants to stay inside GNOME.

## Package / feature notes

- i3 is already installed: `i3-wm`, `i3status`, `suckless-tools` (dmenu)
- GNOME Tiling Assistant is installed and active, but it is mouse-assisted snap tiling, not a keyboard-first WM
- Current good fit for keyboard-only work on this host: i3 on X11
- Poor daily-driver fit on this host: Hyprland / experimental NVIDIA Wayland compositors

## i3 border thickness vs rofi

i3 scales decoration pixels by DPI (`ceil(N * dpi / 96)` via libi3).
Rofi theme `px` values do not use that same path.

On this host, X may report ~161 DPI because screen mm and 1440p mode disagree
(EDID physical size is for the 4K panel). Then `border pixel 3` becomes **6**
device pixels, so i3 chrome looks twice as thick as rofi `border: 3px`.

Fix: start i3 through `~/.local/bin/i3-session`, which runs `Xft.dpi: 96`
before i3. Session file: `~/.local/share/xsessions/i3.desktop`.

Also: two tiled windows each own a border, so the seam is N+N pixels.

