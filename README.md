# Brother HL-L1222-V Android Print Server (Raspberry Pi 4B+ / openSUSE Tumbleweed)

This repository now provides an executable setup script that configures a Raspberry Pi 4B+ (openSUSE Tumbleweed) as a print server for a USB-connected Brother HL-L1222/HL-L1222-V.

## What this enables
- Android phones on the **same Wi-Fi network** can print through IPP (Mopria-compatible workflow).
- USB Brother printer is shared by CUPS over the local network.
- Firewall and discovery services are configured for LAN printing.

## Important Bluetooth note
Android-to-Raspberry-Pi Bluetooth printing into CUPS is generally not reliable/supported in modern Android/CUPS workflows. The script still enables Bluetooth service for optional experimentation, but the production path is **Wi-Fi IPP**.

## Script
- `scripts/setup_hl_l1222_android_print.sh`

## Run
```bash
sudo bash scripts/setup_hl_l1222_android_print.sh
```

## After script completes
1. Keep printer connected via USB to Raspberry Pi.
2. Connect Android phone to same Wi-Fi as Raspberry Pi.
3. Enable Mopria Print Service (or equivalent Android print service).
4. Add printer with:
   - `ipp://<raspberrypi-ip>/printers/Brother_HL_L1222_V`

## Notes
- Script uses CUPS `everywhere` model as default for broad compatibility.
- If you have an official Brother HL-L1222-V Linux PPD/driver package, install it and adjust queue model if desired.
