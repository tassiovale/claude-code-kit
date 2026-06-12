# statusline.ps1 — Claude Code status line for Windows (PowerShell)
# Mirrors statusline.sh: model | dir | git | context bar | >200k flag | cost | rate limits
# No jq required — PowerShell parses JSON natively.
#
# Register in ~/.claude/settings.json (use FORWARD slashes in the path):
#   {
#     "statusLine": {
#       "type": "command",
#       "command": "powershell -NoProfile -ExecutionPolicy Bypass -File C:/Users/<you>/.claude/statusline.ps1"
#     }
#   }
# Have PowerShell 7? Swap `powershell` for `pwsh`. Windows Terminal recommended for ANSI/UTF-8.

# UTF-8 output so block/emoji glyphs render correctly
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }
$j = $raw | ConvertFrom-Json

# ANSI colors + glyphs (built from code points to dodge source-encoding issues)
$e   = [char]27
$RST = "$e[0m"; $DIM = "$e[2m"; $CYA = "$e[36m"; $RED = "$e[31m"; $YEL = "$e[33m"; $GRN = "$e[32m"
$BLOCK = "$([char]0x2588)"; $LIGHT = "$([char]0x2591)"; $WARN = "$([char]0x26A0)"
$LEAF  = [char]::ConvertFromUtf32(0x1F33F); $FOLDER = [char]::ConvertFromUtf32(0x1F4C1)
$inv   = [System.Globalization.CultureInfo]::InvariantCulture
function Sev([double]$p) { if ($p -ge 90) { $RED } elseif ($p -ge 70) { $YEL } else { $GRN } }

# --- Scalars with null fallbacks ---
$model = if ($j.model.display_name) { $j.model.display_name } else { 'Claude' }
$dir = if ($j.workspace.current_dir) { Split-Path $j.workspace.current_dir -Leaf }
       elseif ($j.cwd) { Split-Path $j.cwd -Leaf } else { '' }
$pct = if ($null -ne $j.context_window.used_percentage) {
         [int][math]::Floor([double]$j.context_window.used_percentage)
       } else { 0 }
if ($pct -lt 0) { $pct = 0 }; if ($pct -gt 100) { $pct = 100 }
$cost = if ($null -ne $j.cost.total_cost_usd) { [double]$j.cost.total_cost_usd } else { 0.0 }
$session = if ($j.session_id) { $j.session_id } else { 'nosession' }

# --- Git info, cached per session (5s TTL) to avoid lag on big repos ---
$cache = Join-Path $env:TEMP "ccline-git-$session.txt"
$fresh = (Test-Path $cache) -and (((Get-Date) - (Get-Item $cache).LastWriteTime).TotalSeconds -lt 5)
if (-not $fresh) {
    $b = ''; $s = 0; $m = 0
    try {
        & git rev-parse --git-dir *> $null
        if ($LASTEXITCODE -eq 0) {
            $b = (& git branch --show-current 2>$null)
            $s = @(& git diff --cached --numstat 2>$null).Count
            $m = @(& git diff --numstat 2>$null).Count
        }
    } catch { }
    [IO.File]::WriteAllText($cache, "$b`t$s`t$m")
}
$p = ([IO.File]::ReadAllText($cache)).TrimEnd("`r", "`n") -split "`t"
$branch = $p[0]; $staged = [int]$p[1]; $modified = [int]$p[2]

$git = ''
if ($branch) {
    $git = " $DIM$LEAF$RST $branch"
    if ($staged   -gt 0) { $git += " $GRN+$staged$RST" }
    if ($modified -gt 0) { $git += " $YEL~$modified$RST" }
}

# --- Context bar (10 chars) ---
$c = Sev $pct
$filled = [int][math]::Floor($pct / 10); $empty = 10 - $filled
$bar = ("$BLOCK" * $filled) + ("$LIGHT" * $empty)

# --- 200k flag ---
$over = ''
if ($j.exceeds_200k_tokens -eq $true) { $over = " $RED$WARN >200k$RST" }

# --- Rate limits (Pro/Max only, present after first API response) ---
$limits = ''
$fh = $j.rate_limits.five_hour.used_percentage
$sd = $j.rate_limits.seven_day.used_percentage
if ($null -ne $fh) { $v = [int][math]::Floor([double]$fh); $limits += " $(Sev $v)5h $v%$RST" }
if ($null -ne $sd) { $v = [int][math]::Floor([double]$sd); $limits += " $(Sev $v)7d $v%$RST" }
if ($limits) { $limits = " $DIM|$RST$limits" }

# --- Cost — invariant culture so it shows $1.27 (not R$ 1,27 on pt-BR systems) ---
$costFmt = '$' + $cost.ToString('0.00', $inv)

# --- Output (two lines) ---
Write-Output "$CYA[$model]$RST $DIM$FOLDER$RST $dir$git"
Write-Output "$c$bar$RST $pct% ctx$over $DIM|$RST $DIM$costFmt$RST$limits"
