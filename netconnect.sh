#!/usr/bin/env bash
# ==============================================================================
# netconnect.sh
# Cross-distro network diagnostics + connection manager
# Modern-first (openSUSE Tumbleweed, Fedora, Ubuntu) with legacy fallbacks
#
# Consolidated edition (v11.1.0):
# - Keeps v10.3.0 expanded diagnostics and safe profile parsing
# - Adds /run runtime temp dir for command transcripts
# - Adds RFKill hard-block detection + smarter unblock
# - Adds NM disconnect to avoid stale Wi-Fi state
# - Adds Wi-Fi failure hints + optional driver reload (last resort)
# - Adds best-effort --dry-run for mutating actions (diagnostics still run)
# ==============================================================================

set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
SCRIPT_VERSION="11.1.0"

# ------------------------------------------------------------------------------
# Paths / persistence
# ------------------------------------------------------------------------------
readonly LOCK_FILE="/run/netconnect.lock"
readonly CONFIG_DIR="/etc/netconnect"
readonly PROFILE_DIR="${CONFIG_DIR}/profiles"
readonly LOG_DIR="/var/log/netconnect"
readonly LOG_FILE="${LOG_DIR}/netconnect.log"
readonly TRACE_DIR="${LOG_DIR}/trace"
readonly RUNTIME_DIR="/run/netconnect"

# ------------------------------------------------------------------------------
# Defaults / tunables
# ------------------------------------------------------------------------------
readonly DEFAULT_PING_IPS=("1.1.1.1" "8.8.8.8")
readonly DEFAULT_PING_HOST="example.com"
readonly DEFAULT_EXTERNAL_IP_URL="https://api.ipify.org"
readonly DEFAULT_TRACE_TARGET="8.8.8.8"

readonly DHCP_TIMEOUT=45
readonly WIFI_SCAN_WAIT=6
readonly WIFI_CONNECT_WAIT=35
readonly WIFI_ASSOC_POLL_INTERVAL=2
readonly MAX_BACKEND_RETRIES=2

# Backend-specific waits
readonly NM_WAIT=25
readonly WPA_WAIT=35

# ------------------------------------------------------------------------------
# Runtime flags / args
# ------------------------------------------------------------------------------
NON_INTERACTIVE=false
CHECK_ONLY=false
SHOW_STATUS=false
INSTALL_DEPS=false
SHOW_VERSION=false

DBG=false
DEBUG_LEVEL=1
TRACE_TO_FILE=false

DRY_RUN=false

TARGET_IFACE=""
TARGET_TYPE=""      # ethernet|wifi
TARGET_METHOD=""    # dhcp|static
STATIC_CIDR=""
STATIC_GATEWAY=""
STATIC_DNS=""

WIFI_SSID=""
WIFI_PASSWORD=""
WIFI_PASSWORD_STDIN=false
WIFI_SECURITY=""
WIFI_HIDDEN=false

# ------------------------------------------------------------------------------
# Runtime globals
# ------------------------------------------------------------------------------
OS_ID="unknown"
OS_VERSION_ID="unknown"
OS_PRETTY="unknown"
PKG_MANAGER="unknown"

NM_AVAILABLE=false
IWD_AVAILABLE=false
WPA_CLI_AVAILABLE=false
SYSTEMD_AVAILABLE=false
RFKILL_AVAILABLE=false

LAST_WIFI_ERROR=""
LAST_WIFI_BACKEND=""

# ------------------------------------------------------------------------------
# Logging / helpers
# ------------------------------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }
ts() { date '+%F %T'; }

log() {
  local level="$1"; shift
  local msg="$*"
  local line="[$(ts)] [$level] $msg"

  if [[ -d "$LOG_DIR" ]] && [[ -w "$LOG_DIR" || -w "$LOG_FILE" ]]; then
    printf '%s\n' "$line" | tee -a "$LOG_FILE" >&2
  else
    printf '%s\n' "$line" >&2
  fi
}

debug()   { [[ "$DBG" == true && "$DEBUG_LEVEL" -ge 1 ]] && log DEBUG "$*"   || true; }
debugv()  { [[ "$DBG" == true && "$DEBUG_LEVEL" -ge 2 ]] && log VERBOSE "$*" || true; }
debugvv() { [[ "$DBG" == true && "$DEBUG_LEVEL" -ge 3 ]] && log TRACE "$*"   || true; }

die() {
  log ERROR "$*"
  exit 1
}

trim() {
  local v="$1"
  v="${v#${v%%[![:space:]]*}}"
  v="${v%${v##*[![:space:]]}}"
  printf '%s\n' "$v"
}

safe_iface() {
  printf '%s\n' "$1" | tr -cd '[:alnum:]_.:-'
}

mask_secret() {
  local val="$1" len
  [[ -z "${val:-}" ]] && { printf '\n'; return; }
  len=${#val}
  if [[ $len -le 4 ]]; then
    printf '****\n'
  else
    printf '%s***%s\n' "${val:0:2}" "${val: -2}"
  fi
}

print_header() {
  printf '==================================================\n'
  printf '%s\n' "$1"
  printf '==================================================\n'
}

set_last_wifi_error() {
  LAST_WIFI_BACKEND="$1"
  LAST_WIFI_ERROR="$2"
  debug "Wi-Fi error [$LAST_WIFI_BACKEND]: $LAST_WIFI_ERROR"
}

_mktemp_runtime() {
  mkdir -p "$RUNTIME_DIR" >/dev/null 2>&1 || true
  if [[ -d "$RUNTIME_DIR" && -w "$RUNTIME_DIR" ]]; then
    mktemp "${RUNTIME_DIR}/cmd.XXXXXX"
  else
    mktemp /tmp/netconnect_cmd.XXXXXX
  fi
}

run_cmd_logged() {
  # run_cmd_logged "tag" cmd args...
  local tag="$1"; shift
  local tmp rc
  tmp=$(_mktemp_runtime)

  if "$@" >"$tmp" 2>&1; then
    debugv "$tag: success"
    if [[ "$DBG" == true && "$DEBUG_LEVEL" -ge 3 ]]; then
      while IFS= read -r line; do
        debugvv "$tag: $line"
      done < "$tmp"
    fi
    if [[ "$TRACE_TO_FILE" == true ]]; then
      {
        echo "[$(ts)] [$tag] success"
        sed -n '1,200p' "$tmp"
        echo
      } >> "${TRACE_DIR}/commands.trace"
    fi
    rm -f "$tmp" >/dev/null 2>&1 || true
    return 0
  fi

  rc=$?
  debug "$tag: failed rc=$rc"
  while IFS= read -r line; do
    debug "$tag: $line"
  done < "$tmp"

  if [[ "$TRACE_TO_FILE" == true ]]; then
    {
      echo "[$(ts)] [$tag] failed rc=$rc"
      sed -n '1,300p' "$tmp"
      echo
    } >> "${TRACE_DIR}/commands.trace"
  fi

  rm -f "$tmp" >/dev/null 2>&1 || true
  return "$rc"
}

run_action_logged() {
  # Like run_cmd_logged, but respects --dry-run for mutating actions.
  local tag="$1"; shift
  if [[ "$DRY_RUN" == true ]]; then
    log INFO "[DRY-RUN] $tag :: $*"
    return 0
  fi
  run_cmd_logged "$tag" "$@"
}

service_active() {
  local svc="$1"
  have systemctl && systemctl is-active --quiet "$svc"
}

# ------------------------------------------------------------------------------
# Cleanup / lock
# ------------------------------------------------------------------------------
cleanup() {
  local ec=$?
  rm -f "$LOCK_FILE" >/dev/null 2>&1 || true
  # Best-effort cleanup of runtime transcript files
  if [[ -d "$RUNTIME_DIR" ]]; then
    find "$RUNTIME_DIR" -maxdepth 1 -type f -name 'cmd.*' -delete >/dev/null 2>&1 || true
  fi
  exit "$ec"
}
trap cleanup EXIT
trap 'log WARN "Interrupted by signal"; exit 130' INT TERM

require_root() {
  [[ ${EUID:-$(id -u)} -eq 0 ]] || die "Run as root (sudo)."
}

acquire_lock() {
  if [[ -f "$LOCK_FILE" ]]; then
    local pid
    pid=$(cat "$LOCK_FILE" 2>/dev/null || true)
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      die "Another instance is running (pid=$pid)."
    fi
    rm -f "$LOCK_FILE" || true
  fi
  printf '%s\n' "$$" > "$LOCK_FILE"
}

init_dirs() {
  mkdir -p "$CONFIG_DIR" "$PROFILE_DIR" "$LOG_DIR" "$TRACE_DIR" "$RUNTIME_DIR" >/dev/null 2>&1 || true
  touch "$LOG_FILE" >/dev/null 2>&1 || true
  if [[ "$TRACE_TO_FILE" == true ]]; then
    touch "${TRACE_DIR}/commands.trace" >/dev/null 2>&1 || true
  fi
}

# ------------------------------------------------------------------------------
# OS / stack detection
# ------------------------------------------------------------------------------
detect_os() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_VERSION_ID="${VERSION_ID:-unknown}"
    OS_PRETTY="${PRETTY_NAME:-unknown}"
  fi

  if have zypper; then
    PKG_MANAGER="zypper"
  elif have apt-get; then
    PKG_MANAGER="apt"
  elif have dnf; then
    PKG_MANAGER="dnf"
  elif have yum; then
    PKG_MANAGER="yum"
  elif have pacman; then
    PKG_MANAGER="pacman"
  fi

  SYSTEMD_AVAILABLE=false; have systemctl && SYSTEMD_AVAILABLE=true
  RFKILL_AVAILABLE=false; have rfkill && RFKILL_AVAILABLE=true

  log INFO "Detected OS=$OS_ID version=$OS_VERSION_ID pkg=$PKG_MANAGER"
}

