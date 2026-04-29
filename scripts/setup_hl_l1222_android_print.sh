#!/bin/bash
set -euo pipefail

# setup_hl_l1222_android_print.sh
#
# Purpose:
#   Configure Raspberry Pi 4B+ (ARM64) running openSUSE Tumbleweed as a
#   print server for a USB-connected Brother HL-L1222 / HL-L1222-V so Android
#   devices can print over same Wi-Fi via IPP/Mopria.
#
# Execution context:
#   Run as a normal user from home directory (~/). Script uses sudo for
#   privileged operations.
#
# Safety:
#   - Backs up /etc/cups/cupsd.conf before any modification.
#   - Requires explicit confirmation before modifying CUPS config.
#   - Requires explicit confirmation before deleting an existing queue
#     with the same name.

QUEUE_NAME="Brother_HL_L1222_V"
DEVICE_URI=""
MODEL_NAME=""
ENABLE_BLUETOOTH="yes"
ENABLE_UPLOAD="no"
UPLOAD_PORT="8088"
MAX_UPLOAD_BYTES="52428800"

SCRIPT_DIR="/usr/local/lib/hll1222-print"
HOTFOLDER="/var/spool/hll1222-hotfolder"
HOTFOLDER_SERVICE="hll1222-hotfolder"
UPLOAD_SERVICE="hll1222-upload"

TMP_DIR=""
CUPSD_CONF="/etc/cups/cupsd.conf"

log() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }
err() { echo "[ERROR] $*" >&2; }

cleanup() {
  if [[ -n "${TMP_DIR}" && -d "${TMP_DIR}" ]]; then
    rm -rf "${TMP_DIR}"
  fi
}
trap cleanup EXIT SIGINT SIGTERM

require_command() {
  local cmd="$1"
  local pkg="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log "Command '$cmd' missing; installing package '$pkg'..."
    if ! sudo zypper --non-interactive install --no-recommends "$pkg"; then
      err "Failed to install package '$pkg' for command '$cmd'."
      exit 1
    fi
  fi
}

confirm_high_risk() {
  local message="$1"
  read -r -p "WARNING: ${message} Type 'yes' to continue: " answer
  if [[ "$answer" != "yes" ]]; then
    err "Operation cancelled by user."
    exit 1
  fi
}

usage() {
  cat <<USAGE
Usage:
  bash setup_hl_l1222_android_print.sh [options]

Options:
  --queue NAME            CUPS queue name (default: ${QUEUE_NAME})
  --device URI            USB device URI from lpinfo -v
  --model MODEL           Model/PPD from lpinfo -m
  --enable-bluetooth      Enable Bluetooth fallback services
  --disable-bluetooth     Disable Bluetooth fallback services
  --enable-upload         Enable optional LAN upload page fallback
  --disable-upload        Disable optional LAN upload page fallback (default)
  --upload-port PORT      Upload page port (default: ${UPLOAD_PORT})
  --status                Print diagnostics and exit
  -h, --help              Show this help
USAGE
}

parse_args() {
  local arg
  while [[ $# -gt 0 ]]; do
    arg="$1"
    case "$arg" in
      --queue)
        QUEUE_NAME="$2"
        shift 2
        ;;
      --device)
        DEVICE_URI="$2"
        shift 2
        ;;
      --model)
        MODEL_NAME="$2"
        shift 2
        ;;
      --enable-bluetooth)
        ENABLE_BLUETOOTH="yes"
        shift
        ;;
      --disable-bluetooth)
        ENABLE_BLUETOOTH="no"
        shift
        ;;
      --enable-upload)
        ENABLE_UPLOAD="yes"
        shift
        ;;
      --disable-upload)
        ENABLE_UPLOAD="no"
        shift
        ;;
      --upload-port)
        UPLOAD_PORT="$2"
        shift 2
        ;;
      --status)
        STATUS_ONLY="yes"
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        err "Unknown option: $arg"
        usage
        exit 1
        ;;
    esac
  done
}

status_report() {
  echo "=== System ==="
  uname -a
  echo
  echo "=== Architecture ==="
  uname -m
  echo
  echo "=== USB printers ==="
  lsusb | grep -Ei 'brother|printer' || true
  echo
  echo "=== CUPS devices ==="
  lpinfo -v || true
  echo
  echo "=== CUPS models (filtered) ==="
  lpinfo -m | grep -Ei 'brother|hl|brlaser|everywhere|generic|laser|mono|pcl' || true
  echo
  echo "=== CUPS status ==="
  lpstat -t || true
}

