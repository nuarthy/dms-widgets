# dms-widgets

Desktop widgets for [DankMaterialShell](https://danklinux.com), ported from the
[end4-pC](https://github.com/pctrade/end4-pC) background widget board.
Each widget is a standalone DMS `desktop-widget` plugin — install by copying
its folder into `~/.config/DankMaterialShell/plugins/` and adding an instance
via `dms ipc` or the Desktop settings UI (restart DMS after adding files).

## Widgets

| Folder | What |
|---|---|
| wb-usercard | User card: system avatar, name, uptime, weather, lock/settings/power |
| wb-clock | Big clock |
| wb-weather | Current weather |
| wb-cpu / wb-ram / wb-battery | CPU / RAM / battery with Material tiles |
| wb-media | Media player with album art + controls |
| wb-worldclock | Local + Tokyo / Shenyang / New York / London with live GMT offsets |
| wb-calendar | Month calendar |
| wb-converter | Drop-to-convert images (magick, ffmpeg fallback) |
| wb-notes / wb-todo / wb-timers / wb-visualizer / wb-customimage | Phase-2 placeholders |

## Deps

- Image converter needs `magick` (ImageMagick) or `ffmpeg`
- Stats use the DMS backend `dgop` capability
