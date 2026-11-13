# Reads the prototype's log and prints the spike's numbers against docs/spikes/toast-buttons.md.
# Usage: powershell -ExecutionPolicy Bypass -File prototype/toast-buttons/measure.ps1 [-LogPath <path>]
param([string]$LogPath = (Join-Path $env:LOCALAPPDATA 'ToastSpike\spike.log'))
$ErrorActionPreference = 'Stop'
$lines = Get-Content -Encoding UTF8 $LogPath

function Last-Count([string]$name) {
  $m = $lines | Select-String -Pattern "$name count=(\d+)" | Select-Object -Last 1
  if ($m) { [int]$m.Matches[0].Groups[1].Value } else { 0 }
}

# The first activation logged for each toast id, as id -> action.
$first = @{}
foreach ($l in $lines) {
  if ($l -match 'activated id=([a-z]\d+);action=(\w+)') {
    if (-not $first.ContainsKey($Matches[1])) { $first[$Matches[1]] = $Matches[2] }
  }
}
function Clicks([string]$prefix) {
  $ok = 0
  foreach ($n in 1..5) {
    $expected = if ($n -le 3) { 'snooze' } else { 'dismiss' }
    $got = $first["$prefix$n"]
    $mark = if ($got -eq $expected) { $ok++; 'ok' } else { 'MISS' }
    "  $prefix$n expected=$expected got=$(if ($got) { $got } else { '-' }) $mark"
  }
  "  => $ok of 5"
}

"Log: $LogPath"
"Delivery (history count after 10 shown): $(Last-Count 'delivery-history') of 10"
"Banner clicks:"
Clicks 'b'
"Notification center clicks:"
Clicks 'a'
"Do not disturb (history count after 1 shown): $(Last-Count 'dnd-history') of 1"
"Failed toasts logged: $(($lines | Select-String -Pattern ' failed id=').Count)"
