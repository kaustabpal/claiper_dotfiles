#!/usr/bin/env bash
# Restore GNOME display/UI baselines on caliper-01 after i3 or scaling experiments.
# Safe values: ~/.pi/agent/reference/i3_gnome_display.md
set -euo pipefail

OUTPUT="${RESTORE_OUTPUT:-HDMI-0}"
MODE="${RESTORE_MODE:-2560x1440}"
TEXT_SCALE="${RESTORE_TEXT_SCALE:-1.0}"
SCALING_FACTOR="${RESTORE_SCALING_FACTOR:-0}"
CURSOR_SIZE="${RESTORE_CURSOR_SIZE:-24}"

log() { printf '%s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }

log "STATUS: restoring GNOME display baselines"
log "TARGET: output=${OUTPUT} mode=${MODE} text-scale=${TEXT_SCALE} scaling-factor=${SCALING_FACTOR} cursor=${CURSOR_SIZE}"

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface text-scaling-factor "${TEXT_SCALE}"
  gsettings set org.gnome.desktop.interface scaling-factor "${SCALING_FACTOR}"
  gsettings set org.gnome.desktop.interface cursor-size "${CURSOR_SIZE}"
  log "OK: gsettings text-scaling-factor=$(gsettings get org.gnome.desktop.interface text-scaling-factor)"
  log "OK: gsettings scaling-factor=$(gsettings get org.gnome.desktop.interface scaling-factor)"
  log "OK: gsettings cursor-size=$(gsettings get org.gnome.desktop.interface cursor-size)"
else
  warn "gsettings not found; skipped GNOME interface keys"
fi

if command -v xrandr >/dev/null 2>&1; then
  if [[ -n "${DISPLAY:-}" ]]; then
    if xrandr --query | grep -q "^${OUTPUT} connected"; then
      xrandr --output "${OUTPUT}" --mode "${MODE}" --scale 1x1
      log "OK: xrandr ${OUTPUT} -> ${MODE} scale 1x1"
    else
      warn "output ${OUTPUT} not connected; skipped xrandr"
      xrandr --query | awk '/ connected/{print "  "$0}'
    fi
  else
    warn "DISPLAY unset; skipped xrandr (run from graphical session or export DISPLAY)"
  fi
else
  warn "xrandr not found; skipped mode restore"
fi

log "CHECK: shared scale env in startup files"
if grep -nE 'GDK_SCALE|GDK_DPI_SCALE|QT_SCALE_FACTOR|QT_AUTO_SCREEN_SCALE_FACTOR|xrandr --scale' \
  "${HOME}/.profile" "${HOME}/.bashrc" "${HOME}/.bash_profile" \
  "${HOME}/.xprofile" "${HOME}/.xsessionrc" 2>/dev/null; then
  warn "shared scale-related lines found above; remove them if GNOME UI stays wrong"
else
  log "OK: no shared scale env matches in common startup files"
fi

if command -v xrdb >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" ]]; then
  log "CHECK: Xft.dpi=$(xrdb -query 2>/dev/null | awk -F: '/Xft.dpi/{gsub(/[[:space:]]/,"",$2); print $2}')"
fi

log "NEXT: log out and log into GNOME. Reboot if NVIDIA mode stays wrong."
log "STATUS: done"
