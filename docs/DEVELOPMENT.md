# Build, customize, and fork

## Tools

Install Garmin’s [Connect IQ SDK Manager and SDK](https://developer.garmin.com/connect-iq/sdk/) from Garmin. Use SDK Manager to install the target device definition. Garmin may require sign-in for SDK/device downloads; this is separate from publishing to the Connect IQ Store. The tested build uses SDK 9.2.0 and Java 17.

The helper script uses Bash, Java, and OpenSSL (macOS/Linux, or a compatible shell on Windows). Native Windows users can also build with Garmin’s VS Code Monkey C extension using the same manifest and jungle files.

## Clone and build

```sh
git clone https://github.com/loganthorneloe/sector-watchface.git
cd sector-watchface
export CIQ_SDK="/path/to/your/connect-iq-sdk"
# Optional if java is not on PATH:
export CIQ_JAVA="/path/to/java"
./scripts/build.sh fenix9pro51mm release
```

The result is `build/Sector-fenix9pro51mm-release.prg`. Rename a copy to `Sector.prg` and follow [INSTALL.md](INSTALL.md) for your own build.

The script creates a new private signing key at `.private/developer_key.der` if none exists. That directory and key extensions are ignored by Git. Keep your key private, back it up securely, and reuse it for your own updates. Set `CIQ_KEY` to use an existing key. The original publisher’s private key is intentionally absent.

## Independent forks

Fork on GitHub and clone your fork. Before distributing an independent version, change the `<iq:application id="...">` value in `manifest.xml` to a new 32-character UUID without hyphens, for example generated with:

```sh
python3 -c 'import uuid; print(uuid.uuid4().hex)'
```

Rename the app in `resources/strings/strings.xml` as appropriate. A different UUID lets your version coexist with Sector and avoids update/signing conflicts. Do not expect a build signed with your own key to replace the official binary seamlessly.

## Customize

- `source/SectorView.mc`: layout, hand shapes, tick marks, fonts, and health-gauge colors.
- `source/SectorMath.mc`: formatting, clamped progress, temperature and UV color ramps.
- `source/SectorData.mc`: Garmin data sources, validation, and caching.
- `resources/settings/properties.xml`: default temperature units (`1` Fahrenheit, `2` Celsius, `0` watch preference).
- `resources/settings/settings.xml`: optional app settings UI.

The temperature gradient samples actual Celsius values between the daily low and high. The white marker uses `(current − low) / (high − low)`, clamped to 0–1. Missing values or invalid ranges use a neutral track. UV uses a fixed 0–11 scale; its numeric readout can exceed 11.

## Other watches

Only `fenix9pro51mm` is declared and tested. To port Sector, install your target’s SDK definition, add its product ID to `manifest.xml`, then build for that ID. Layout coordinates scale to screen size, but this does not guarantee readability or API support. Check display type, resolution, fonts, memory, power behavior, and complication availability. The all-black low-power behavior was designed for AMOLED; MIP displays may need different handling. Sleep Score needs API 6.0.2 and native support. Test both the simulator and the actual watch before claiming compatibility.

## Simulator and tests

```sh
./scripts/build.sh fenix9pro51mm test
# Start Garmin's Connect IQ simulator, then use its SDK launcher:
"$CIQ_SDK/bin/monkeydo" build/Sector-fenix9pro51mm-test.prg fenix9pro51mm -t

./scripts/build.sh fenix9pro51mm release
"$CIQ_SDK/bin/monkeydo" build/Sector-fenix9pro51mm-release.prg fenix9pro51mm
```

Launcher syntax and extensions can differ on Windows. Never install the test build as the daily face. Check high-power, low-power/off, and missing-data states, and inspect long/short text values. The six tests cover progress/units/formatting, score-history validity, and color boundaries. Release screenshots should use simulator data.

## Publishing a release

Use a release build, update `manifest.xml`, copy the intended binary to `install/Sector.prg`, and regenerate `install/SHA256SUMS`. Verify the staged files before pushing; never add `.private/`, device backups, credentials, local SDKs, or debug artifacts. Attach `Sector.prg` and `SHA256SUMS` to the matching GitHub release. Keep the MIT license with redistributed source.