install_dependencies() {
  log "Refreshing repositories..."
  if ! sudo zypper --non-interactive refresh; then
    err "Failed to refresh zypper repositories."
    exit 1
  fi

  log "Installing required packages..."
  if ! sudo zypper --non-interactive install --no-recommends \
    cups cups-client cups-filters ghostscript \
    avahi nss-mdns firewalld usbutils python3; then
    err "Failed to install required base packages."
    exit 1
  fi

  # Optional package; continue if unavailable.
  if ! sudo zypper --non-interactive install --no-recommends printer-driver-brlaser; then
    warn "Optional package printer-driver-brlaser was not installed."
  fi

  if [[ "$ENABLE_BLUETOOTH" == "yes" ]]; then
    log "Installing Bluetooth packages..."
    if ! sudo zypper --non-interactive install --no-recommends bluez bluez-tools; then
      err "Failed to install Bluetooth packages."
      exit 1
    fi
  fi
}

enable_services() {
  log "Enabling and starting core services..."
  if ! sudo systemctl enable --now cups.service; then
    err "Failed to enable/start cups.service."
    exit 1
  fi
  if ! sudo systemctl enable --now avahi-daemon.service; then
    err "Failed to enable/start avahi-daemon.service."
    exit 1
  fi
  if ! sudo systemctl enable --now firewalld.service; then
    err "Failed to enable/start firewalld.service."
    exit 1
  fi
  if [[ "$ENABLE_BLUETOOTH" == "yes" ]]; then
    if ! sudo systemctl enable --now bluetooth.service; then
      warn "Failed to enable/start bluetooth.service; continuing."
    fi
  fi
}

configure_firewall() {
  log "Opening firewall for IPP and mDNS..."
  if ! sudo firewall-cmd --permanent --add-service=ipp; then
    warn "Could not add firewalld service 'ipp'."
  fi
  if ! sudo firewall-cmd --permanent --add-service=mdns; then
    warn "Could not add firewalld service 'mdns'."
  fi
  if [[ "$ENABLE_UPLOAD" == "yes" ]]; then
    if ! sudo firewall-cmd --permanent --add-port="${UPLOAD_PORT}/tcp"; then
      warn "Could not open upload port ${UPLOAD_PORT}/tcp."
    fi
  fi
  if ! sudo firewall-cmd --reload; then
    warn "Failed to reload firewall rules."
  fi
}

configure_cups_sharing() {
  confirm_high_risk "This will modify ${CUPSD_CONF} (a backup will be created)."

  local backup
  backup="${CUPSD_CONF}.bak.$(date +%Y%m%d%H%M%S)"
  log "Creating CUPS config backup at ${backup}..."
  if ! sudo cp -a "${CUPSD_CONF}" "${backup}"; then
    err "Failed to create backup of ${CUPSD_CONF}."
    exit 1
  fi

  log "Configuring CUPS sharing using cupsctl..."
  if ! sudo cupsctl --share-printers --remote-any; then
    err "Failed to configure cups sharing with cupsctl."
    exit 1
  fi

  # Ensure WebInterface and mDNS browsing directives exist.
  if ! sudo grep -qi '^WebInterface[[:space:]]\+Yes' "${CUPSD_CONF}"; then
    echo 'WebInterface Yes' | sudo tee -a "${CUPSD_CONF}" >/dev/null
  fi
  if ! sudo grep -qi '^Browsing[[:space:]]\+Yes' "${CUPSD_CONF}"; then
    echo 'Browsing Yes' | sudo tee -a "${CUPSD_CONF}" >/dev/null
  fi
  if ! sudo grep -qi '^BrowseLocalProtocols[[:space:]]\+dnssd' "${CUPSD_CONF}"; then
    echo 'BrowseLocalProtocols dnssd' | sudo tee -a "${CUPSD_CONF}" >/dev/null
  fi

  if ! sudo systemctl restart cups.service; then
    err "Failed to restart cups.service after config change."
    exit 1
  fi
}

detect_usb_uri() {
  if [[ -n "$DEVICE_URI" ]]; then
    return 0
  fi

  log "Detecting Brother USB URI..."
  DEVICE_URI="$(lpinfo -v | awk 'BEGIN{IGNORECASE=1} /^direct[[:space:]]+usb:\/\// && /Brother|HL|L1222/ {print $2; exit}')"

  if [[ -z "$DEVICE_URI" ]]; then
    err "Could not detect Brother USB URI."
    echo "Available CUPS devices:"
    lpinfo -v || true
    exit 1
  fi

  log "Detected URI: ${DEVICE_URI}"
}