detect_network_stack() {
  NM_AVAILABLE=false
  IWD_AVAILABLE=false
  WPA_CLI_AVAILABLE=false

  if have nmcli; then
    if $SYSTEMD_AVAILABLE; then
      service_active NetworkManager && NM_AVAILABLE=true
    else
      nmcli -t general status >/dev/null 2>&1 && NM_AVAILABLE=true
    fi
  fi

  if have iwctl; then
    if $SYSTEMD_AVAILABLE; then
      service_active iwd && IWD_AVAILABLE=true
    else
      iwctl --version >/dev/null 2>&1 && IWD_AVAILABLE=true
    fi
  fi

  have wpa_cli && WPA_CLI_AVAILABLE=true

  debug "NM_AVAILABLE=$NM_AVAILABLE IWD_AVAILABLE=$IWD_AVAILABLE WPA_CLI_AVAILABLE=$WPA_CLI_AVAILABLE"
}

install_optional_deps() {
  print_header "INSTALL OPTIONAL DEPENDENCIES"

  case "$PKG_MANAGER" in
    zypper)
      zypper --non-interactive refresh || true
      zypper --non-interactive install -y \
        iproute2 iputils traceroute curl wget network-manager wpa_supplicant \
        iw dhcpcd net-tools nftables wireless-tools rfkill || true
      ;;
    apt)
      apt-get update -qq || true
      DEBIAN_FRONTEND=noninteractive apt-get install -y \
        iproute2 iputils-ping traceroute curl wget network-manager wpasupplicant \
        iw isc-dhcp-client dhcpcd5 net-tools nftables wireless-tools rfkill || true
      ;;
    dnf)
      dnf -y install \
        iproute iputils traceroute curl wget NetworkManager wpa_supplicant iw \
        dhcp-client net-tools nftables wireless-tools util-linux rfkill || true
      ;;
    yum)
      yum -y install \
        iproute iputils traceroute curl wget NetworkManager wpa_supplicant iw \
        dhcp-client net-tools nftables wireless-tools util-linux rfkill || true
      ;;
    pacman)
      pacman -Sy --noconfirm \
        iproute2 iputils traceroute curl wget networkmanager wpa_supplicant iw \
        dhclient net-tools nftables wireless_tools util-linux rfkill || true
      ;;
    *)
      log WARN "No supported package manager found. Skipping install."
      ;;
  esac

  detect_network_stack
}

