# QuickLook Extension skeletons

This directory contains skeleton Quick Look extensions (Thumbnail + Preview) in Swift.

What they do
- Provide placeholder UI for .xd files so you can test the extension loading flow and try to extract an embedded preview image called preview.png.
- The providers now attempt to extract a candidate preview image using SSZipArchive by unzipping the .xd to a temporary directory, then searching common preview paths. This requires linking SSZipArchive into the extension targets.

IMPORTANT: Using SSZipArchive is more robust than calling /usr/bin/unzip, but the extension target must link SSZipArchive (add it in the Xcode target's Link Binary With Libraries or use CocoaPods/SwiftPM as appropriate).

Next steps to make them fully functional
1. Add both extension targets to the Xcode project or create an Xcode workspace with new targets.
2. Ensure SSZipArchive is linked into both extension targets (the project references SSZipArchive already; add the framework/library to the new targets).
3. Replace the simple candidate-path lookup with full parsing of XD file structure (XD is a ZIP archive; identify the correct preview image assets or render layers directly).
4. Implement rendering of the real preview assets (images, SVGs, or layer renders) instead of the placeholder HTML/drawing.
5. Ensure correct Info.plist/UTType declarations and entitlements if needed.
6. Codesign and notarize the app (or use a host app) before distributing on modern macOS releases.

Testing locally
- Add the extensions as targets in Xcode and run them from the host app target.
- Ensure SSZipArchive is linked for the extension targets.
- Use `qlmanage -r` and `qlmanage -r cache` after installing to clear Quick Look caches.
- Use `qlmanage -d 4 -p /path/to/file.xd` to get debug output from Quick Look when testing.
