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

1. **Find device UUID** by name:
   ```bash
   xcrun devicectl list devices 2>/dev/null | grep -i <device_name>
   ```
   Extract the UUID from the output (format: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`).

2. **Build** using the device name:
   ```bash
   xcodebuild -project <project>.xcodeproj -scheme <scheme> \
     -destination 'platform=iOS,name=<device_name>' \
     -allowProvisioningUpdates build
   ```

3. **Install** using the device UUID and the built app path:
   ```bash
   xcrun devicectl device install app \
     --device <device_uuid> \
     <path/to/YourApp.app>
   ```

4. **Optionally launch** the app if the bundle ID is known:
   ```bash
   xcrun devicectl device process launch \
     --device <device_uuid> \
     <bundle_id>
   ```

## Known Devices

| Name | UUID |
|------|------|
| kio | 04832C21-3945-5E10-89A0-F246713D1C8E |

## Notes

- Build uses device **name**; install and launch use device **UUID**.
- The `.app` output path varies by project. Use the current DerivedData output or `xcodebuild -showBuildSettings` to locate it.
- If the app does not appear to update, manually kill and relaunch it on the device.
- If the bundle ID is unknown, skip the launch step or inspect build settings first.
