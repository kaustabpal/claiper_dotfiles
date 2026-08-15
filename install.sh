#!/usr/bin/env bash
# Restore claiper i3 setup onto a fresh Ubuntu user home.
# Run as the desktop user (not root). Does not copy Firefox logins.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="${HOME}"

link_or_copy() {
  local src=$1 dest=$2
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    cp -a "$dest" "${dest}.bak.$(date +%Y%m%d%H%M%S)"
  fi
  ln -sfn "$src" "$dest"
}

echo "Installing claiper i3 files into ${HOME_DIR}"

mkdir -p \
  "${HOME_DIR}/.config/i3" \
  "${HOME_DIR}/.config/i3status" \
  "${HOME_DIR}/.config/rofi" \
  "${HOME_DIR}/.config/dunst" \
  "${HOME_DIR}/.config/gsimplecal" \
  "${HOME_DIR}/.config/gtk-3.0" \
  "${HOME_DIR}/.config/gtk-4.0" \
  "${HOME_DIR}/.config/xsettingsd" \
  "${HOME_DIR}/.config/i3-gtk/nm-applet/gtk-3.0" \
  "${HOME_DIR}/.config/i3-gtk/gsimplecal/gtk-3.0" \
  "${HOME_DIR}/.config/i3-gtk/gsimplecal/gsimplecal" \
  "${HOME_DIR}/.local/bin" \
  "${HOME_DIR}/.local/share/wallpapers" \
  "${HOME_DIR}/.local/share/xsessions" \
  "${HOME_DIR}/.pi/agent/reference"

install -m 0644 "${REPO}/i3/config" "${HOME_DIR}/.config/i3/config"
install -m 0644 "${REPO}/i3status/config" "${HOME_DIR}/.config/i3status/config"
install -m 0644 "${REPO}/rofi/config.rasi" "${HOME_DIR}/.config/rofi/config.rasi"
install -m 0644 "${REPO}/dunst/dunstrc" "${HOME_DIR}/.config/dunst/dunstrc"
install -m 0644 "${REPO}/gsimplecal/config" "${HOME_DIR}/.config/gsimplecal/config"
install -m 0644 "${REPO}/gtk/gtk-3.0/settings.ini" "${HOME_DIR}/.config/gtk-3.0/settings.ini"
install -m 0644 "${REPO}/gtk/gtk-3.0/gtk.css" "${HOME_DIR}/.config/gtk-3.0/gtk.css"
install -m 0644 "${REPO}/gtk/gtk-4.0/settings.ini" "${HOME_DIR}/.config/gtk-4.0/settings.ini"
install -m 0644 "${REPO}/gtk/gtk-4.0/gtk.css" "${HOME_DIR}/.config/gtk-4.0/gtk.css"
install -m 0644 "${REPO}/gtk/gtkrc-2.0" "${HOME_DIR}/.gtkrc-2.0"
install -m 0644 "${REPO}/gtk/xsettingsd/xsettingsd.conf" "${HOME_DIR}/.config/xsettingsd/xsettingsd.conf"
install -m 0644 "${REPO}/i3-gtk/nm-applet/gtk-3.0/"* "${HOME_DIR}/.config/i3-gtk/nm-applet/gtk-3.0/"
install -m 0644 "${REPO}/i3-gtk/gsimplecal/gtk-3.0/"* "${HOME_DIR}/.config/i3-gtk/gsimplecal/gtk-3.0/"
install -m 0644 "${REPO}/i3-gtk/gsimplecal/gsimplecal/config" "${HOME_DIR}/.config/i3-gtk/gsimplecal/gsimplecal/config"
install -m 0755 "${REPO}/local-bin/"* "${HOME_DIR}/.local/bin/"
install -m 0644 "${REPO}/wallpapers/caliper.png" "${HOME_DIR}/.local/share/wallpapers/caliper.png"
install -m 0644 "${REPO}/xsessions/i3.desktop" "${HOME_DIR}/.local/share/xsessions/i3.desktop"
install -m 0644 "${REPO}/reference/i3_gnome_display.md" "${HOME_DIR}/.pi/agent/reference/i3_gnome_display.md"

if [[ -f "${REPO}/firefox/user.js" ]]; then
  echo "Firefox user.js is in firefox/user.js — copy into the profile after first Firefox start."
fi

echo "Done. Log out, pick the i3 session (i3-session wrapper), then:"
echo "  ~/.local/bin/restore-gnome-display.sh   # only if GNOME scale is wrong"
echo "Packages: sudo apt-get install -y \$(grep -v '^#' ${REPO}/packages.txt | xargs)"
