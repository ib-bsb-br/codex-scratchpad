#!/usr/bin/env bash
set -euo pipefail

# Setup script: Brother HL-L1222(-V) USB printer on openSUSE Tumbleweed (Raspberry Pi)
# Goal: receive print jobs from Android phones over the same Wi-Fi (IPP/Mopria) via CUPS.
# Note: Bluetooth printing from Android to CUPS is generally unsupported/restricted; script enables
# practical network printing path and optional USB OTG fallback guidance.

PRINTER_NAME="Brother_HL_L1222_V"
PPD_MODEL="everywhere"

if [[ ${EUID} -ne 0 ]]; then
  echo "Please run as root: sudo bash $0"
  exit 1
fi

REQ_CMDS=(zypper systemctl lpinfo lpadmin lpstat)
for c in "${REQ_CMDS[@]}"; do
  command -v "$c" >/dev/null || { echo "Missing command: $c"; exit 1; }
done

echo "[1/8] Installing print/network discovery stack..."
zypper --non-interactive refresh
zypper --non-interactive install \
  cups cups-filters ghostscript avahi nss-mdns \
  firewalld ipp-usb bluez bluez-tools

echo "[2/8] Enabling required services..."
systemctl enable --now cups.service
systemctl enable --now avahi-daemon.service
systemctl enable --now firewalld.service
systemctl enable --now bluetooth.service

# Ensure cupsd listens on local network for Android clients using IPP/Mopria.
CUPSD_CONF="/etc/cups/cupsd.conf"
if ! grep -q '^Port 631' "$CUPSD_CONF"; then
  sed -i 's/^Listen localhost:631/# &/' "$CUPSD_CONF" || true
  echo 'Port 631' >> "$CUPSD_CONF"
fi

if ! grep -q '^Browsing Yes' "$CUPSD_CONF"; then
  echo 'Browsing Yes' >> "$CUPSD_CONF"
fi

if ! grep -q '^DefaultShared Yes' "$CUPSD_CONF"; then
  echo 'DefaultShared Yes' >> "$CUPSD_CONF"
fi

if ! grep -q '^WebInterface Yes' "$CUPSD_CONF"; then
  echo 'WebInterface Yes' >> "$CUPSD_CONF"
fi

if ! grep -q '<Location />' "$CUPSD_CONF"; then
  cat >> "$CUPSD_CONF" <<'CUPSLOC'
<Location />
  Order allow,deny
  Allow @LOCAL
</Location>

<Location /admin>
  Order allow,deny
  Allow @LOCAL
</Location>
CUPSLOC
fi

echo "[3/8] Opening firewall for IPP + mDNS..."
firewall-cmd --permanent --add-service=ipp || true
firewall-cmd --permanent --add-service=mdns || true
firewall-cmd --reload || true

echo "[4/8] Detecting USB printer URI..."
USB_URI="$(lpinfo -v | awk '/^direct usb:\/\/Brother\//{print $2; exit}')"
if [[ -z "$USB_URI" ]]; then
  echo "No Brother USB URI auto-detected. Available devices:"
  lpinfo -v
  echo "Connect the printer via USB and re-run this script."
  exit 1
fi

echo "Detected URI: $USB_URI"

echo "[5/8] Creating/updating CUPS queue..."
if lpstat -p "$PRINTER_NAME" >/dev/null 2>&1; then
  lpadmin -x "$PRINTER_NAME"
fi
lpadmin -p "$PRINTER_NAME" -E -v "$USB_URI" -m "$PPD_MODEL"
lpoptions -d "$PRINTER_NAME"

# Disable duplex (hardware lacks automatic duplex)
lpadmin -p "$PRINTER_NAME" -o sides=one-sided -o media=A4

# Enable sharing explicitly
lpadmin -p "$PRINTER_NAME" -o printer-is-shared=true

echo "[6/8] Restarting CUPS..."
systemctl restart cups.service

echo "[7/8] Printing a test page..."
lp -d "$PRINTER_NAME" /usr/share/cups/data/testprint || true

echo "[8/8] Final status"
lpstat -t

IP_ADDR="$(hostname -I | awk '{print $1}')"
cat <<MSG

Setup complete.

Android printing method (recommended):
1) Connect phone to same Wi-Fi as Raspberry Pi.
2) Ensure Mopria Print Service is enabled on Android.
3) Add/find printer: ipp://$IP_ADDR/printers/$PRINTER_NAME

Bluetooth note:
- Direct Android->CUPS Bluetooth printing is typically not supported on modern Android/CUPS stacks.
- Use Wi-Fi IPP/Mopria path above, or USB-OTG direct phone-to-printer where supported by phone/app.
MSG
