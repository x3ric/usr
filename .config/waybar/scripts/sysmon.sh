#!/usr/bin/env bash
set -uo pipefail
state_dir="${XDG_RUNTIME_DIR:-/tmp}/waybar-sysmon"
mkdir -p "$state_dir" 2>/dev/null || true

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
idle_all=$((idle + iowait))
non_idle=$((user + nice + system + irq + softirq + steal))
total=$((idle_all + non_idle))
prev_file="$state_dir/cpu"
cpu_used=0
if [[ -f "$prev_file" ]]; then
  read -r prev_total prev_idle < "$prev_file" || true
  dt=$((total - ${prev_total:-total}))
  di=$((idle_all - ${prev_idle:-idle_all}))
  ((dt > 0)) && cpu_used=$(((100 * (dt - di)) / dt))
fi
printf '%s %s\n' "$total" "$idle_all" > "$prev_file" 2>/dev/null || true

cpu_temp_str=""
for f in /sys/class/thermal/thermal_zone*/temp; do
  [[ -f "$f" ]] || continue
  t=$(cat "$f" 2>/dev/null) || continue
  [[ -n "$t" ]] || continue
  t=$((t / 1000))
  ((t > 0 && t < 120)) || continue
  cpu_temp_str=" ${t}°C"
  break
done

core_count=$(nproc 2>/dev/null || echo "?")
mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)
mem_avail=$(awk '/MemAvailable/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)
mem_used=$((mem_total - mem_avail))
mem_pct=0; [[ "$mem_total" -gt 0 ]] && mem_pct=$((mem_used * 100 / mem_total))
swap_total=$(awk '/SwapTotal/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)
swap_free=$(awk '/SwapFree/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)
swap_used=$((swap_total - swap_free))
swap_pct=0; [[ "$swap_total" -gt 0 ]] && swap_pct=$((swap_used * 100 / swap_total))
to_gb() { awk "BEGIN {printf \"%.1f\", $1/1048576}"; }
mem_str="$(to_gb "$mem_used")/$(to_gb "$mem_total")G"
swap_str=""; [[ "$swap_total" -gt 0 ]] && swap_str=" swp $(to_gb "$swap_used")/$(to_gb "$swap_total")G ${swap_pct}%"

disk_used=$(df -h / 2>/dev/null | awk 'NR==2 {print $3}') || disk_used="?"
disk_total=$(df -h / 2>/dev/null | awk 'NR==2 {print $2}') || disk_total="?"
disk_pct=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}') || disk_pct="0%"

net_dev=$(ip -o route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}') || net_dev=""
net_str=""
if [[ -n "$net_dev" && -f "/sys/class/net/$net_dev/statistics/rx_bytes" ]]; then
  rx_bytes=$(cat "/sys/class/net/$net_dev/statistics/rx_bytes")
  tx_bytes=$(cat "/sys/class/net/$net_dev/statistics/tx_bytes")
  rx_file="$state_dir/rx"; tx_file="$state_dir/tx"; ts_file="$state_dir/ts"
  now=$(date +%s%N); rx_str="--"; tx_str="--"
  if [[ -f "$rx_file" ]]; then
    old_rx=$(cat "$rx_file" 2>/dev/null || echo "$rx_bytes")
    old_tx=$(cat "$tx_file" 2>/dev/null || echo "$tx_bytes")
    old_ts=$(cat "$ts_file" 2>/dev/null || echo "$now")
    elapsed=$(((now - old_ts) / 1000000))
    if [[ "$elapsed" -gt 0 ]]; then
      drx=$((((rx_bytes - old_rx) * 1000) / elapsed)); [[ "$drx" -lt 0 ]] && drx=0
      dtx=$((((tx_bytes - old_tx) * 1000) / elapsed)); [[ "$dtx" -lt 0 ]] && dtx=0
      rx_str=$(numfmt --to=iec --format="%.1f" "$drx" 2>/dev/null || echo "$drx")
      tx_str=$(numfmt --to=iec --format="%.1f" "$dtx" 2>/dev/null || echo "$dtx")
      rx_str="${rx_str}/s"; tx_str="${tx_str}/s"
    fi
  fi
  echo "$rx_bytes" > "$rx_file" 2>/dev/null || true
  echo "$tx_bytes" > "$tx_file" 2>/dev/null || true
  echo "$now" > "$ts_file" 2>/dev/null || true
  net_str=" ${rx_str} ${tx_str}"
fi

load=$(awk '{print $1" "$2" "$3}' /proc/loadavg 2>/dev/null || echo "?")
uptime_sec=$(awk '{print int($1)}' /proc/uptime 2>/dev/null || echo 0)
uptime_d=$((uptime_sec / 86400)); uptime_sec=$((uptime_sec % 86400))
uptime_h=$((uptime_sec / 3600)); uptime_sec=$((uptime_sec % 3600))
uptime_m=$((uptime_sec / 60))
if [[ "$uptime_d" -gt 0 ]]; then uptime_str="${uptime_d}d${uptime_h}h"; elif [[ "$uptime_h" -gt 0 ]]; then uptime_str="${uptime_h}h${uptime_m}m"; else uptime_str="${uptime_m}m"; fi
proc_count=$(awk '/^processes/ {print $2}' /proc/stat 2>/dev/null || echo "?")
short_text="${cpu_used}%${cpu_temp_str} ${mem_pct}% ${disk_pct}"
tooltip="CPU: ${cpu_used}%${cpu_temp_str}  Load: ${load}  Cores: ${core_count}
Mem: ${mem_str} ${mem_pct}%${swap_str}
Disk: ${disk_used}/${disk_total} (${disk_pct})
Net:${net_str}
Up: ${uptime_str}  Procs: ${proc_count}"
text_esc=$(printf '%s' "$short_text" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()),end="")')
tip_esc=$(printf '%s' "$tooltip" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()),end="")')
printf '{"text":%s,"tooltip":%s}\n' "$text_esc" "$tip_esc"
