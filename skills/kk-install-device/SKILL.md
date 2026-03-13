---
name: kk:install-device
description: Use when building and installing an iOS app to a connected physical device, especially when the user says "install to <device>" or "安装到 <device>".
---

# Install to Physical Device

Build the current iOS app and install it to a connected physical device.

## Usage

User says: `install to kio` or `安装到 kio`

The argument is the device name (for example, `kio`).

## Workflow

1. **Resolve the device** via the local cache helper:
   ```bash
   device_info="$(bash skills/kk-install-device/scripts/resolve-device.sh <device_name>)"
   ```
   The helper returns `<display_name><TAB><device_uuid>`.
   It reads `~/.local/share/kk-install-device/devices.tsv` first and only refreshes that cache with `xcrun devicectl list devices` when the requested device is missing.
   Matching remains case-insensitive and supports unique substrings such as `kio`; if multiple cached devices match, use a more specific name.

2. **Extract the resolved values**:
   ```bash
   device_display_name="${device_info%%$'\t'*}"
   device_uuid="${device_info#*$'\t'}"
   ```

3. **Build** using the resolved device display name:
   ```bash
   xcodebuild -project <project>.xcodeproj -scheme <scheme> \
     -destination 'platform=iOS,name=<device_display_name>' \
     -allowProvisioningUpdates build
   ```

4. **Install** using the resolved device UUID and the built app path:
   ```bash
   xcrun devicectl device install app \
     --device <device_uuid> \
     <path/to/YourApp.app>
   ```

5. **Optionally launch** the app if the bundle ID is known:
   ```bash
   xcrun devicectl device process launch \
     --device <device_uuid> \
     <bundle_id>
   ```

## Notes

- Build uses the resolved device **display name**; install and launch use the resolved device **UUID**.
- Cache file: `~/.local/share/kk-install-device/devices.tsv`
- Refresh rule: only refresh on cache miss.
- To force a full rebuild of the local cache, delete `~/.local/share/kk-install-device/devices.tsv` and run the helper again.
- The `.app` output path varies by project. Use the current DerivedData output or `xcodebuild -showBuildSettings` to locate it.
- If the app does not appear to update, manually kill and relaunch it on the device.
- If the bundle ID is unknown, skip the launch step or inspect build settings first.
