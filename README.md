# netconnect.sh

`netconnect.sh` is a cross-distro network diagnostics and connection manager script designed for modern Linux distributions (including openSUSE Tumbleweed) while retaining explicit fallback paths for legacy/stable systems (including Debian 11 bullseye).

## Key capabilities
- Full diagnostics report with modules for:
  - interfaces, routes, DNS, DHCP leases, logs, neighbors/ARP,
  - interface statistics, listening ports, firewall state,
  - network manager stack details, path diagnostics, connectivity summary.
- Multi-backend connection flows:
  - Ethernet DHCP: `nmcli -> dhclient -> dhcpcd -> udhcpc`
  - Ethernet static: NetworkManager profile or manual `iproute2` fallback
  - Wi-Fi connect: `nmcli -> iwctl -> wpa_cli`
- Wi-Fi scanning across available stacks (`nmcli`, `iw`, `wpa_cli`).
- DNS configuration helpers (`resolvectl`, `resolvconf`, direct `resolv.conf` fallback).
- Saved Wi-Fi profile support in `/etc/netconnect/profiles` with restricted permissions.
- Interactive menu mode and non-interactive automation mode.
- Cross-distro optional dependency installer (`zypper`, `apt`, `dnf`, `yum`, `pacman`).
- Optional dry-run mode (`--dry-run`) for mutating operations.
- Optional command transcript persistence (`--trace-to-file`) under `/var/log/netconnect/trace/commands.trace`.

## Usage examples
```bash
sudo ./netconnect.sh --status
sudo ./netconnect.sh --check-only
sudo ./netconnect.sh -n -i eth0 -t ethernet -m dhcp
sudo ./netconnect.sh -n -i eth0 -t ethernet -m static --static-cidr 192.168.1.10/24 --gateway 192.168.1.1 --dns "1.1.1.1,8.8.8.8"
sudo ./netconnect.sh -n -i wlan0 -t wifi --ssid "CorpWiFi" --password "secret" --security WPA2-PSK
printf '%s\n' 'secret' | sudo ./netconnect.sh -n -i wlan0 -t wifi --ssid "CorpWiFi" --password-stdin --security WPA2-PSK
sudo ./netconnect.sh --install-deps
sudo ./netconnect.sh --dry-run -n -i wlan0 -t wifi --ssid "CorpWiFi" --password "secret" --security WPA2-PSK
```

## Notes
- Root privileges are required.
- Interactive mode is entered automatically when no explicit target is passed and `-n` is not used.
- The script is intentionally modular so features remain comprehensive while code duplication stays low.

## Debugging Wi-Fi failures
- Use `--debug-level 3` to capture per-backend command output (`nmcli`, `iwctl`, `wpa_cli`) in stderr and log file.
- Add `--trace-to-file` to write command transcripts to `/var/log/netconnect/trace/commands.trace`.
- Interactive mode now rejects empty passwords for non-open security modes and returns a failed workflow exit when configuration attempts fail.
- If already connected to the same SSID, the script now validates current link/L3 state before retrying a reconnect.
- The script checks `rfkill` and fails early on hard blocks, while trying to clear soft blocks automatically.
- On repeated Wi-Fi backend failures, it emits backend/reason details and prints remediation hints.
