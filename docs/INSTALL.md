# Install Sector with a USB cable

## Before you start

The supplied `Sector.prg` is for **fēnix 9 Pro inReach, 51 mm AMOLED** (`fenix9pro51mm`) only. Other Garmin models need their own compiled and tested build. A USB charging cable must also support data transfer.

Download [`Sector.prg` for v1.1.8](https://github.com/loganthorneloe/sector-watchface/raw/refs/tags/v1.1.8/install/Sector.prg). Download the actual file, not a saved GitHub HTML page. If using the repository ZIP, the ready-to-install file is `install/Sector.prg`; do not copy the entire ZIP to the watch.

## 1. Connect and enable file transfer

Connect the watch directly to the computer. Allow the accessory if your computer asks. Select **MTP / File Transfer** on the watch if prompted. On the tested model the USB mode is under **Watch Settings → System → Advanced → USB Mode**; menu names can vary with firmware. Unlock the watch if it requests authentication for file access.

A charging/time screen alone does not confirm MTP is active. The computer must be able to browse the watch’s files.

## 2. Open the watch’s storage

### Windows

Open **File Explorer → This PC → your Garmin watch → Internal Storage** (names may vary). Open **GARMIN**, then **APPS**.

### macOS

Finder does not browse MTP devices. Use an MTP file-transfer client such as [OpenMTP](https://openmtp.ganeshrvel.com/), which lists Garmin support. Open the watch’s internal storage in the client and navigate to **GARMIN/APPS**. The included watch binary was verified using an MTP transfer; individual client/firmware combinations can vary.

Run only one application that accesses the watch over USB at a time. If another Garmin or MTP client holds the device, quit that client before refreshing the file listing. Installing Garmin Express is not required for this procedure.

### Linux

Use a file manager with MTP support, such as Files or Dolphin with your distribution’s MTP backend. Open the Garmin device, then its internal storage and **GARMIN/APPS**. If no MTP device appears, check your distribution’s device permissions and MTP support.

## 3. Copy and activate

Copy **`Sector.prg`** into the existing **`GARMIN/APPS`** directory. The resulting path is:

```text
GARMIN/APPS/Sector.prg
```

Do not put it in `NEWFILES`, a nested folder, or the storage root. Do not format the watch or delete other apps. Wait for copying to finish, eject/disconnect through your client if available, and unplug the cable. Open the watch’s watch-face picker and select **Sector**. Garmin may rename a sideloaded program after it imports it; that is normal.

## Updates and removal

Install a newer official release using the same copy procedure. If your client finds `Sector.prg` already present, replace that file only; keep a local copy of the previous release if you want a rollback. Keep the original filename when updating. Do not guess which unrelated numbered `.prg` files to delete.

To remove Sector, select another watch face and use the watch’s installed watch-face/app management controls to remove it when available. Menu wording varies by firmware. A fork built with a different application UUID is a separate installation.

## Troubleshooting

- **Charging but no files:** confirm a data-capable cable, an allowed USB accessory, the watch’s MTP mode, and any unlock prompt. Try a direct computer port and refresh the MTP client after the watch finishes connecting. Recheck whether the device is actually exposing storage before repeatedly reconnecting it.
- **Not visible in Finder:** use an MTP client on macOS; this is expected for MTP storage.
- **File copies but no Sector appears:** check the exact model, the file’s `.prg` extension, the folder, and that you disconnected before opening the face picker. Do not install the simulator test build.
- **`--` for a metric:** Garmin has not supplied a valid current value. Sync Garmin weather and allow the watch to collect sleep/body data. Sleep Score also needs compatible firmware/native complication support.
- **Blank while asleep:** intentional. Enable wrist-gesture wake in the watch’s display settings. Sector draws its red second hand only while awake.
- **Temperature units:** the prebuilt default is Fahrenheit. Building your own default is documented in [DEVELOPMENT.md](DEVELOPMENT.md); availability of app-settings editing for sideloaded apps varies.

## Optional download verification

Download [`SHA256SUMS` for the same version](https://github.com/loganthorneloe/sector-watchface/raw/refs/tags/v1.1.8/install/SHA256SUMS) and compare the checksum of `Sector.prg`:

```sh
# macOS
shasum -a 256 Sector.prg
# Linux
sha256sum Sector.prg
```

```powershell
# Windows PowerShell
Get-FileHash .\Sector.prg -Algorithm SHA256
```

Compare the displayed digest with `SHA256SUMS`. No Garmin account credentials or private signing keys are needed to copy the prebuilt file.
