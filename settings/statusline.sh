#!/usr/bin/env bash
# ~/.claude/statusline.sh
# Claude Code status line — two lines:
#   line 1: [model] 📁 dir 🌿 branch +staged ~modified
#   line 2: ██████░░░░ NN% ctx [⚠ >200k] | $cost | 5h NN% 7d NN%
#
# Setup:
#   chmod +x ~/.claude/statusline.sh
#   settings.json -> { "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" } }
# Requires: jq, git (optional), a 256-color/ANSI terminal.

input=$(cat)

# --- One jq pass: all scalar fields, tab-separated -------------------------
IFS=$'\t' read -r MODEL DIR PCT COST SESSION FIVE_H SEVEN_D OVER200 < <(
  jq -r '
    [ (.model.display_name // "Claude"),
      ((.workspace.current_dir // .cwd // "") | split("/") | last),
      ((.context_window.used_percentage // 0) | floor),
      (.cost.total_cost_usd // 0),
      (.session_id // "nosession"),
      (.rate_limits.five_hour.used_percentage // "" | if . == "" then "" else (floor|tostring) end),
      (.rate_limits.seven_day.used_percentage // "" | if . == "" then "" else (floor|tostring) end),
      (.exceeds_200k_tokens // false)
    ] | @tsv' <<<"$input"
)

# Clamp percentage to a sane 0–100 so the bar math never goes negative
(( PCT < 0   )) && PCT=0
(( PCT > 100 )) && PCT=100

# --- Colors ----------------------------------------------------------------
RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'
CYA=$'\033[36m'; DIM=$'\033[2m';  RST=$'\033[0m'

# green < 70, yellow 70–89, red >= 90  (takes an integer percent as $1)
sev_color() {
  if   (( $1 >= 90 )); then printf '%s' "$RED"
  elif (( $1 >= 70 )); then printf '%s' "$YEL"
  else                      printf '%s' "$GRN"; fi
}

# --- Git info, cached per session (5s TTL) to avoid lag on big repos --------
CACHE="/tmp/ccline-git-$SESSION"
TTL=5
cache_stale() {
  [ ! -f "$CACHE" ] || \
  (( $(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || stat -f %m "$CACHE" 2>/dev/null || echo 0) > TTL ))
}
if cache_stale; then
  if git rev-parse --git-dir >/dev/null 2>&1; then
    B=$(git branch --show-current 2>/dev/null)
    S=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    M=$(git diff         --numstat 2>/dev/null | wc -l | tr -d ' ')
    printf '%s\t%s\t%s\n' "$B" "$S" "$M" > "$CACHE"
  else
    printf '\t\t\n' > "$CACHE"
  fi
fi
IFS=$'\t' read -r BRANCH STAGED MODIFIED < "$CACHE"

GIT=""
if [ -n "$BRANCH" ]; then
  GIT=" ${DIM}🌿${RST} $BRANCH"
  (( STAGED   > 0 )) && GIT+=" ${GRN}+${STAGED}${RST}"
  (( MODIFIED > 0 )) && GIT+=" ${YEL}~${MODIFIED}${RST}"
fi

# --- Context bar (10 chars) ------------------------------------------------
C=$(sev_color "$PCT")
FILLED=$(( PCT / 10 )); EMPTY=$(( 10 - FILLED ))
printf -v F "%${FILLED}s"; printf -v E "%${EMPTY}s"
BAR="${F// /█}${E// /░}"

# --- 200k flag (matters mainly on extended-context models) -----------------
OVER=""
[ "$OVER200" = "true" ] && OVER=" ${RED}⚠ >200k${RST}"

# --- Rate limits (Pro/Max only, present after first API response) ----------
LIMITS=""
[ -n "$FIVE_H"  ] && LIMITS+=" $(sev_color "$FIVE_H")5h ${FIVE_H}%${RST}"
[ -n "$SEVEN_D" ] && LIMITS+=" $(sev_color "$SEVEN_D")7d ${SEVEN_D}%${RST}"
[ -n "$LIMITS"  ] && LIMITS=" ${DIM}|${RST}$LIMITS"

# --- Cost ------------------------------------------------------------------
COST_FMT=$(printf '$%.2f' "$COST")

# --- Output (colors are already real ESC bytes, so %s is safe) -------------
printf '%s\n' "${CYA}[$MODEL]${RST} ${DIM}📁${RST} $DIR$GIT"
printf '%s\n' "${C}${BAR}${RST} ${PCT}% ctx$OVER ${DIM}|${RST} ${DIM}${COST_FMT}${RST}$LIMITS"
