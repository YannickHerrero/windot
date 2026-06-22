#!/usr/bin/env bash
#
# Sync the WezTerm Omakase color theme into Windows Terminal.
#
# The wmenu theme orchestrator regenerates ~/.wezterm-colors.lua on every theme
# switch (WezTerm hot-reloads it). Windows Terminal can't read that Lua file, so
# this bridge translates it into the "wezterm-omakase" color scheme inside the
# Windows Terminal settings.json. Every other setting is left untouched.
#
# Run from WSL:
#   ./theme-sync.sh           # one-shot resync after a theme switch
#   ./theme-sync.sh --watch   # watch the colors file and resync on change
#
# Requires python3 (no jq dependency).

set -euo pipefail

WIN_USER="${WIN_USER:-YannickHerrero}"
COLORS_LUA="${COLORS_LUA:-/mnt/c/Users/${WIN_USER}/.wezterm-colors.lua}"
WT_SETTINGS="${WT_SETTINGS:-/mnt/c/Users/${WIN_USER}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json}"
SCHEME_NAME="wezterm-omakase"

sync_once() {
    COLORS_LUA="$COLORS_LUA" WT_SETTINGS="$WT_SETTINGS" SCHEME_NAME="$SCHEME_NAME" \
    python3 - <<'PY'
import json, os, re, shutil, sys, time

colors_lua = os.environ["COLORS_LUA"]
wt_settings = os.environ["WT_SETTINGS"]
scheme_name = os.environ["SCHEME_NAME"]

ansi_keys = ["black", "red", "green", "yellow", "blue", "purple", "cyan", "white"]
bright_keys = ["brightBlack", "brightRed", "brightGreen", "brightYellow",
               "brightBlue", "brightPurple", "brightCyan", "brightWhite"]

with open(colors_lua, encoding="utf-8") as f:
    text = f.read()

def scalar(name):
    m = re.search(rf'{name}\s*=\s*"(#[0-9A-Fa-f]{{6}})"', text)
    return m.group(1) if m else None

def array(name):
    m = re.search(rf'{name}\s*=\s*\{{(.*?)\}}', text, re.DOTALL)
    return re.findall(r'"(#[0-9A-Fa-f]{6})"', m.group(1)) if m else []

ansi, brights = array("ansi"), array("brights")
if len(ansi) != 8 or len(brights) != 8:
    sys.exit(f"Expected 8 ansi + 8 brights, got {len(ansi)}/{len(brights)}")

scheme = {
    "name": scheme_name,
    "foreground": scalar("foreground"),
    "background": scalar("background"),
    "cursorColor": scalar("cursor_bg"),
    "selectionBackground": scalar("selection_bg"),
}
scheme.update(dict(zip(ansi_keys, ansi)))
scheme.update(dict(zip(bright_keys, brights)))
missing = [k for k, v in scheme.items() if v is None]
if missing:
    sys.exit(f"Missing colors in lua file: {missing}")

with open(wt_settings, encoding="utf-8-sig") as f:
    settings = json.load(f)

schemes = settings.setdefault("schemes", [])
for i, s in enumerate(schemes):
    if s.get("name") == scheme_name:
        if s == scheme:
            print(f"[{time.strftime('%H:%M:%S')}] No change.")
            sys.exit(0)
        schemes[i] = scheme
        break
else:
    schemes.append(scheme)

shutil.copy2(wt_settings, wt_settings + ".bak")
with open(wt_settings, "w", encoding="utf-8") as f:
    json.dump(settings, f, indent=4, ensure_ascii=False)
    f.write("\n")
print(f"[{time.strftime('%H:%M:%S')}] Synced '{scheme_name}' -> Windows Terminal (bg {scheme['background']})")
PY
}

if [[ "${1:-}" == "--watch" ]]; then
    echo "Watching ${COLORS_LUA} ... (Ctrl+C to stop)"
    last=""
    while true; do
        if [[ -f "$COLORS_LUA" ]]; then
            mtime=$(stat -c %Y "$COLORS_LUA" 2>/dev/null || echo "")
            if [[ "$mtime" != "$last" ]]; then
                last="$mtime"
                sync_once || echo "sync failed" >&2
            fi
        fi
        sleep 1
    done
else
    sync_once
fi
