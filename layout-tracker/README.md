# tak0-layout

Per-window keyboard layouts for Hyprland that **learn how you use them**.

Every window remembers its own layout. The service also keeps score of how long you spend in each layout
in each app, and opens new windows in the layout you most likely want there.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/tak0dan/QoL-Script-For-Hyprland-By-Tak00/main/layout-tracker/install.sh | bash
```

This puts `tak0-layout` in `~/.local/bin`, installs a systemd **user** service and starts it. It needs
Python 3, `hyprctl`, `curl` and systemd. It waits for Hyprland to start, so nothing has to go into your Hyprland config
except the optional key bind below. Run the same command again to update.

Remove it (your statistics are kept):

```bash
curl -fsSL https://raw.githubusercontent.com/tak0dan/QoL-Script-For-Hyprland-By-Tak00/main/layout-tracker/install.sh | bash -s -- --uninstall
```

### Switching layouts

Either keep Hyprland's own bind (for example `kb_options = grp:alt_shift_toggle`), or point a key at the CLI:

```ini
bind = SUPER, SPACE, exec, tak0-layout toggle
```

Both work. The service notices any switch, whoever made it, and saves it for that window.

## How it decides

- **Time** in each layout is counted per app (window class) and globally, while the window is focused.
- **Uses** counts how many times each layout was picked, so a layout you flip to often is not lost to one you left
  open overnight.
- Old habits fade: counts decay with a 14-day half-life (`TAK0_LAYOUT_HALF_LIFE_DAYS`), so the
  default follows how you type now.
- A **new window** starts in the app's top layout once it has about a minute of data
  (`TAK0_LAYOUT_MIN_SECONDS`). Before that it uses your global favourite.
- **Layouts you stop using** (removed from `kb_layout`) are never deleted from the statistics. They are ignored when
  choosing a default and come back with their history if you add them again.

## Commands

```
tak0-layout stats            # global split plus your top apps, as bars
tak0-layout stats kitty      # one app
tak0-layout status           # current layout, configured layouts, data path
tak0-layout toggle           # next layout
tak0-layout forget kitty     # reset one app
systemctl --user status tak0-layout
journalctl --user -u tak0-layout -f
```

Statistics are written to `~/.local/share/tak0-layout/stats.json` about every 10 seconds while you work.
Each layout has `percent_recent` (with decay) and `percent_total` (all time), plus seconds and uses.

## Notes

- Tested on Hyprland 0.57. It reads the event socket directly, so it does not need `socat` or `jq`.
- If you used the older `Tak0-Per-Window-Switch.sh` from this repo, disable its `exec-once` and key bind before
  installing. The two would fight over the layout. The old script stays in the repo untouched.
