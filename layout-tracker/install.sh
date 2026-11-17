#!/usr/bin/env bash
# tak0-layout installer / updater.
#   curl -fsSL https://raw.githubusercontent.com/tak0dan/QoL-Script-For-Hyprland-By-Tak00/main/layout-tracker/install.sh | bash
# Remove with:  ... | bash -s -- --uninstall   (your statistics are kept)
set -euo pipefail

REPO="tak0dan/QoL-Script-For-Hyprland-By-Tak00"
REF="${TAK0_REF:-main}"
RAW="https://raw.githubusercontent.com/$REPO/$REF/layout-tracker"
BIN="$HOME/.local/bin/tak0-layout"
UNIT_DIR="$HOME/.config/systemd/user"

if [[ "${1:-}" == "--uninstall" ]]; then
  systemctl --user disable --now tak0-layout.service 2>/dev/null || true
  rm -f "$BIN" "$UNIT_DIR/tak0-layout.service"
  systemctl --user daemon-reload
  echo "Removed. Statistics are still in ~/.local/share/tak0-layout/"
  exit 0
fi

for dep in python3 hyprctl curl systemctl; do
  command -v "$dep" >/dev/null || { echo "Missing dependency: $dep" >&2; exit 1; }
done

mkdir -p "$(dirname "$BIN")" "$UNIT_DIR"
curl -fsSL "$RAW/tak0-layout" -o "$BIN.tmp" && mv "$BIN.tmp" "$BIN" && chmod +x "$BIN"
curl -fsSL "$RAW/tak0-layout.service" -o "$UNIT_DIR/tak0-layout.service"

# The old script fights over the layout if it is still running.
if pgrep -f 'Tak0-Per-Window-Switch' >/dev/null; then
  echo "Note: the old Tak0-Per-Window-Switch.sh is running. Remove its exec-once and keybind from your Hyprland config."
fi

systemctl --user daemon-reload
systemctl --user enable --now tak0-layout.service
systemctl --user restart tak0-layout.service

case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) echo "Add ~/.local/bin to your PATH to use the tak0-layout command." ;; esac
echo "Installed. Check it with:  tak0-layout status   |   tak0-layout stats"
echo "Bind your layout key to:   bind = ALT, SHIFT_L, exec, tak0-layout toggle   (any key you like)"
