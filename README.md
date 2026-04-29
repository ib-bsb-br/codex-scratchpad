# Tutorial: Set up a Brother HL-L1222-V on Raspberry Pi 4B+ (openSUSE Tumbleweed)

## Goal
Configure a **Brother HL-L1222-V** USB laser printer on a **Raspberry Pi 4B+** running **openSUSE Tumbleweed** with:
- Local printing from the Pi
- Optional network printer sharing (IPP)
- Validation, troubleshooting, and maintenance steps

---

## 1) What you need

### Hardware
- Raspberry Pi 4B+ (any RAM size)
- microSD / SSD with openSUSE Tumbleweed installed
- Stable power supply for Pi
- Brother HL-L1222-V
- USB 2.0 A-to-B cable (printer cable)

### Software assumptions
- openSUSE Tumbleweed (aarch64) updated
- sudo/root access
- Internet access to install packages

### Printer facts used in this setup
- Model family: HL-L1222-V
- Interface: USB 2.0 Full-Speed
- Print technology: monochrome laser
- No duplex unit (manual duplex only)

---

## 2) Update system and install print stack

> Run commands exactly as shown.

```bash
sudo zypper refresh 2>&1 | fold -w 1500
sudo zypper up -y 2>&1 | fold -w 1500
```

Install CUPS and common printing components:

```bash
sudo zypper install -y cups cups-filters ghostscript gutenprint avahi nss-mdns 2>&1 | fold -w 1500
```

Install tools you will use for diagnostics:

```bash
sudo zypper install -y usbutils system-config-printer 2>&1 | fold -w 1500
```

Enable and start services:

```bash
sudo systemctl enable --now cups.service 2>&1 | fold -w 1500
sudo systemctl enable --now avahi-daemon.service 2>&1 | fold -w 1500
```

Check service state:

```bash
systemctl status cups --no-pager 2>&1 | fold -w 1500
systemctl status avahi-daemon --no-pager 2>&1 | fold -w 1500
```

---

## 3) Connect printer and verify USB detection

1. Power on the printer.
2. Connect USB cable from Pi to HL-L1222-V.
3. Verify kernel sees it:

```bash
lsusb 2>&1 | fold -w 1500
```

Also check CUPS-visible devices:

```bash
lpinfo -v 2>&1 | fold -w 1500
```

You should see a `usb://Brother/...` style backend URI.

---

## 4) Choose driver strategy (recommended path first)

For this class of Brother mono laser device, the most reliable order is:

1. **Driverless / IPP Everywhere** (if exposed by firmware through USB or network)
2. **Generic PCL/BR-Script compatible PPD**
3. **Brother LPR + CUPS wrapper packages**

Because this model is USB-only in its base spec, many users will use either generic raster/PPD support or Brother’s Linux driver package.

### A) Try automatic setup with `lpadmin`

Find device URI and available models first:

```bash
lpinfo -v 2>&1 | fold -w 1500
lpinfo -m 2>&1 | fold -w 1500 > /tmp/cups-models.txt
rg -n "Brother|HL|laser|everywhere|drv:///sample.drv" /tmp/cups-models.txt 2>&1 | fold -w 1500
```

If `everywhere` works, add queue:

```bash
sudo lpadmin -p HLL1222V -E -v "usb://BROTHER/HL-L1222V?serial=REPLACE_ME" -m everywhere 2>&1 | fold -w 1500
```

If `everywhere` is not available, try a generic model from `lpinfo -m`:

```bash
sudo lpadmin -p HLL1222V -E -v "usb://BROTHER/HL-L1222V?serial=REPLACE_ME" -m drv:///sample.drv/generic.ppd 2>&1 | fold -w 1500
```

Set defaults:

```bash
sudo lpoptions -p HLL1222V -o media=A4 -o sides=one-sided 2>&1 | fold -w 1500
sudo lpadmin -d HLL1222V 2>&1 | fold -w 1500
```

> Replace the `-v` URI with the exact one shown by `lpinfo -v`.

### B) Brother official driver path (when generic path quality is poor)

1. Download ARM-compatible Brother Linux driver package for HL-L1222-V (LPR + CUPS wrapper) from Brother support.
2. Install dependencies if prompted.
3. Install `.rpm` packages with `zypper`:

```bash
sudo zypper install -y ./brother-*.rpm 2>&1 | fold -w 1500
```

4. Re-run queue creation with the PPD installed by Brother package:

```bash
lpinfo -m 2>&1 | fold -w 1500 > /tmp/cups-models-brother.txt
rg -n "Brother.*HL|hll1222|l1222" /tmp/cups-models-brother.txt 2>&1 | fold -w 1500
```

Then use the matching model string in `lpadmin -m ...`.

---

## 5) Print a test page

### From CUPS web UI
- Open: `http://localhost:631`
- Go to **Printers** → **HLL1222V** → **Maintenance** → **Print Test Page**

### From terminal
```bash
lpstat -t 2>&1 | fold -w 1500
lp -d HLL1222V /usr/share/cups/data/testprint 2>&1 | fold -w 1500
```

