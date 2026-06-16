#!/bin/bash
input=$(cat)

# ANSI colors ($'...' embeds actual ESC byte)
GRN=$'\033[32m'
YLW=$'\033[33m'
CYN=$'\033[36m'
MAG=$'\033[35m'
ORG=$'\033[38;5;214m'
RED=$'\033[31m'
DIM=$'\033[2m'
RST=$'\033[0m'

IS_DARWIN=0
[ "$(uname -s)" = "Darwin" ] && IS_DARWIN=1

# Extract everything in one jq call. "-" marks missing optional fields
# (tabs are IFS whitespace, so truly empty fields would collapse under read).
IFS=$'\t' read -r model ctx_total ctx_used ctx_used_pct thinking effort style cost \
  rate_5h_pct rate_7d_pct rate_5h_resets rate_7d_resets < <(
  echo "$input" | jq -r '[
    (.model.display_name // "Unknown"),
    (.context_window.context_window_size // 200000),
    (.context_window.total_input_tokens // 0),
    (.context_window.used_percentage // 0),
    (if .thinking.enabled then "on" else "off" end),
    (.effort.level // "-"),
    (.output_style.name // "-"),
    (.cost.total_cost_usd // 0),
    (.rate_limits.five_hour.used_percentage // "-"),
    (.rate_limits.seven_day.used_percentage // "-"),
    (.rate_limits.five_hour.resets_at // "-"),
    (.rate_limits.seven_day.resets_at // "-")
  ] | @tsv' 2>/dev/null
)
model=${model:-Unknown}
ctx_total=${ctx_total:-200000}
ctx_used=${ctx_used:-0}
ctx_used_pct=${ctx_used_pct:-0}
thinking=${thinking:-off}
effort=${effort:--}
style=${style:--}
cost=${cost:-0}
rate_5h_pct=${rate_5h_pct:--}
rate_7d_pct=${rate_7d_pct:--}
rate_5h_resets=${rate_5h_resets:--}
rate_7d_resets=${rate_7d_resets:--}

# Float-tolerant truncation (bash printf '%d' chokes on values like "42.5")
to_int() {
  awk -v v="$1" 'BEGIN { printf "%d", v }'
}

# Percentage to 1 decimal, trailing .0 dropped (source granularity varies: 9 vs 23.5)
fmt_pct1() {
  awk -v v="$1" 'BEGIN { s = sprintf("%.1f", v); sub(/\.0$/, "", s); print s }'
}

# Number formatter (comma-separated)
fmt_num() {
  awk -v v="$1" 'BEGIN {
    n = int(v); s = ""
    while (n > 999) { s = "," sprintf("%03d", n%1000) s; n = int(n/1000) }
    print n s
  }'
}

# Usage color: <50 green, 50-79 yellow, >=80 red
pct_color() {
  if   [ "$1" -ge 80 ]; then printf '%s' "$RED"
  elif [ "$1" -ge 50 ]; then printf '%s' "$YLW"
  else printf '%s' "$GRN"
  fi
}

# Progress bar (10 segments, color by usage)
make_bar() {
  local pct=$(to_int "$1")
  local filled=$(( pct / 10 ))
  [ "$filled" -gt 10 ] && filled=10
  [ "$filled" -lt 0 ] && filled=0
  local color=$(pct_color "$pct")

  local bar=""
  local i=0
  while [ $i -lt $filled ]; do
    bar="${bar}${color}●${RST}"
    i=$(( i + 1 ))
  done
  while [ $i -lt 10 ]; do
    bar="${bar}${DIM}○${RST}"
    i=$(( i + 1 ))
  done
  printf '%s' "$bar"
}

fmt_epoch() {
  local ts=$1 fmt=$2
  if [ "$IS_DARWIN" = 1 ]; then
    date -r "$ts" "+$fmt" 2>/dev/null
  else
    date -d "@${ts}" "+$fmt" 2>/dev/null
  fi
}

# epoch -> "2:00pm" (5h window resets within hours; date would be noise)
fmt_reset_time() {
  fmt_epoch "$1" "%I:%M%p" | tr '[:upper:]' '[:lower:]' | sed 's/^0//'
}

# epoch -> "jun 16 7:33pm"
fmt_reset_full() {
  fmt_epoch "$1" "%b %d %I:%M%p" | tr '[:upper:]' '[:lower:]' | sed 's/ 0/ /g'
}

# Line 1: model | tokens/limit (used%) | thinking[/effort] [| output style]
ctx_pct_int=$(to_int "$ctx_used_pct")
ctx_color=$(pct_color "$ctx_pct_int")

think_color=$DIM
[ "$thinking" = "on" ] && think_color=$CYN
think_seg="${think_color}${thinking}${RST}"
if [ "$effort" != "-" ]; then
  case "$effort" in
    high)       effort_color=$YLW ;;
    xhigh)      effort_color=$ORG ;;
    max)        effort_color=$RED ;;
    *)          effort_color=$DIM ;;
  esac
  think_seg="${think_seg}${DIM}·${RST}${effort_color}${effort}${RST}"
fi

style_seg=""
if [ "$style" != "-" ] && [ "$style" != "default" ]; then
  style_seg=" | style: ${MAG}${style}${RST}"
fi

printf '%s | %s / %s (%s%s%%%s) | think: %s%s\n' \
  "${GRN}${model}${RST}" \
  "$(fmt_num "$ctx_used")" "$(fmt_num "$ctx_total")" \
  "$ctx_color" "$(fmt_pct1 "$ctx_used_pct")" "$RST" \
  "$think_seg" "$style_seg"

# Line 2 (only when rate limits present): 5h bar + reset | 7d bar + reset | cost
line2=""
if [ "$rate_5h_pct" != "-" ]; then
  line2="${ORG}5h${RST} $(make_bar "$rate_5h_pct") $(fmt_pct1 "$rate_5h_pct")%"
  [ "$rate_5h_resets" != "-" ] && line2="$line2 ${DIM}~$(fmt_reset_time "$rate_5h_resets")${RST}"
fi
if [ "$rate_7d_pct" != "-" ]; then
  seg="${ORG}7d${RST} $(make_bar "$rate_7d_pct") $(fmt_pct1 "$rate_7d_pct")%"
  [ "$rate_7d_resets" != "-" ] && seg="$seg ${DIM}~$(fmt_reset_full "$rate_7d_resets")${RST}"
  line2="${line2:+$line2 | }$seg"
fi
if [ -n "$line2" ]; then
  cost_fmt=$(awk -v c="$cost" 'BEGIN { printf "%.2f", c }')
  printf '%s | $%s\n' "$line2" "$cost_fmt"
fi

exit 0
