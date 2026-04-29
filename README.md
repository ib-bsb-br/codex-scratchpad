# iPhone Tutorial: Using the Raspberry Pi + openSUSE CUPS Brother HL-L1222 Print Server

## Goal
Use an iPhone on the same Wi-Fi network to print through your Raspberry Pi 4B+ openSUSE CUPS server connected by USB to a Brother HL-L1222/HL-L1222-V.

This tutorial assumes your setup script has already run successfully and created:
- CUPS queue: `impressora_brother`
- Optional upload web service: `hll1222-upload` on port `8088`
- Optional hotfolder watcher: `hll1222-hotfolder`

---

## 1) Understand what works from iPhone

### Primary iPhone path (recommended)
- **AirPrint/IPP over Wi-Fi** through CUPS shared printer.
- This is the native iOS experience from apps like Files, Safari, Photos, Mail, Notes, etc.

### Secondary iPhone path (fallback)
- **Web upload page** at `http://<pi-ip>:8088/` (if upload service enabled).
- Upload supported files; the Pi watcher prints them automatically.

### Important limitation
- Your Brother model is USB/non-wireless. iPhone never talks to the printer directly.
- iPhone talks to the **Pi print server**, and the Pi sends jobs to USB printer.

---

## 2) Verify server readiness on Raspberry Pi first
Run these checks on the Pi before testing iPhone:

```bash
systemctl status cups --no-pager
systemctl status avahi-daemon --no-pager
systemctl status firewalld --no-pager
lpstat -t
```

If you enabled upload mode:

```bash
systemctl status hll1222-upload --no-pager
systemctl status hll1222-hotfolder --no-pager
```

Check LAN IP:

```bash
hostname -I | awk '{print $1}'
```

Expected: keep this IP for iPhone tests (example `192.168.1.50`).

---

## 3) Confirm CUPS queue and sharing state

Use:

```bash
lpstat -p impressora_brother -l
lpoptions -p impressora_brother -l
```

Confirm queue is enabled/shared. If uncertain, enforce:

```bash
sudo lpadmin -p impressora_brother -o printer-is-shared=true
sudo cupsctl --share-printers --remote-any
sudo systemctl restart cups
```

---

## 4) iPhone method A: Native Print (AirPrint/IPP discovery)

1. Connect iPhone to the **same SSID/Wi-Fi** as the Raspberry Pi.
2. Open a printable item (e.g., PDF in Files, webpage in Safari, photo in Photos).
3. Tap **Share** → **Print**.
4. Tap **Printer** and wait for discovery.
5. Select printer queue shown by CUPS (commonly `impressora_brother` or host-derived name).
6. Set copies/page range/media options and tap **Print**.

### If printer does not appear
- Wait 10–20 seconds in the printer picker.
- Ensure no client isolation on Wi-Fi router.
- Re-check Pi services and firewall.
- Retry after toggling iPhone Wi-Fi off/on.

---

## 5) iPhone method B: Browser upload page fallback

If AirPrint discovery fails or the app cannot print directly:

1. On iPhone Safari, open:
   - `http://<pi-ip>:8088/`
2. Choose file to upload (PDF/TXT/JPG/PNG/TIFF).
3. Submit upload.
4. File lands in hotfolder and is auto-printed by watcher.

### Useful examples
- `http://192.168.1.50:8088/`

### File behavior
- Allowed extensions: `.pdf`, `.txt`, `.png`, `.jpg`, `.jpeg`, `.tif`, `.tiff`
- Oversized uploads are rejected by configured max bytes.

---

## 6) Validate job pipeline end-to-end

After sending from iPhone, inspect queue/jobs on Pi:

```bash
lpstat -t
journalctl -u cups -n 100 --no-pager
```

For upload route:

```bash
journalctl -u hll1222-upload -n 100 --no-pager
journalctl -u hll1222-hotfolder -n 100 --no-pager
ls -la /var/spool/hll1222-hotfolder
```

What success looks like:
- Job appears in CUPS queue then completes.
- Uploaded file is consumed by watcher and removed/processed.
- Physical printer starts within seconds.

---

## 7) iPhone-specific troubleshooting matrix

### Symptom: “No AirPrint Printers Found”
Check:
- Same Wi-Fi network/subnet
- `avahi-daemon` running
- Firewall has `ipp` and `mdns`

Commands:

```bash
sudo firewall-cmd --list-services
systemctl is-active avahi-daemon
systemctl is-active cups
```

Expected services include `ipp` and `mdns`.

---

### Symptom: iPhone sees printer but print fails immediately
Check:

```bash
lpstat -t
journalctl -u cups -n 200 --no-pager
```

Likely causes:
- Driver/model mismatch
- USB URI changed after reconnect/reboot

Recovery:
- Re-run your setup script with explicit URI/model if needed.

---

### Symptom: Upload page opens, but upload fails
Check upload services:

```bash
systemctl status hll1222-upload --no-pager
journalctl -u hll1222-upload -n 200 --no-pager
python3 -c 'import multipart; print("ok")'
```

If `multipart` import fails, install dependency and restart service:

```bash
sudo zypper --non-interactive install --no-recommends python3-python-multipart
sudo systemctl restart hll1222-upload
```

---

### Symptom: Upload accepted, nothing prints
Check watcher:

```bash
systemctl status hll1222-hotfolder --no-pager
journalctl -u hll1222-hotfolder -n 200 --no-pager
```

Manual test:

```bash
echo 'test from pi' | lp -d impressora_brother
```

If manual CUPS print works, issue is watcher path/permissions/file type.

---

## 8) Router and network conditions that matter

For iPhone discovery/printing reliability:
- Disable AP/client isolation on guest Wi-Fi.
- Keep Pi and iPhone in same VLAN/subnet.
- Avoid VPN on iPhone during test.
- Ensure multicast/mDNS isn’t blocked.

---

## 9) Operational best practices

- Keep a static DHCP lease for Raspberry Pi IP.
- Keep queue name stable (`impressora_brother`).
- Prefer PDF for predictable rendering.
- Do periodic status checks after updates:

```bash
systemctl status cups avahi-daemon firewalld --no-pager
lpstat -t
```

---

## 10) Quick runbook (short version)

1. iPhone and Pi on same Wi-Fi.
2. Print from iPhone Share → Print.
3. If printer not found, use Safari upload fallback `http://<pi-ip>:8088/`.
4. If failure persists, check:

```bash
systemctl status cups avahi-daemon hll1222-upload hll1222-hotfolder --no-pager
lpstat -t
journalctl -u cups -n 100 --no-pager
```

---

## 11) Security note

Your script currently uses permissive hotfolder permissions (`0777`) to maximize compatibility for upload + watcher workflows. This is practical in trusted home LAN setups, but you should avoid exposing port `8088` beyond local network.

If you later want a hardened variant (group-based ACL instead of `0777`), create a dedicated service user/group and restrict write access to that principal only.
