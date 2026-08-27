# QuickLook Extension skeletons

This directory contains skeleton Quick Look extensions (Thumbnail + Preview) in Swift.

What they do
- Provide placeholder UI for .xd files so you can test the extension loading flow and try to extract an embedded preview image called preview.png.
- The providers now attempt to extract a candidate preview image using SSZipArchive by unzipping the .xd to a temporary directory, then searching common preview paths. This requires linking SSZipArchive into the extension targets.

Using CocoaPods (recommended)
1. Add the two extension targets to your Xcode project: "QuickLookXD-Thumbnail" and "QuickLookXD-Preview". When adding the targets, set their product type to Quick Look Thumbnail and Quick Look Preview extensions respectively (or create generic App Extension targets and set the NSExtension keys in Info.plist as provided).
2. Update the Podfile at the repository root (this repo already includes target blocks for both extension targets). If you didn't run `pod install` before, run it now after creating the targets.

   From the repository root:

   ```bash
   pod install
   open QuickLookXD.xcworkspace
   ```

3. Ensure each extension target links SSZipArchive. CocoaPods will add the Pods project and link the frameworks automatically for targets listed in the Podfile. If you add the targets after running `pod install`, re-run `pod install` so CocoaPods picks up the new targets.
4. Add the Swift files in Extensions/QuickLookXD-Thumbnail and Extensions/QuickLookXD-Preview to their respective target membership in Xcode (select file -> File Inspector -> Target Membership).
5. Add the provided Info.plist files in each extension target (or configure the target's Info.plist to point to those files).

Notes on wiring SSZipArchive
- The repository already lists SSZipArchive in Podfile/Podfile.lock. By including the extension targets in the Podfile and re-running `pod install`, the SSZipArchive framework will be linked into the extension targets automatically.
- If you prefer not to use CocoaPods for the extension targets, you can add SSZipArchive manually to each extension target via Link Binary With Libraries and copy the headers into a bridging header (Objective-C bridging header) that imports <SSZipArchive/SSZipArchive.h>.

Improved extraction behavior
- The providers now use SSZipArchive to unzip the .xd into a temporary directory and search a list of candidate paths (preview.png, previews/preview.png, thumbnail.png, etc.).
- This is an improvement over calling /usr/bin/unzip, but still not a fully robust solution: the canonical preview asset location depends on XD file internals. For a production implementation, examine the XD archive manifest and locate the highest-quality preview asset or render layers yourself.

Testing locally
- Add the extensions as targets in Xcode and run them from the host app target.
- Ensure SSZipArchive is linked for the extension targets (pod install should handle this).
- Use `qlmanage -r` and `qlmanage -r cache` after installing to clear Quick Look caches.
- Use `qlmanage -d 4 -p /path/to/file.xd` to get debug output from Quick Look when testing.

If you'd like, I can add an Xcode project file with the extension targets preconfigured and a Podfile workspace that runs `pod install` out-of-the-box (I can add that to this branch).