select_model() {
  if [[ -n "$MODEL_NAME" ]]; then
    return 0
  fi

  log "Selecting best available print model..."

  # 1) Prefer brlaser/Brother model lines if available.
  MODEL_NAME="$(lpinfo -m | awk 'BEGIN{IGNORECASE=1} /brlaser/ || (/Brother/ && /HL/ && /1200|1210|1212|1222|L12/) {print $1; exit}')"
  if [[ -n "$MODEL_NAME" ]]; then
    log "Selected model: ${MODEL_NAME}"
    return 0
  fi

  # 2) Fallback to everywhere if available.
  if lpinfo -m | awk '{print $1}' | grep -qx 'everywhere'; then
    MODEL_NAME="everywhere"
    warn "Falling back to 'everywhere' model."
    return 0
  fi

  # 3) Fallback to generic mono laser.
  MODEL_NAME="$(lpinfo -m | awk 'BEGIN{IGNORECASE=1} /Generic/ && /laser|mono|pcl/ {print $1; exit}')"
  if [[ -n "$MODEL_NAME" ]]; then
    warn "Using generic fallback model: ${MODEL_NAME}"
    return 0
  fi

  err "No suitable model found automatically."
  echo "Candidate models:"
  lpinfo -m | grep -Ei 'brother|hl|brlaser|everywhere|generic|laser|mono|pcl' || true
  exit 1
}

create_or_replace_queue() {
  detect_usb_uri
  select_model

  if lpstat -p "$QUEUE_NAME" >/dev/null 2>&1; then
    confirm_high_risk "Queue '${QUEUE_NAME}' already exists and will be deleted/recreated."
    if ! sudo lpadmin -x "$QUEUE_NAME"; then
      err "Failed to remove existing queue ${QUEUE_NAME}."
      exit 1
    fi
  fi

  log "Creating printer queue ${QUEUE_NAME}..."
  if ! sudo lpadmin -p "$QUEUE_NAME" -E -v "$DEVICE_URI" -m "$MODEL_NAME"; then
    err "Failed to create queue ${QUEUE_NAME}."
    exit 1
  fi

  if ! sudo lpadmin -p "$QUEUE_NAME" -o printer-is-shared=true -o media=A4 -o PageSize=A4 -o sides=one-sided; then
    err "Failed to set queue defaults for ${QUEUE_NAME}."
    exit 1
  fi

  if ! sudo cupsenable "$QUEUE_NAME"; then
    err "Failed to enable queue ${QUEUE_NAME}."
    exit 1
  fi

  if ! sudo cupsaccept "$QUEUE_NAME"; then
    err "Failed to set queue ${QUEUE_NAME} to accept jobs."
    exit 1
  fi

  if ! sudo lpoptions -d "$QUEUE_NAME"; then
    err "Failed to set default printer to ${QUEUE_NAME}."
    exit 1
  fi

  if ! sudo systemctl restart cups.service; then
    err "Failed to restart CUPS after queue creation."
    exit 1
  fi
}

