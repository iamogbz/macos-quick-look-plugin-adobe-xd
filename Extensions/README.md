# QuickLook Extension skeletons

This directory contains skeleton Quick Look extensions (Thumbnail + Preview) in Swift.

What they do
- Provide placeholder UI for .xd files so you can test the extension loading flow and try to extract an embedded preview image called preview.png.
- For demo purposes the providers attempt to stream candidate preview image paths from the .xd using the system unzip tool. This is NOT production-ready.

Next steps to make them fully functional
1. Add both extension targets to the Xcode project or create an Xcode workspace with new targets.
2. Replace the unzip-based extraction with a proper zip library (ZIPFoundation or SSZipArchive). The repo already includes SSZipArchive in the project; adding a small Objective-C wrapper to call into it from Swift is a good option.
3. Implement rendering of the real preview assets (images, SVGs, or layer renders) instead of the placeholder HTML/drawing.
4. Ensure correct Info.plist/UTType declarations and entitlements if needed.
5. Codesign and notarize the app (or use a host app) before distributing on modern macOS releases.

Testing locally
- Add the extensions as targets in Xcode and run them from the host app target.
- Use `qlmanage -r` and `qlmanage -r cache` after installing to clear Quick Look caches.
- Use `qlmanage -d 4 -p /path/to/file.xd` to get debug output from Quick Look when testing.