# ------------------------------------------------------------------------------
# Usage / parsing
# ------------------------------------------------------------------------------
usage() {
  cat <<USAGE
$SCRIPT_NAME v$SCRIPT_VERSION
Cross-distro network diagnostics and connection manager

Usage: sudo $SCRIPT_NAME [options]

General:
  -h, --help
  -v, --version
  -d, --debug
  --debug-level N            1..3
  --trace-to-file            write command traces to ${TRACE_DIR}/commands.trace
  --dry-run                  print mutating actions without applying them
  -n, --non-interactive
  --install-deps

Actions:
  -c, --check-only
  --status

Target:
  -i, --interface IFACE
  -t, --type ethernet|wifi
  -m, --method dhcp|static

Static:
  --static-cidr CIDR
  --gateway IP
  --dns "IP,IP"

Wi-Fi:
  --ssid SSID
  --password PASS
  --password-stdin           read password from stdin (safer than argv)
  --security Open|WEP|WPA-PSK|WPA2-PSK|WPA3-SAE|SAE
  --hidden
USAGE
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) usage; exit 0 ;;
      -v|--version) SHOW_VERSION=true ;;
      -d|--debug) DBG=true; DEBUG_LEVEL=2 ;;
      --debug-level)
        [[ $# -lt 2 ]] && die "Missing value for $1"
        DBG=true
        DEBUG_LEVEL="$2"
        [[ "$DEBUG_LEVEL" =~ ^[1-3]$ ]] || die "--debug-level must be 1..3"
        shift
        ;;
      --trace-to-file) TRACE_TO_FILE=true ;;
      --dry-run) DRY_RUN=true ;;
      -n|--non-interactive) NON_INTERACTIVE=true ;;
      -c|--check-only) CHECK_ONLY=true ;;
      --status) SHOW_STATUS=true ;;
      --install-deps) INSTALL_DEPS=true ;;
      -i|--interface) [[ $# -lt 2 ]] && die "Missing value for $1"; TARGET_IFACE=$(safe_iface "$2"); shift ;;
      -t|--type) [[ $# -lt 2 ]] && die "Missing value for $1"; TARGET_TYPE=$(trim "${2,,}"); shift ;;
      -m|--method) [[ $# -lt 2 ]] && die "Missing value for $1"; TARGET_METHOD=$(trim "${2,,}"); shift ;;
      --static-cidr) [[ $# -lt 2 ]] && die "Missing value for $1"; STATIC_CIDR="$2"; shift ;;
      --gateway) [[ $# -lt 2 ]] && die "Missing value for $1"; STATIC_GATEWAY="$2"; shift ;;
      --dns) [[ $# -lt 2 ]] && die "Missing value for $1"; STATIC_DNS="$2"; shift ;;
      --ssid) [[ $# -lt 2 ]] && die "Missing value for $1"; WIFI_SSID="$2"; shift ;;
      --password) [[ $# -lt 2 ]] && die "Missing value for $1"; WIFI_PASSWORD="$2"; shift ;;
      --password-stdin) WIFI_PASSWORD_STDIN=true ;;
      --security) [[ $# -lt 2 ]] && die "Missing value for $1"; WIFI_SECURITY="$2"; shift ;;
      --hidden) WIFI_HIDDEN=true ;;
      *) die "Unknown option: $1" ;;
    esac
    shift
  done

  [[ -z "$TARGET_TYPE" || "$TARGET_TYPE" == "ethernet" || "$TARGET_TYPE" == "wifi" ]] || die "--type must be ethernet|wifi"
  [[ -z "$TARGET_METHOD" || "$TARGET_METHOD" == "dhcp" || "$TARGET_METHOD" == "static" ]] || die "--method must be dhcp|static"
}

# ------------------------------------------------------------------------------
# Validation
# ------------------------------------------------------------------------------
is_valid_ipv4() {
  local ip="$1"
  [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  local IFS='.' a b c d
  read -r a b c d <<< "$ip"
  for o in "$a" "$b" "$c" "$d"; do
    ((o >= 0 && o <= 255)) || return 1
  done
  return 0
}

is_valid_cidr() {
  local cidr="$1" ip mask
  [[ "$cidr" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]{1,2})$ ]] || return 1
  ip="${cidr%/*}"
  mask="${cidr#*/}"
  is_valid_ipv4 "$ip" || return 1
  ((mask >= 1 && mask <= 32)) || return 1
  return 0
}

iface_exists() {
  [[ -n "$1" && -e "/sys/class/net/$1" ]]
}

iface_is_wifi() {
  [[ -n "$1" && -d "/sys/class/net/$1/wireless" ]]
}

iface_has_ipv4() {
  local iface="$1"
  have ip && ip -4 addr show dev "$iface" 2>/dev/null | grep -q 'inet '
}

wifi_connected_ssid() {
  local iface="$1"
  if have nmcli; then
    nmcli -t -f ACTIVE,SSID dev wifi list ifname "$iface" 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}'
    return 0
  fi
  if have iwgetid; then
    iwgetid -r "$iface" 2>/dev/null || true
    return 0
  fi
  printf '\n'
}

rfkill_wifi_hard_blocked() {
  $RFKILL_AVAILABLE || return 1
  rfkill list wifi 2>/dev/null | grep -q "Hard blocked: yes"
}

ensure_wifi_unblocked() {
  # detect hard block and fail early; soft block -> unblock.
  local iface="$1"
  iface_is_wifi "$iface" || return 0
  $RFKILL_AVAILABLE || return 0

  run_cmd_logged "rfkill list" rfkill list || true

  if rfkill list wifi 2>/dev/null | grep -q "Soft blocked: yes"; then
    log WARN "Wi-Fi appears soft-blocked (rfkill); attempting unblock"
    run_action_logged "rfkill unblock wifi" rfkill unblock wifi || true
  fi

  if rfkill_wifi_hard_blocked; then
    log ERROR "Wi-Fi appears HARD blocked (rfkill). Check hardware switch/BIOS/firmware."
    return 1
  fi

  return 0
}

wifi_state_snapshot() {
  local iface="$1"
  debug "--- WIFI STATE SNAPSHOT ($iface) ---"

  have ip && run_cmd_logged "ip link $iface" ip -d link show "$iface" || true
  have ip && run_cmd_logged "ip addr $iface" ip -4 -6 addr show "$iface" || true

  if have nmcli; then
    run_cmd_logged "nmcli general" nmcli general status || true
    run_cmd_logged "nmcli device show $iface" nmcli device show "$iface" || true
    run_cmd_logged "nmcli wifi list $iface" nmcli -t -f ACTIVE,SSID,SECURITY,SIGNAL,FREQ dev wifi list ifname "$iface" || true
    run_cmd_logged "nmcli active" nmcli -f NAME,UUID,TYPE,DEVICE connection show --active || true
  fi

  if have iw; then
    run_cmd_logged "iw dev $iface info" iw dev "$iface" info || true
    run_cmd_logged "iw dev $iface link" iw dev "$iface" link || true
  fi

  if have wpa_cli; then
    run_cmd_logged "wpa_cli status $iface" wpa_cli -i "$iface" status || true
  fi

  if $RFKILL_AVAILABLE; then
    run_cmd_logged "rfkill list" rfkill list || true
  fi
}

network_failure_hints() {
  local iface="$1"
  print_header "WIFI FAILURE HINTS"
  echo "- Interface: $iface"
  echo "- Verify passphrase/security matches the AP settings."
  echo "- If using WPA3, try WPA2-PSK temporarily to isolate compatibility."
  echo "- Try disconnecting and retrying; inspect manager reason codes."
  if have nmcli; then
    nmcli -f GENERAL.STATE,GENERAL.REASON,GENERAL.CONNECTION device show "$iface" 2>/dev/null || true
  fi
  echo "- Logs to inspect:"
  echo "    journalctl -b | grep -Ei 'wlan|wifi|wpa|supplicant|iwd|NetworkManager|firmware'"
}

iface_driver() {
  local iface="$1"
  [[ -e "/sys/class/net/$iface/device/driver/module" ]] || return 1
  basename "$(readlink -f "/sys/class/net/$iface/device/driver/module")"
}

nm_disconnect_iface() {
  local iface="$1"
  $NM_AVAILABLE || return 0
  run_action_logged "nmcli dev disconnect $iface" nmcli device disconnect "$iface" || true
}

# ------------------------------------------------------------------------------
# Discovery
# ------------------------------------------------------------------------------
get_eth_ifaces() {
  local out=()
  if have ip; then
    while IFS= read -r ifn; do
      [[ -z "$ifn" || "$ifn" == "lo" ]] && continue
      [[ -d "/sys/class/net/$ifn/wireless" ]] && continue
      [[ -e "/sys/class/net/$ifn/device" ]] || continue
      out+=("$ifn")
    done < <(ip -o link show | awk -F': ' '{print $2}' | sed 's/@.*//')
  elif have ifconfig; then
    while IFS= read -r ifn; do
      [[ "$ifn" == "lo" ]] && continue
      [[ -d "/sys/class/net/$ifn/wireless" ]] && continue
      out+=("$ifn")
    done < <(ifconfig -a | sed -n 's/^\([^ :]*\).*/\1/p')
  fi
  [[ ${#out[@]} -gt 0 ]] && printf '%s\n' "${out[@]}"
}

get_wifi_ifaces() {
  local out=()
  if have iw; then
    while IFS= read -r ifn; do
      [[ -n "$ifn" ]] && out+=("$ifn")
    done < <(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}')
  fi

  if [[ ${#out[@]} -eq 0 ]] && have ip; then
    while IFS= read -r ifn; do
      [[ -d "/sys/class/net/$ifn/wireless" ]] && out+=("$ifn")
    done < <(ip -o link show | awk -F': ' '{print $2}' | sed 's/@.*//')
  fi

  [[ ${#out[@]} -gt 0 ]] && printf '%s\n' "${out[@]}"
}

bring_iface_up() {
  local iface="$1"
  iface_exists "$iface" || { log ERROR "Interface not found: $iface"; return 1; }

  if iface_is_wifi "$iface"; then
    ensure_wifi_unblocked "$iface" || return 1
  fi

  if have ip; then
    run_action_logged "ip link up $iface" ip link set "$iface" up
  elif have ifconfig; then
    run_action_logged "ifconfig up $iface" ifconfig "$iface" up
  else
    log ERROR "No tool available to bring interfaces up (ip/ifconfig missing)."
    return 1
  fi
}

# ------------------------------------------------------------------------------
# Diagnostics
# ------------------------------------------------------------------------------
report_system() {
  print_header "SYSTEM"
  echo "Generated: $(date -Is)"
  echo "Hostname: $(hostname -f 2>/dev/null || hostname 2>/dev/null || echo unknown)"
  echo "Kernel: $(uname -srmo 2>/dev/null || uname -a)"
  echo "OS: $OS_PRETTY"
  echo "PID: $$"
}

report_interfaces() {
  print_header "NETWORK INTERFACES"
  if have ip; then
    echo "[Modern] ip -br addr"
    ip -br addr show || true
    echo
    echo "[Modern] ip -d link"
    ip -d link show | sed -n '1,260p' || true
  fi
  if have ifconfig; then
    echo
    echo "[Legacy] ifconfig -a"
    ifconfig -a || true
  fi
}

report_routes() {
  print_header "ROUTING"
  if have ip; then
    echo "[Modern] ip route"
    ip route show || true
    echo
    echo "[Modern] ip -6 route"
    ip -6 route show || true
  fi
  if have route; then
    echo
    echo "[Legacy] route -n"
    route -n || true
  elif have netstat; then
    echo
    echo "[Legacy] netstat -rn"
    netstat -rn || true
  fi
}

report_dns() {
  print_header "DNS"
  if have resolvectl; then
    echo "[Modern] resolvectl status"
    resolvectl status || true
  elif have systemd-resolve; then
    echo "[Legacy-modern] systemd-resolve --status"
    systemd-resolve --status || true
  fi
  echo
  echo "[File] /etc/resolv.conf"
  [[ -f /etc/resolv.conf ]] && sed -n '1,220p' /etc/resolv.conf || echo "/etc/resolv.conf not found"
}

report_dhcp_leases() {
  print_header "DHCP LEASES"
  local found=0
  local patterns=(
    "/var/lib/dhcp/*.leases"
    "/var/lib/dhcp/dhclient*.lease*"
    "/var/lib/NetworkManager/*.lease"
    "/var/lib/wicked/lease/*"
    "/var/db/dhcpd.leases"
  )
  local pat f
  for pat in "${patterns[@]}"; do
    # shellcheck disable=SC2086
    for f in $pat; do
      [[ -f "$f" ]] || continue
      found=1
      echo "Lease file: $f"
      if file "$f" 2>/dev/null | grep -qiE 'text|ascii|utf'; then
        tail -n 50 "$f" || true
      else
        echo "(binary/non-text lease file skipped)"
      fi
      echo "----------------------------------------"
    done
  done
  [[ $found -eq 0 ]] && echo "No known lease files found"
}

report_logs() {
  print_header "RECENT NETWORK LOGS"
  if have journalctl; then
    journalctl -b --no-pager -n 700 2>/dev/null \
      | grep -Ei 'dhcp|network|wpa|wifi|ethernet|carrier|link is (up|down)|supplicant|nmcli|iwd|firmware' \
      | tail -n 140 || true
  elif [[ -f /var/log/syslog ]]; then
    grep -Ei 'dhcp|network|wpa|wifi|ethernet|carrier|supplicant|nmcli|iwd|firmware' /var/log/syslog | tail -n 140 || true
  elif [[ -f /var/log/messages ]]; then
    grep -Ei 'dhcp|network|wpa|wifi|ethernet|carrier|supplicant|nmcli|iwd|firmware' /var/log/messages | tail -n 140 || true
  else
    echo "No supported log source available"
  fi
}

report_neighbors() {
  print_header "NEIGHBOR / ARP"
  if have ip; then
    ip neigh show || true
  elif have arp; then
    arp -n || true
  else
    echo "No neighbor tool found"
  fi
}

report_interface_stats() {
  print_header "INTERFACE STATS"
  if have ip; then
    ip -s link show || true
  elif have netstat; then
    netstat -i || true
  else
    echo "No stats tool found"
  fi
}

report_ports() {
  print_header "LISTENING PORTS"
  if have ss; then
    ss -tulpen || true
  elif have netstat; then
    netstat -tulpen || true
  else
    echo "Neither ss nor netstat available"
  fi
}

report_firewall() {
  print_header "FIREWALL"
  if have firewall-cmd && service_active firewalld; then
    echo "[firewalld]"
    firewall-cmd --list-all || true
  elif have nft; then
    echo "[nftables]"
    nft list ruleset | sed -n '1,280p' || true
  elif have iptables; then
    echo "[iptables]"
    iptables -L -n -v | sed -n '1,220p' || true
  else
    echo "No supported firewall tool detected"
  fi
}

report_network_managers() {
  print_header "NETWORK MANAGER STACK"
  echo "NetworkManager available: $NM_AVAILABLE"
  $NM_AVAILABLE && { nmcli general status 2>/dev/null || true; nmcli device status 2>/dev/null || true; }

  echo
  echo "iwd available: $IWD_AVAILABLE"
  $IWD_AVAILABLE && iwctl --version 2>/dev/null || true

  echo
  echo "wpa_cli available: $WPA_CLI_AVAILABLE"
  $WPA_CLI_AVAILABLE && wpa_cli -v 2>/dev/null || true

  if have wicked; then
    echo
    echo "wicked detected"
    wicked ifstatus all 2>/dev/null || true
  fi
}

report_path_diagnostics() {
  print_header "PATH DIAGNOSTICS"
  if have tracepath; then
    tracepath -n -m 8 "$DEFAULT_TRACE_TARGET" || true
  elif have traceroute; then
    traceroute -n -m 8 "$DEFAULT_TRACE_TARGET" || true
  else
    echo "No tracepath/traceroute available"
  fi
}

connectivity_check() {
  print_header "CONNECTIVITY CHECK"
  local ip_ok=false dns_ok=false target

  if have ping; then
    for target in "${DEFAULT_PING_IPS[@]}"; do
      if ping -c 2 -W 2 "$target" >/dev/null 2>&1; then
        echo "IP connectivity OK via $target"
        ip_ok=true
        break
      fi
    done
    $ip_ok || echo "IP connectivity failed (${DEFAULT_PING_IPS[*]})"

    if ping -c 2 -W 2 "$DEFAULT_PING_HOST" >/dev/null 2>&1; then
      echo "DNS resolution OK ($DEFAULT_PING_HOST)"
      dns_ok=true
    else
      echo "DNS resolution failed ($DEFAULT_PING_HOST)"
    fi
  else
    echo "ping command unavailable"
  fi

  if have curl; then
    local ext
    ext=$(curl -fsS --connect-timeout 6 "$DEFAULT_EXTERNAL_IP_URL" 2>/dev/null || true)
    [[ -n "$ext" ]] && echo "External IP: $ext" || echo "External IP: unavailable"
  elif have wget; then
    local extw
    extw=$(wget -qO- --timeout=6 "$DEFAULT_EXTERNAL_IP_URL" 2>/dev/null || true)
    [[ -n "$extw" ]] && echo "External IP: $extw" || echo "External IP: unavailable"
  else
    echo "External IP probe skipped (curl/wget missing)"
  fi

  if $ip_ok && $dns_ok; then
    return 0
  elif $ip_ok; then
    return 2
  else
    return 1
  fi
}

diagnostics_report() {
  local rc=0
  print_header "NETWORK DIAGNOSTICS REPORT"
  report_system
  report_interfaces
  report_routes
  report_dns
  report_dhcp_leases
  report_logs
  report_neighbors
  report_interface_stats
  report_ports
  report_firewall
  report_network_managers
  report_path_diagnostics
  connectivity_check || rc=$?
  return "$rc"
}

show_status() {
  print_header "NETWORK STATUS"
  if have ip; then
    ip -br addr show || true
    ip route show || true
  else
    echo "ip command unavailable"
  fi

  if have nmcli; then
    nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>/dev/null || true
  fi

  connectivity_check || true
}

# ------------------------------------------------------------------------------
# DNS / profile
# ------------------------------------------------------------------------------
configure_dns() {
  local dns_csv="$1"
  [[ -z "$dns_csv" ]] && return 0

  if [[ "$DRY_RUN" == true ]]; then
    log INFO "[DRY-RUN] configure_dns :: $dns_csv"
    return 0
  fi

  local dns_arr=() dns_clean=() d
  IFS=',' read -r -a dns_arr <<< "$dns_csv"

  for d in "${dns_arr[@]}"; do
    d=$(trim "$d")
    is_valid_ipv4 "$d" || { log WARN "Skipping invalid DNS IP: $d"; continue; }
    dns_clean+=("$d")
  done

  [[ ${#dns_clean[@]} -eq 0 ]] && return 1

  if have resolvectl && service_active systemd-resolved; then
    if run_cmd_logged "resolvectl dns global" resolvectl dns "" "${dns_clean[@]}"; then
      run_cmd_logged "resolvectl flush-caches" resolvectl flush-caches || true
      log INFO "Configured DNS via systemd-resolved"
      return 0
    fi
  fi

  if have resolvconf; then
    {
      for d in "${dns_clean[@]}"; do printf 'nameserver %s\n' "$d"; done
    } | resolvconf -a netconnect >/dev/null 2>&1 && {
      resolvconf -u >/dev/null 2>&1 || true
      log INFO "Configured DNS via resolvconf"
      return 0
    }
  fi

  if [[ -L /etc/resolv.conf ]]; then
    log WARN "/etc/resolv.conf is symlink; direct write skipped"
    return 1
  fi

  {
    printf '# generated by %s %s at %s\n' "$SCRIPT_NAME" "$SCRIPT_VERSION" "$(date -Is)"
    for d in "${dns_clean[@]}"; do printf 'nameserver %s\n' "$d"; done
  } > /etc/resolv.conf

  log INFO "Configured DNS via /etc/resolv.conf"
  return 0
}

profile_path_for() {
  local iface="$1" ssid="$2" safe_ssid
  safe_ssid=$(printf '%s' "$ssid" | tr -cs '[:alnum:]_.-' '_')
  printf '%s/%s_%s.conf\n' "$PROFILE_DIR" "$iface" "$safe_ssid"
}

save_wifi_profile() {
  local iface="$1" ssid="$2" pass="$3" sec="$4" hidden="$5" p
  p=$(profile_path_for "$iface" "$ssid")

  if [[ "$DRY_RUN" == true ]]; then
    log INFO "[DRY-RUN] save_wifi_profile :: $p (SSID=$ssid sec=$sec hidden=$hidden pass=$(mask_secret "$pass"))"
    return 0
  fi

  umask 077
  {
    printf 'INTERFACE=%s\n' "$iface"
    printf 'SSID=%s\n' "$ssid"
    printf 'SECURITY=%s\n' "$sec"
    printf 'HIDDEN=%s\n' "$hidden"
    [[ -n "$pass" ]] && printf 'PASSWORD_B64=%s\n' "$(printf '%s' "$pass" | base64 | tr -d '\n')"
  } > "$p"

  log INFO "Saved Wi-Fi profile: $p"
}

load_wifi_profile_safe() {
  local profile_file="$1"
  [[ -f "$profile_file" ]] || return 1

  INTERFACE=""
  SSID=""
  SECURITY=""
  HIDDEN=""
  PASSWORD_B64=""

  while IFS='=' read -r k v; do
    [[ -z "${k:-}" ]] && continue
    case "$k" in
      INTERFACE|SSID|SECURITY|HIDDEN|PASSWORD_B64)
        printf -v "$k" '%s' "$v"
        ;;
      *)
        ;;
    esac
  done < "$profile_file"

  [[ -n "$INTERFACE" && -n "$SSID" ]] || return 1
  return 0
}

# ------------------------------------------------------------------------------
# DHCP / static
# ------------------------------------------------------------------------------
configure_dhcp_iface() {
  local iface="$1"

  bring_iface_up "$iface" || return 1

  if $NM_AVAILABLE; then
    debug "Trying DHCP via nmcli on $iface"
    run_action_logged "nmcli device connect $iface" nmcli device connect "$iface" || true
    run_action_logged "nmcli device reapply $iface" nmcli device reapply "$iface" || true
    run_action_logged "nmcli ipv4 auto $iface" nmcli device modify "$iface" ipv4.method auto ipv6.method auto || true
    run_action_logged "nmcli device up $iface" nmcli device up "$iface" || true
    sleep 3
    iface_has_ipv4 "$iface" && return 0
  fi

  if have dhclient; then
    debug "Trying DHCP via dhclient on $iface"
    run_action_logged "dhclient release $iface" dhclient -r "$iface" || true
    if [[ "$DRY_RUN" != true ]]; then
      timeout "$DHCP_TIMEOUT" dhclient "$iface" >/dev/null 2>&1 || true
    else
      log INFO "[DRY-RUN] dhclient $iface (timeout $DHCP_TIMEOUT)"
      return 0
    fi
    iface_has_ipv4 "$iface" && return 0
  fi

  if have dhcpcd; then
    debug "Trying DHCP via dhcpcd on $iface"
    run_action_logged "dhcpcd stop $iface" dhcpcd -k "$iface" || true
    if [[ "$DRY_RUN" != true ]]; then
      timeout "$DHCP_TIMEOUT" dhcpcd -w "$iface" >/dev/null 2>&1 || true
    else
      log INFO "[DRY-RUN] dhcpcd -w $iface (timeout $DHCP_TIMEOUT)"
      return 0
    fi
    iface_has_ipv4 "$iface" && return 0
  fi

  if have udhcpc; then
    debug "Trying DHCP via udhcpc on $iface"
    if [[ "$DRY_RUN" != true ]]; then
      timeout "$DHCP_TIMEOUT" udhcpc -n -q -i "$iface" >/dev/null 2>&1 || true
    else
      log INFO "[DRY-RUN] udhcpc -i $iface (timeout $DHCP_TIMEOUT)"
      return 0
    fi
    iface_has_ipv4 "$iface" && return 0
  fi

  log ERROR "Failed DHCP configuration on $iface"
  return 1
}

configure_static_iface() {
  local iface="$1" cidr="$2" gw="$3" dns_csv="$4"

  is_valid_cidr "$cidr" || { log ERROR "Invalid CIDR: $cidr"; return 1; }
  is_valid_ipv4 "$gw" || { log ERROR "Invalid gateway: $gw"; return 1; }
  bring_iface_up "$iface" || return 1

  if $NM_AVAILABLE; then
    local con="netconnect-static-${iface}-$$"
    run_action_logged "nmcli con del $con" nmcli connection delete "$con" || true
    if run_action_logged "nmcli con add static $con" nmcli connection add type ethernet con-name "$con" ifname "$iface" \
      ipv4.method manual ipv4.addresses "$cidr" ipv4.gateway "$gw" ipv6.method ignore connection.autoconnect no; then
      [[ -n "$dns_csv" ]] && run_action_logged "nmcli con dns $con" nmcli connection modify "$con" ipv4.dns "$dns_csv" || true
      run_action_logged "nmcli con up $con" nmcli connection up "$con" || true
      sleep 2
      if iface_has_ipv4 "$iface"; then
        log INFO "Static IP configured via NetworkManager"
        return 0
      fi
      run_action_logged "nmcli con cleanup $con" nmcli connection delete "$con" || true
    fi
  fi

  if have ip; then
    run_action_logged "ip flush $iface" ip addr flush dev "$iface" || true
    run_action_logged "ip add $cidr $iface" ip addr add "$cidr" dev "$iface" || return 1
    run_action_logged "ip route del default $iface" ip route del default dev "$iface" || true
    run_action_logged "ip route add default via $gw $iface" ip route add default via "$gw" dev "$iface" || return 1
    [[ -n "$dns_csv" ]] && configure_dns "$dns_csv" || true
    iface_has_ipv4 "$iface" && { log INFO "Static IP configured via iproute2"; return 0; }
  elif have ifconfig && have route; then
    local ip="${cidr%/*}"
    run_action_logged "ifconfig set $iface $ip" ifconfig "$iface" "$ip" up || return 1
    run_action_logged "route add default via $gw $iface" route add default gw "$gw" "$iface" || true
    [[ -n "$dns_csv" ]] && configure_dns "$dns_csv" || true
    log INFO "Static IP attempted via ifconfig/route"
    return 0
  fi

  log ERROR "Static configuration failed on $iface"
  return 1
}

# ------------------------------------------------------------------------------
# Wi-Fi scan/connect
# ------------------------------------------------------------------------------
scan_wifi_nmcli() {
  local iface="$1"
  run_cmd_logged "nmcli wifi rescan $iface" nmcli device wifi rescan ifname "$iface" || true
  sleep "$WIFI_SCAN_WAIT"
  nmcli -t -f SSID,SECURITY,SIGNAL,FREQ dev wifi list ifname "$iface" --rescan no 2>/dev/null || true
}

scan_wifi_iw() {
  local iface="$1"
  iw dev "$iface" scan 2>/dev/null | awk '
    /^BSS / {ssid="";signal="";freq="";security="Open"}
    /SSID:/ {sub(/^[ \t]*SSID:[ \t]*/, ""); ssid=$0}
    /signal:/ {signal=$2}
    /freq:/ {freq=$2}
    /RSN:/ {security="WPA2/WPA3"}
    /WPA:/ {if (security=="Open") security="WPA"}
    /^$/ { if (ssid != "") printf "%s:%s:%s:%s\n", ssid, security, signal, freq }
  '
}

scan_wifi_wpa_cli() {
  local iface="$1"
  run_cmd_logged "wpa_cli scan $iface" wpa_cli -i "$iface" scan || true
  sleep "$WIFI_SCAN_WAIT"
  wpa_cli -i "$iface" scan_results 2>/dev/null | tail -n +2 | awk -F'\t' '{
    if (NF >= 5) {
      sec="Open"
      if ($4 ~ /WPA3|SAE/) sec="WPA3-SAE"
      else if ($4 ~ /WPA2|RSN/) sec="WPA2-PSK"
      else if ($4 ~ /WPA/) sec="WPA-PSK"
      else if ($4 ~ /WEP/) sec="WEP"
      printf "%s:%s:%s:%s\n", $5, sec, $3, $2
    }
  }'
}

scan_wifi_networks() {
  local iface="$1"
  print_header "WIFI SCAN ($iface)"
  bring_iface_up "$iface" || return 1
  ensure_wifi_unblocked "$iface" || return 1

  if $NM_AVAILABLE; then
    echo "[nmcli]"
    scan_wifi_nmcli "$iface" || true
  fi

  if have iw; then
    echo
    echo "[iw]"
    scan_wifi_iw "$iface" || true
  fi

  if $WPA_CLI_AVAILABLE; then
    echo
    echo "[wpa_cli]"
    scan_wifi_wpa_cli "$iface" || true
  fi
}

ensure_wpa_supplicant_socket() {
  local iface="$1"

  if $NM_AVAILABLE || $IWD_AVAILABLE; then
    return 0
  fi

  if $SYSTEMD_AVAILABLE; then
    service_active wpa_supplicant || run_action_logged "systemctl start wpa_supplicant" systemctl start wpa_supplicant || true
  fi

  wpa_cli -i "$iface" status >/dev/null 2>&1 && return 0

  if have wpa_supplicant; then
    mkdir -p /run/wpa_supplicant /etc/wpa_supplicant >/dev/null 2>&1 || true
    local conf="/etc/wpa_supplicant/wpa_supplicant-${iface}.conf"
    if [[ ! -f "$conf" ]]; then
      umask 077
      {
        echo "ctrl_interface=DIR=/run/wpa_supplicant GROUP=netdev"
        echo "update_config=1"
      } > "$conf"
    fi
    run_action_logged "wpa_supplicant spawn $iface" wpa_supplicant -B -i "$iface" -c "$conf" -D nl80211,wext || true
    sleep 2
    wpa_cli -i "$iface" status >/dev/null 2>&1 && return 0
  fi

  return 1
}

connect_wifi_wpa_cli() {
  local iface="$1" ssid="$2" pass="$3" sec="$4" hidden="$5"

  ensure_wpa_supplicant_socket "$iface" || {
    set_last_wifi_error "wpa_cli" "wpa_supplicant control socket unavailable"
    return 1
  }

  local net_id
  net_id=$(wpa_cli -i "$iface" add_network 2>/dev/null | tail -n 1)
  [[ "$net_id" =~ ^[0-9]+$ ]] || {
    set_last_wifi_error "wpa_cli" "failed to create network profile"
    return 1
  }

  run_action_logged "wpa_cli set ssid $iface" wpa_cli -i "$iface" set_network "$net_id" ssid "\"$ssid\"" || true
  [[ "$hidden" == true ]] && run_action_logged "wpa_cli set hidden $iface" wpa_cli -i "$iface" set_network "$net_id" scan_ssid 1 || true

  case "${sec^^}" in
    OPEN)
      run_action_logged "wpa_cli key_mgmt NONE $iface" wpa_cli -i "$iface" set_network "$net_id" key_mgmt NONE || true ;;
    WEP)
      run_action_logged "wpa_cli wep mode $iface" wpa_cli -i "$iface" set_network "$net_id" key_mgmt NONE || true
      run_action_logged "wpa_cli wep key $iface" wpa_cli -i "$iface" set_network "$net_id" wep_key0 "\"$pass\"" || true ;;
    WPA3-SAE|SAE)
      run_action_logged "wpa_cli sae mode $iface" wpa_cli -i "$iface" set_network "$net_id" key_mgmt SAE || true
      run_action_logged "wpa_cli sae pass $iface" wpa_cli -i "$iface" set_network "$net_id" sae_password "\"$pass\"" || true ;;
    *)
      run_action_logged "wpa_cli psk mode $iface" wpa_cli -i "$iface" set_network "$net_id" key_mgmt WPA-PSK || true
      run_action_logged "wpa_cli psk set $iface" wpa_cli -i "$iface" set_network "$net_id" psk "\"$pass\"" || true ;;
  esac

  run_action_logged "wpa_cli enable network $iface" wpa_cli -i "$iface" enable_network "$net_id" || true
  run_action_logged "wpa_cli select network $iface" wpa_cli -i "$iface" select_network "$net_id" || true

  local i
  for ((i=0; i<WPA_WAIT; i+=WIFI_ASSOC_POLL_INTERVAL)); do
    if wpa_cli -i "$iface" status 2>/dev/null | grep -q 'wpa_state=COMPLETED'; then
      configure_dhcp_iface "$iface" && return 0
      break
    fi
    sleep "$WIFI_ASSOC_POLL_INTERVAL"
  done

  run_action_logged "wpa_cli cleanup network $iface" wpa_cli -i "$iface" remove_network "$net_id" || true
  set_last_wifi_error "wpa_cli" "association timeout or DHCP failure"
  return 1
}

connect_wifi_nmcli() {
  local iface="$1" ssid="$2" pass="$3" hidden="$4"

  local cmd=(nmcli --wait "$NM_WAIT" device wifi connect "$ssid" ifname "$iface")
  [[ -n "$pass" ]] && cmd+=(password "$pass")
  [[ "$hidden" == true ]] && cmd+=(hidden yes)

  if run_action_logged "nmcli wifi connect $ssid on $iface" "${cmd[@]}"; then
    sleep 2
    iface_has_ipv4 "$iface" && return 0
    configure_dhcp_iface "$iface" && return 0
    set_last_wifi_error "nmcli" "connected but no IPv4 after DHCP retry"
    return 1
  fi

  run_cmd_logged "nmcli reason $iface" nmcli -f GENERAL.STATE,GENERAL.REASON,GENERAL.CONNECTION,IP4.ADDRESS,IP4.GATEWAY device show "$iface" || true
  set_last_wifi_error "nmcli" "nmcli connect command failed"
  return 1
}

connect_wifi_iwd() {
  local iface="$1" ssid="$2" pass="$3"

  if [[ -n "$pass" ]]; then
    run_action_logged "iwctl connect $ssid on $iface" iwctl --passphrase "$pass" station "$iface" connect "$ssid" || {
      set_last_wifi_error "iwctl" "iwctl secure connect failed"
      return 1
    }
  else
    run_action_logged "iwctl connect open $ssid on $iface" iwctl station "$iface" connect "$ssid" || {
      set_last_wifi_error "iwctl" "iwctl open connect failed"
      return 1
    }
  fi

  sleep 2
  iface_has_ipv4 "$iface" && return 0
  configure_dhcp_iface "$iface" && return 0
  set_last_wifi_error "iwctl" "connected but no IPv4 after DHCP retry"
  return 1
}

connect_wifi_iface() {
  local iface="$1" ssid="$2" pass="${3:-}" sec="${4:-WPA2-PSK}" hidden="${5:-false}"

  LAST_WIFI_ERROR=""
  LAST_WIFI_BACKEND=""

  [[ -n "$ssid" ]] || { log ERROR "SSID is required"; return 1; }
  bring_iface_up "$iface" || return 1
  ensure_wifi_unblocked "$iface" || return 1

  if [[ "${sec^^}" != "OPEN" && -z "$pass" ]]; then
    log ERROR "Non-open security requires a non-empty password for SSID '$ssid'"
    return 1
  fi

  debug "Connecting Wi-Fi iface=$iface ssid=$ssid sec=$sec hidden=$hidden pass=$(mask_secret "$pass")"
  wifi_state_snapshot "$iface"

  # Avoid stale state issues
  nm_disconnect_iface "$iface"

  local current_ssid
  current_ssid=$(wifi_connected_ssid "$iface" || true)
  if [[ -n "$current_ssid" && "$current_ssid" == "$ssid" && -z "$pass" ]]; then
    debug "Already associated to target SSID '$ssid'"
    if iface_has_ipv4 "$iface"; then
      log INFO "Already connected to '$ssid' on $iface"
      return 0
    fi
  fi

  local attempt
  for ((attempt=1; attempt<=MAX_BACKEND_RETRIES; attempt++)); do
    debug "Wi-Fi connect attempt $attempt/$MAX_BACKEND_RETRIES"

    if $NM_AVAILABLE; then
      connect_wifi_nmcli "$iface" "$ssid" "$pass" "$hidden" && return 0
      debug "nmcli backend failed: $LAST_WIFI_ERROR"
    fi

    if $IWD_AVAILABLE; then
      connect_wifi_iwd "$iface" "$ssid" "$pass" && return 0
      debug "iwctl backend failed: $LAST_WIFI_ERROR"
    fi

    if $WPA_CLI_AVAILABLE; then
      connect_wifi_wpa_cli "$iface" "$ssid" "$pass" "$sec" "$hidden" && return 0
      debug "wpa_cli backend failed: $LAST_WIFI_ERROR"
    fi

    sleep 1
  done

  # Last resort: driver reload — gated and best-effort.
  if [[ "$DRY_RUN" != true ]] && iface_is_wifi "$iface" && have modprobe; then
    local drv
    drv=$(iface_driver "$iface" 2>/dev/null || true)
    if [[ -n "$drv" ]]; then
      debug "Attempting last-resort driver reload for $iface driver=$drv"
      run_action_logged "modprobe -r $drv" modprobe -r "$drv" || true
      sleep 1
      run_action_logged "modprobe $drv" modprobe "$drv" || true
      sleep 2
      # one quick retry after reload
      nm_disconnect_iface "$iface"
      if $NM_AVAILABLE; then
        connect_wifi_nmcli "$iface" "$ssid" "$pass" "$hidden" && return 0
      fi
      if $IWD_AVAILABLE; then
        connect_wifi_iwd "$iface" "$ssid" "$pass" && return 0
      fi
      if $WPA_CLI_AVAILABLE; then
        connect_wifi_wpa_cli "$iface" "$ssid" "$pass" "$sec" "$hidden" && return 0
      fi
    fi
  fi

  wifi_state_snapshot "$iface"
  network_failure_hints "$iface"
  log ERROR "Failed to connect Wi-Fi SSID '$ssid' on $iface (backend=${LAST_WIFI_BACKEND:-none}, reason=${LAST_WIFI_ERROR:-unspecified})"
  return 1
}

# ------------------------------------------------------------------------------
# Workflows
# ------------------------------------------------------------------------------
configure_ethernet_flow() {
  local iface="$1" method="$2"
  [[ -n "$iface" ]] || return 1
  iface_exists "$iface" || { log ERROR "Interface does not exist: $iface"; return 1; }

  case "$method" in
    static)
      [[ -n "$STATIC_CIDR" && -n "$STATIC_GATEWAY" ]] || {
        log ERROR "Static mode requires --static-cidr and --gateway"
        return 1
      }
      configure_static_iface "$iface" "$STATIC_CIDR" "$STATIC_GATEWAY" "$STATIC_DNS"
      ;;
    *)
      configure_dhcp_iface "$iface"
      ;;
  esac
}

configure_wifi_flow() {
  local iface="$1" ssid="$2" pass="$3" sec="$4" hidden="$5"

  iface_exists "$iface" || { log ERROR "Interface does not exist: $iface"; return 1; }
  [[ -n "$ssid" ]] || { log ERROR "Wi-Fi requires --ssid"; return 1; }

  connect_wifi_iface "$iface" "$ssid" "$pass" "$sec" "$hidden" && {
    save_wifi_profile "$iface" "$ssid" "$pass" "$sec" "$hidden"
    return 0
  }

  return 1
}

auto_connect_flow() {
  local rc=1 iface profile pass_decoded

  mapfile -t eths < <(get_eth_ifaces)
  for iface in "${eths[@]:-}"; do
    [[ -z "$iface" ]] && continue
    log INFO "Trying Ethernet DHCP on $iface"
    if configure_dhcp_iface "$iface"; then
      rc=0
      break
    fi
  done

  if [[ $rc -ne 0 && -n "${WIFI_SSID:-}" ]]; then
    mapfile -t wlans < <(get_wifi_ifaces)
    for iface in "${wlans[@]:-}"; do
      [[ -z "$iface" ]] && continue
      log INFO "Trying Wi-Fi on $iface with provided SSID"
      if connect_wifi_iface "$iface" "$WIFI_SSID" "${WIFI_PASSWORD:-}" "${WIFI_SECURITY:-WPA2-PSK}" "$WIFI_HIDDEN"; then
        save_wifi_profile "$iface" "$WIFI_SSID" "${WIFI_PASSWORD:-}" "${WIFI_SECURITY:-WPA2-PSK}" "$WIFI_HIDDEN"
        rc=0
        break
      fi
    done
  fi

  if [[ $rc -ne 0 ]]; then
    mapfile -t wlans2 < <(get_wifi_ifaces)
    for iface in "${wlans2[@]:-}"; do
      [[ -z "$iface" ]] && continue
      for profile in "$PROFILE_DIR/${iface}_"*.conf; do
        [[ -f "$profile" ]] || continue
        load_wifi_profile_safe "$profile" || continue
        pass_decoded=""
        [[ -n "${PASSWORD_B64:-}" ]] && pass_decoded=$(printf '%s' "$PASSWORD_B64" | base64 -d 2>/dev/null || true)

        log INFO "Trying saved profile on $iface (SSID=${SSID:-unknown})"
        if connect_wifi_iface "$iface" "${SSID:-}" "$pass_decoded" "${SECURITY:-WPA2-PSK}" "${HIDDEN:-false}"; then
          rc=0
          break 2
        fi
      done
    done
  fi

  return "$rc"
}

# ------------------------------------------------------------------------------
# Interactive mode
# ------------------------------------------------------------------------------
prompt() {
  local text="$1" def="${2:-}" val
  if [[ -n "$def" ]]; then
    read -r -p "$text [$def]: " val
    [[ -z "$val" ]] && val="$def"
  else
    read -r -p "$text: " val
  fi
  printf '%s\n' "$val"
}

prompt_secret() {
  local text="$1" val
  read -r -s -p "$text: " val
  echo >&2
  printf '%s\n' "$val"
}

choose_from_list() {
  local title="$1"; shift
  local arr=("$@")
  local n=${#arr[@]}
  [[ $n -gt 0 ]] || return 1

  echo "$title" >&2
  local i
  for ((i=0; i<n; i++)); do
    echo "  $((i+1))) ${arr[i]}" >&2
  done

  local choice
  while true; do
    read -r -p "Select [1-$n]: " choice
    [[ "$choice" =~ ^[0-9]+$ ]] || continue
    ((choice >= 1 && choice <= n)) || continue
    printf '%s\n' "${arr[choice-1]}"
    return 0
  done
}

interactive_menu() {
  local did_config=false
  local last_config_ok=false

  while true; do
    print_header "NETCONNECT MENU"
    cat <<MENU
1) Show full diagnostics report
2) Show short status
3) Configure Ethernet (DHCP)
4) Configure Ethernet (Static)
5) Scan Wi-Fi networks
6) Connect Wi-Fi
7) Connectivity check only
8) Exit
MENU

    local action
    read -r -p "Select action [1-8]: " action

    case "$action" in
      1)
        diagnostics_report || true
        ;;
      2)
        show_status
        ;;
      3)
        mapfile -t eths < <(get_eth_ifaces)
        [[ ${#eths[@]} -gt 0 ]] || { log ERROR "No Ethernet interfaces"; continue; }
        local eiface
        eiface=$(choose_from_list "Choose Ethernet interface:" "${eths[@]}") || continue
        did_config=true
        if configure_ethernet_flow "$eiface" dhcp; then last_config_ok=true; else last_config_ok=false; fi
        ;;
      4)
        mapfile -t eths2 < <(get_eth_ifaces)
        [[ ${#eths2[@]} -gt 0 ]] || { log ERROR "No Ethernet interfaces"; continue; }
        local eiface2
        eiface2=$(choose_from_list "Choose Ethernet interface:" "${eths2[@]}") || continue
        local cidr gw dns
        cidr=$(prompt "Static CIDR" "192.168.1.100/24")
        gw=$(prompt "Gateway" "192.168.1.1")
        dns=$(prompt "DNS list (comma separated)" "1.1.1.1,8.8.8.8")
        did_config=true
        if configure_static_iface "$eiface2" "$cidr" "$gw" "$dns"; then last_config_ok=true; else last_config_ok=false; fi
        ;;
      5)
        mapfile -t wlans < <(get_wifi_ifaces)
        [[ ${#wlans[@]} -gt 0 ]] || { log ERROR "No Wi-Fi interfaces"; continue; }
        local wiface
        wiface=$(choose_from_list "Choose Wi-Fi interface:" "${wlans[@]}") || continue
        scan_wifi_networks "$wiface" || true
        ;;
      6)
        mapfile -t wlans2 < <(get_wifi_ifaces)
        [[ ${#wlans2[@]} -gt 0 ]] || { log ERROR "No Wi-Fi interfaces"; continue; }
        local wiface2
        wiface2=$(choose_from_list "Choose Wi-Fi interface:" "${wlans2[@]}") || continue
        local ssid pass sec hid
        ssid=$(prompt "SSID")
        sec=$(prompt "Security (Open/WEP/WPA2-PSK/WPA3-SAE)" "WPA2-PSK")
        pass=""
        if [[ "${sec^^}" != "OPEN" ]]; then
          pass=$(prompt_secret "Password")
          [[ -n "$pass" ]] || { log ERROR "Password cannot be empty for $sec"; continue; }
        fi
        hid=$(prompt "Hidden SSID? (true/false)" "false")
        did_config=true
        if connect_wifi_iface "$wiface2" "$ssid" "$pass" "$sec" "$hid"; then
          save_wifi_profile "$wiface2" "$ssid" "$pass" "$sec" "$hid"
          last_config_ok=true
        else
          last_config_ok=false
          log ERROR "Wi-Fi connect failed backend=${LAST_WIFI_BACKEND:-unknown} reason=${LAST_WIFI_ERROR:-unknown}"
        fi
        ;;
      7)
        connectivity_check || true
        ;;
      8)
        log INFO "Exit requested"
        if [[ "$did_config" == true ]]; then
          [[ "$last_config_ok" == true ]] && return 0 || return 1
        fi
        connectivity_check >/dev/null 2>&1 && return 0 || return 1
        ;;
      *)
        log WARN "Invalid menu option"
        ;;
    esac

    echo
    read -r -p "Press Enter to continue..." _
  done
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  parse_args "$@"

  if $SHOW_VERSION; then
    echo "$SCRIPT_NAME v$SCRIPT_VERSION"
    exit 0
  fi

  # Read password from stdin if requested (safer than argv)
  if [[ "$WIFI_PASSWORD_STDIN" == true ]]; then
    # Trim trailing newline only; allow spaces
    IFS= read -r WIFI_PASSWORD || true
  fi

  require_root
  acquire_lock
  init_dirs
  detect_os
  detect_network_stack

  if $INSTALL_DEPS; then
    install_optional_deps
    exit 0
  fi

  if $SHOW_STATUS; then
    show_status
    exit 0
  fi

  if $CHECK_ONLY; then
    diagnostics_report
    exit $?
  fi

  local rc=1
  if [[ -n "${TARGET_IFACE:-}" && -n "${TARGET_TYPE:-}" ]]; then
    if [[ "$TARGET_TYPE" == "ethernet" ]]; then
      local method="${TARGET_METHOD:-dhcp}"
      configure_ethernet_flow "$TARGET_IFACE" "$method" && rc=0 || rc=1
    else
      configure_wifi_flow "$TARGET_IFACE" "$WIFI_SSID" "${WIFI_PASSWORD:-}" "${WIFI_SECURITY:-WPA2-PSK}" "$WIFI_HIDDEN" && rc=0 || rc=1
    fi
  else
    if [[ "$NON_INTERACTIVE" == true ]]; then
      auto_connect_flow && rc=0 || rc=1
    else
      interactive_menu && rc=0 || rc=1
    fi
  fi

  if [[ $rc -eq 0 ]]; then
    log INFO "Connection workflow completed successfully"
  else
    log ERROR "Connection workflow failed"
  fi

  connectivity_check || true
  return "$rc"
}

main "$@"