install_hotfolder_service() {
  log "Installing hotfolder auto-print watcher..."

  if ! sudo install -d -m 0755 "$SCRIPT_DIR"; then
    err "Failed to create script directory ${SCRIPT_DIR}."
    exit 1
  fi
  if ! sudo install -d -m 0775 -o lp -g lp "$HOTFOLDER"; then
    err "Failed to create hotfolder ${HOTFOLDER}."
    exit 1
  fi

  TMP_DIR="$(mktemp -d)"
  local watcher_py
  watcher_py="${TMP_DIR}/hotfolder_watcher.py"

  cat > "$watcher_py" <<'PY'
#!/usr/bin/env python3
import os
import time
import shutil
import subprocess
from pathlib import Path

hot = Path(os.environ.get("PRINT_HOTFOLDER", "/var/spool/hll1222-hotfolder"))
queue = os.environ.get("PRINT_QUEUE", "Brother_HL_L1222_V")
allowed = {".pdf", ".txt", ".png", ".jpg", ".jpeg", ".tif", ".tiff"}
done = hot / "printed"
failed = hot / "failed"

for d in (hot, done, failed):
    d.mkdir(parents=True, exist_ok=True)


def stable(p: Path) -> bool:
    try:
        s1 = p.stat().st_size
        time.sleep(1)
        s2 = p.stat().st_size
        return s1 == s2 and s2 > 0
    except FileNotFoundError:
        return False


while True:
    for f in sorted(hot.iterdir()):
        if f.is_dir() or f.name.startswith('.'):
            continue
        tag = str(int(time.time())) + "-" + f.name
        if f.suffix.lower() not in allowed:
            try:
                shutil.move(str(f), str(failed / tag))
            except Exception:
                pass
            continue
        if not stable(f):
            continue
        try:
            subprocess.run(["lp", "-d", queue, str(f)], check=True)
            shutil.move(str(f), str(done / tag))
        except Exception:
            try:
                shutil.move(str(f), str(failed / tag))
            except Exception:
                pass
    time.sleep(3)
PY

  if ! sudo install -m 0755 "$watcher_py" "${SCRIPT_DIR}/hotfolder_watcher.py"; then
    err "Failed to install hotfolder watcher script."
    exit 1
  fi

  local service_file
  service_file="${TMP_DIR}/${HOTFOLDER_SERVICE}.service"
  cat > "$service_file" <<EOF2
[Unit]
Description=HL-L1222 hotfolder auto-print watcher
After=cups.service
Requires=cups.service

[Service]
Type=simple
User=lp
Group=lp
Environment=PRINT_QUEUE=${QUEUE_NAME}
Environment=PRINT_HOTFOLDER=${HOTFOLDER}
ExecStart=${SCRIPT_DIR}/hotfolder_watcher.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF2

  if ! sudo install -m 0644 "$service_file" "/etc/systemd/system/${HOTFOLDER_SERVICE}.service"; then
    err "Failed to install systemd service ${HOTFOLDER_SERVICE}."
    exit 1
  fi

  if ! sudo systemctl daemon-reload; then
    err "Failed to reload systemd daemon."
    exit 1
  fi

  if ! sudo systemctl enable --now "${HOTFOLDER_SERVICE}.service"; then
    err "Failed to enable/start ${HOTFOLDER_SERVICE}.service."
    exit 1
  fi

  TMP_DIR=""
}

