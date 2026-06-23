#!/bin/bash
# Calendar widget for the tmux status bar, backed by icalBuddy (icalBuddy64 fork).
#
#   cal.sh             next-meeting status string  (default; used by status-right)
#   cal.sh tasks       due-tasks status string     (separate status segment)
#   cal.sh join        open the next meeting's video link (Meet/Zoom/Teams/Webex)
#   cal.sh _popupbody  full details — run inside `display-popup` (bound to prefix+M)
#
# Calendars are resolved WITHOUT hardcoding (this repo is public):
#   1. $TMUX_CAL_MEETINGS / $TMUX_CAL_TASKS   env override
#   2. ~/.config/tmux/calendars.local         gitignored; may set MEETING_CALS/TASK_CALS
#   3. auto-discover from the live DB          CalDAV/email-named calendars
#
# Forces 24h time and uses GNU `date -d` (with a BSD fallback) so the countdown
# works regardless of locale / which `date` is on PATH.

# ---- config ----------------------------------------------------------------
TASK_CALS="Reminders,To-Dos"   # task calendars (generic names; override as needed)
ALERT_WITHIN_MIN=10            # switch to a live countdown once within this many minutes
TITLE_MAX=24                   # truncate long event titles to this many chars
DISCOVER_TTL=3600              # re-discover meeting calendars at most this often (seconds)
ICON_FREE="󱁕"                  # no more meetings today
ICON_NEXT="󰃭"                  # upcoming meeting (not imminent)
ICON_SOON="󰤙"                  # meeting within ALERT_WITHIN_MIN
ICON_NOW="󰗶"                   # meeting in progress
ICON_TASK=""                  # due tasks
# ---------------------------------------------------------------------------

US=$'\x1f'                     # unit separator; never appears in event text

# print cached output if younger than $2 seconds, else run $3 and cache it
cached() {
  local f="${TMPDIR:-/tmp}/tmuxcal_$1" age out
  if [ -f "$f" ]; then
    age=$(( $(date +%s) - $(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0) ))
    if [ "$age" -lt "$2" ]; then cat "$f"; return; fi
  fi
  out="$("$3")"
  printf '%s' "$out" >"$f" 2>/dev/null
  printf '%s' "$out"
}

# meeting calendars = CalDAV/email-named calendars (noise like Holidays has no '@')
_discover_meetings() { icalBuddy calendars 2>/dev/null | grep '@' | sed -E 's/^[^[:alnum:]]*//' | paste -sd ',' -; }

# --- resolve calendars (see header) ----------------------------------------
_local="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/calendars.local"
[ -r "$_local" ] && . "$_local"
: "${MEETING_CALS:=}"
[ -n "${TMUX_CAL_MEETINGS:-}" ] && MEETING_CALS="$TMUX_CAL_MEETINGS"
[ -n "${TMUX_CAL_TASKS:-}" ] && TASK_CALS="$TMUX_CAL_TASKS"
[ -z "$MEETING_CALS" ] && MEETING_CALS="$(cached caldiscover "$DISCOVER_TTL" _discover_meetings)"

# icalBuddy for the meeting calendars, machine-friendly output
icb() { icalBuddy -nc -nrd -npn -b "" -ea -ic "$MEETING_CALS" "$@"; }

_trunc() { local s="$1"; if [ "${#s}" -gt "$TITLE_MAX" ]; then printf '%s…' "${s:0:TITLE_MAX-1}"; else printf '%s' "$s"; fi; }
# epoch seconds for "HH:MM" today — GNU `date -d` (nix coreutils) or BSD /bin/date
_epoch_at() { local d; d="$(date +%Y-%m-%d)"; date -d "$d $1" +%s 2>/dev/null || /bin/date -j -f "%Y-%m-%d %H:%M" "$d $1" +%s 2>/dev/null; }
_now_title() { icb -po "title" -li 1 eventsNow 2>/dev/null | head -1; }
_next_raw()  { icb -tf "%H:%M" -eed -po "datetime,title" -ps "@${US}@" -n -li 1 eventsToday 2>/dev/null | head -1; }
_join_url()  { icb -po "url,notes" -n -li 1 eventsToday 2>/dev/null | grep -oiE 'https://([a-z0-9-]+\.)?(meet\.google\.com|zoom\.us|teams\.microsoft\.com|webex\.com)/[^ )]+' | head -1; }

_meetings_compute() {
  local now_title raw start title tgt mins
  now_title="$(_now_title)"
  if [ -n "$now_title" ]; then printf '%s %s' "$ICON_NOW" "$(_trunc "$now_title")"; return; fi
  raw="$(_next_raw)"
  if [ -z "$raw" ]; then printf '%s' "$ICON_FREE"; return; fi
  start="${raw%%${US}*}"; title="${raw#*${US}}"
  tgt="$(_epoch_at "$start")"
  if [ -n "$tgt" ]; then mins=$(( (tgt - $(date +%s)) / 60 )); else mins=999; fi
  if [ "$mins" -ge 0 ] && [ "$mins" -lt "$ALERT_WITHIN_MIN" ]; then
    printf '%s %s %s (in %dm)' "$ICON_SOON" "$start" "$(_trunc "$title")" "$mins"
  else
    printf '%s %s %s' "$ICON_NEXT" "$start" "$(_trunc "$title")"
  fi
}

_tasks_compute() {
  local n
  n="$(icalBuddy -nc -npn -b "##T##" -ab "##T##" -ic "$TASK_CALS" -li 99 "tasksDueBefore:today+1" 2>/dev/null | grep -c '##T##')"
  if [ "${n:-0}" -gt 0 ]; then printf '%s %d due' "$ICON_TASK" "$n"; fi
}

popup_body() {
  icalBuddy -nc -nrd -ea -ic "$MEETING_CALS" -tf "%H:%M" \
    -iep "title,datetime,location,attendees,url" -li 3 -n eventsToday 2>/dev/null
  local url; url="$(_join_url)"
  [ -n "$url" ] && printf '\n──────────────\n  join: %s\n' "$url"
  printf '\n[ any key to close ] '
  read -rn1 _ 2>/dev/null
}

case "${1:-meetings}" in
  tasks)      cached tasks 60 _tasks_compute ;;
  join)       url="$(_join_url)"; [ -n "$url" ] && open "$url" ;;
  _popupbody) popup_body ;;
  *)          cached meetings 30 _meetings_compute ;;
esac