Check queue/jobs:

```bash
lpq -P HLL1222V 2>&1 | fold -w 1500
```

---

## 6) Optional: share printer over network (Pi as print server)

Enable CUPS sharing:

```bash
sudo cupsctl --share-printers --remote-any --remote-admin 2>&1 | fold -w 1500
```

Review `/etc/cups/cupsd.conf` and ensure your LAN can access it. Then restart:

```bash
sudo systemctl restart cups 2>&1 | fold -w 1500
```

Open firewall (example using firewalld):

```bash
sudo firewall-cmd --permanent --add-service=ipp 2>&1 | fold -w 1500
sudo firewall-cmd --permanent --add-service=mdns 2>&1 | fold -w 1500
sudo firewall-cmd --reload 2>&1 | fold -w 1500
```

Discover from other devices via mDNS/Bonjour (Avahi).

---

## 7) Quality and paper tuning

Set printer options (inspect available options first):

```bash
lpoptions -p HLL1222V -l 2>&1 | fold -w 1500
```

Common useful defaults:

```bash
sudo lpadmin -p HLL1222V -o Resolution=600dpi 2>&1 | fold -w 1500
sudo lpadmin -p HLL1222V -o PageSize=A4 2>&1 | fold -w 1500
sudo lpadmin -p HLL1222V -o InputSlot=Tray1 2>&1 | fold -w 1500
```

Manual duplex workflow (because hardware duplex is not supported):
1. Print odd pages only.
2. Reinsert stack according to exit orientation.
3. Print even pages in reverse order.

---

## 8) Consumables and lifecycle notes

From provided model sheet:
- Toner: **TN116** (standard yield, ~1,000 pages)
- Drum: **DR116** (~10,000 pages)
- Starter toner may differ from replacement yield

Operational guidance:
- Keep vents clear (laser heat)
- Use supported paper weights/media
- Avoid humid storage for paper
- Run periodic test page after long idle periods

---

## 9) Troubleshooting playbook

### Printer not detected on USB
```bash
dmesg | tail -n 120 2>&1 | fold -w 1500
lsusb 2>&1 | fold -w 1500
lpinfo -v 2>&1 | fold -w 1500
```
- Try a different USB cable/port.
- Power-cycle printer and Pi.
- Confirm `usblp` module if needed:

```bash
lsmod 2>&1 | fold -w 1500 | rg -n "usblp"
```

### Jobs stuck in queue
```bash
lpstat -t 2>&1 | fold -w 1500
journalctl -u cups -n 200 --no-pager 2>&1 | fold -w 1500
```
- Cancel and retry:

```bash
cancel -a HLL1222V 2>&1 | fold -w 1500
```

- Restart CUPS:

```bash
sudo systemctl restart cups 2>&1 | fold -w 1500
```

### Wrong paper size / clipped output
- Ensure app paper size = CUPS default (A4 vs Letter).
- Re-apply default:

```bash
sudo lpadmin -p HLL1222V -o PageSize=A4 2>&1 | fold -w 1500
```

### Low print quality / faint text
- Remove and gently redistribute toner.
- Verify print density/toner save options.
- Replace toner (TN116) then inspect drum (DR116) if issue persists.

---

## 10) Backup and restore printer configuration

Backup:

```bash
sudo tar -czf cups-backup-$(date +%F).tar.gz /etc/cups 2>&1 | fold -w 1500
```

Restore:

```bash
sudo tar -xzf cups-backup-YYYY-MM-DD.tar.gz -C / 2>&1 | fold -w 1500
sudo systemctl restart cups 2>&1 | fold -w 1500
```

---

## 11) Quick validation checklist

- [ ] `cups` and `avahi-daemon` are active
- [ ] `lpinfo -v` shows Brother USB URI
- [ ] Queue `HLL1222V` exists and is enabled
- [ ] Test page prints successfully
- [ ] Client discovery/printing works (if shared)
- [ ] Defaults set (A4, one-sided, desired resolution)

---

## 12) Minimal command bundle (copy/paste sequence)

```bash
sudo zypper refresh 2>&1 | fold -w 1500
sudo zypper install -y cups cups-filters ghostscript gutenprint avahi nss-mdns usbutils 2>&1 | fold -w 1500
sudo systemctl enable --now cups avahi-daemon 2>&1 | fold -w 1500
lpinfo -v 2>&1 | fold -w 1500
lpinfo -m 2>&1 | fold -w 1500 > /tmp/cups-models.txt
rg -n "Brother|HL|everywhere|generic" /tmp/cups-models.txt 2>&1 | fold -w 1500
# then create queue using your real URI:
# sudo lpadmin -p HLL1222V -E -v "usb://..." -m everywhere 2>&1 | fold -w 1500
sudo lpadmin -d HLL1222V 2>&1 | fold -w 1500
lp -d HLL1222V /usr/share/cups/data/testprint 2>&1 | fold -w 1500
lpstat -t 2>&1 | fold -w 1500
```

This completes a production-grade baseline setup for HL-L1222-V on Raspberry Pi 4B+ with openSUSE Tumbleweed.