install_upload_service_optional() {
  if [[ "$ENABLE_UPLOAD" != "yes" ]]; then
    return 0
  fi

  log "Installing optional LAN upload service on port ${UPLOAD_PORT}..."

  TMP_DIR="$(mktemp -d)"
  local upload_py
  upload_py="${TMP_DIR}/upload_server.py"

  cat > "$upload_py" <<'PY'
#!/usr/bin/env python3
import cgi
import html
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

hot = Path(os.environ.get("PRINT_HOTFOLDER", "/var/spool/hll1222-hotfolder"))
queue = os.environ.get("PRINT_QUEUE", "Brother_HL_L1222_V")
maxb = int(os.environ.get("MAX_UPLOAD_BYTES", "52428800"))
allowed = {".pdf", ".txt", ".png", ".jpg", ".jpeg", ".tif", ".tiff"}

hot.mkdir(parents=True, exist_ok=True)

page = f"""<!doctype html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>HL-L1222 Upload</title></head><body><h1>HL-L1222 Upload</h1><p>Queue: <b>{html.escape(queue)}</b></p><form method='post' enctype='multipart/form-data' action='/upload'><input type='file' name='file' required><button type='submit'>Upload</button></form><p>LAN only. Allowed: PDF/TXT/PNG/JPG/TIFF</p></body></html>"""

class H(BaseHTTPRequestHandler):
    def send_body(self, code, body, ctype="text/html; charset=utf-8"):
        data = body.encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if urlparse(self.path).path == "/":
            self.send_body(200, page)
        else:
            self.send_body(404, "Not found")

    def do_POST(self):
        if urlparse(self.path).path != "/upload":
            self.send_body(404, "Not found")
            return
        clen = int(self.headers.get("Content-Length", "0"))
        if clen <= 0 or clen > maxb:
            self.send_body(413, "Invalid upload size")
            return
        form = cgi.FieldStorage(fp=self.rfile, headers=self.headers, environ={"REQUEST_METHOD": "POST", "CONTENT_TYPE": self.headers.get("Content-Type", ""), "CONTENT_LENGTH": str(clen)})
        if "file" not in form or not getattr(form["file"], "filename", ""):
            self.send_body(400, "Missing file")
            return
        item = form["file"]
        name = Path(item.filename).name
        ext = Path(name).suffix.lower()
        if ext not in allowed:
            self.send_body(400, f"Unsupported file type: {html.escape(ext)}")
            return
        safe = "".join(ch if ch.isalnum() or ch in "._-" else "_" for ch in name)[:160]
        dst = hot / safe
        i = 1
        while dst.exists():
            dst = hot / f"{Path(safe).stem}_{i}{ext}"
            i += 1
        with open(dst, "wb") as f:
            while True:
                chunk = item.file.read(1024 * 1024)
                if not chunk:
                    break
                f.write(chunk)
        os.chmod(dst, 0o664)
        self.send_body(200, "<p>Uploaded successfully. File queued.</p><p><a href='/'>Back</a></p>")

if __name__ == "__main__":
    host = "0.0.0.0"
    port = int(os.environ.get("UPLOAD_PORT", "8088"))
    ThreadingHTTPServer((host, port), H).serve_forever()
PY

  if ! sudo install -d -m 0755 "$SCRIPT_DIR"; then
    err "Failed to ensure ${SCRIPT_DIR}."
    exit 1
  fi

  if ! sudo install -m 0755 "$upload_py" "${SCRIPT_DIR}/upload_server.py"; then
    err "Failed to install upload server script."
    exit 1
  fi

  local upload_unit
  upload_unit="${TMP_DIR}/${UPLOAD_SERVICE}.service"
  cat > "$upload_unit" <<EOF3
[Unit]
Description=HL-L1222 optional LAN upload service
After=network-online.target cups.service ${HOTFOLDER_SERVICE}.service
Wants=network-online.target
Requires=cups.service

[Service]
Type=simple
User=lp
Group=lp
Environment=PRINT_QUEUE=${QUEUE_NAME}
Environment=PRINT_HOTFOLDER=${HOTFOLDER}
Environment=UPLOAD_PORT=${UPLOAD_PORT}
Environment=MAX_UPLOAD_BYTES=${MAX_UPLOAD_BYTES}
ExecStart=${SCRIPT_DIR}/upload_server.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF3

  if ! sudo install -m 0644 "$upload_unit" "/etc/systemd/system/${UPLOAD_SERVICE}.service"; then
    err "Failed to install upload service unit."
    exit 1
  fi

  if ! sudo systemctl daemon-reload; then
    err "Failed to reload systemd daemon."
    exit 1
  fi

  if ! sudo systemctl enable --now "${UPLOAD_SERVICE}.service"; then
    err "Failed to enable/start ${UPLOAD_SERVICE}.service."
    exit 1
  fi

  TMP_DIR=""
}

print_summary() {
  local ip
  ip="$(hostname -I | awk '{print $1}')"

  echo
  echo "Setup complete."
  echo "Queue Name: ${QUEUE_NAME}"
  echo "Device URI: ${DEVICE_URI}"
  echo "Model Name: ${MODEL_NAME}"
  echo
  echo "Android on same Wi-Fi (recommended):"
  echo "  ipp://${ip}:631/printers/${QUEUE_NAME}"
  echo
  echo "Validate:"
  echo "  lpstat -t"
  echo "  lpinfo -v"
  echo "  lpinfo -m | grep -Ei 'brother|hl|brlaser|everywhere|generic|laser|mono|pcl'"
  echo "  echo 'test page from pi' | lp -d ${QUEUE_NAME}"
  echo
  if [[ "$ENABLE_UPLOAD" == "yes" ]]; then
    echo "Optional upload page:"
    echo "  http://${ip}:${UPLOAD_PORT}/"
    echo
  fi
  if [[ "$ENABLE_BLUETOOTH" == "yes" ]]; then
    echo "Bluetooth note: Android Bluetooth direct printing is not standard."
    echo "Use Wi-Fi IPP above; Bluetooth should be treated as file-transfer fallback."
  fi
}

main() {
  local STATUS_ONLY="no"
  parse_args "$@"

  require_command "sudo" "sudo"
  require_command "zypper" "zypper"
  require_command "lpinfo" "cups-client"
  require_command "lpadmin" "cups-client"
  require_command "lpstat" "cups-client"

  if [[ "${STATUS_ONLY:-no}" == "yes" ]]; then
    status_report
    exit 0
  fi

  install_dependencies
  enable_services
  configure_firewall
  configure_cups_sharing
  create_or_replace_queue
  install_hotfolder_service
  install_upload_service_optional
  print_summary
}

main "$@"
