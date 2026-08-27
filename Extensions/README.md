# QuickLook Extension skeletons

This directory contains skeleton Quick Look extensions (Thumbnail + Preview) in Swift.

What they do
- Provide placeholder UI for .xd files so you can test the extension loading flow and try to extract an embedded preview image called preview.png.
- The providers use SSZipArchive to unzip the .xd to a temporary directory, then search common preview paths. This requires linking SSZipArchive into the extension targets.

What I changed for you (branch: swift-quicklook-extension-skeleton)
- Added Swift providers that use SSZipArchive:
  - Extensions/QuickLookXD-Thumbnail/ThumbnailProvider.swift
  - Extensions/QuickLookXD-Preview/PreviewProvider.swift
- Added Info.plist files for both extensions in Extensions/
- Added Extensions/Bridging-Header.h (imports SSZipArchive for Swift use)
- Updated Podfile to include the two extension targets so CocoaPods can link SSZipArchive into them
- Added helper script to test Quick Look via qlmanage (scripts/ql_test.sh)

Goal
Make the repository ready for local testing and verification without requiring an Apple Developer certificate; the only manual steps left are adding the extension targets in Xcode (UI steps) and running `pod install` locally to wire SSZipArchive into those targets. After that you can run and test locally and sign the app for distribution when ready.

Step-by-step instructions to finish the build and test locally

Prerequisites
- Xcode (matching your macOS version)
- CocoaPods (the repo already uses CocoaPods) — install if you don't have it: `sudo gem install cocoapods` or use Homebrew

1) Create the extension targets in Xcode (manual steps — no certificate needed)
- Open the project in Xcode (do NOT open the workspace yet):
  - open QuickLookXD.xcodeproj
- For each extension create a new target:
  - File > New > Target...
  - Select "macOS" > "App Extension" > "Quick Look Preview" (or a generic App Extension and then set the NSExtension keys in Info.plist as provided). Name it `QuickLookXD-Preview`.
  - Repeat and create a "Quick Look Thumbnail" extension target named `QuickLookXD-Thumbnail` (or App Extension if no template).

2) Point each extension target to the provided Info.plist
- Select the new target in Xcode > Build Settings > Packaging > Info.plist File and set it to the path in the repo, for example:
  - `Extensions/QuickLookXD-Preview/Info.plist`
  - `Extensions/QuickLookXD-Thumbnail/Info.plist`

3) Add the Swift source files to each target membership
- In the Project navigator, add (or drag) these files into the project if they aren't already visible:
  - `Extensions/QuickLookXD-Preview/PreviewProvider.swift`
  - `Extensions/QuickLookXD-Thumbnail/ThumbnailProvider.swift`
- Select each file, open the File Inspector and check the Target Membership box for the appropriate extension target.

4) Add the Objective-C Bridging Header for the extension targets
- There is a bridging header at `Extensions/Bridging-Header.h` that imports SSZipArchive. Set this bridging header path in each extension target:
  - Select the extension target > Build Settings > Swift Compiler - General > Objective-C Bridging Header
  - Set the path (relative to your project file), e.g.: `Extensions/Bridging-Header.h`

5) Wire SSZipArchive into the extension targets via CocoaPods
- The Podfile in the branch already includes the two extension targets. From the repository root run:

```bash
pod install
open QuickLookXD.xcworkspace
```

- If you created the extension targets after initially running `pod install`, re-run `pod install` so CocoaPods picks up the new targets. CocoaPods will create an Xcode workspace and link SSZipArchive for the specified targets.

6) Verify project settings
- Open the workspace produced by CocoaPods: `open QuickLookXD.xcworkspace`
- Confirm that the Pods project contains frameworks for `SSZipArchive` and that each extension target has the Pods product in "Link Binary With Libraries".
- Ensure the product module name matches `$(PRODUCT_MODULE_NAME)` expected by the Info.plist NSExtensionPrincipalClass (`$(PRODUCT_MODULE_NAME).ThumbnailProvider` / `$(PRODUCT_MODULE_NAME).PreviewProvider`). Usually the default module name is the target name.

7) Build and run (local testing without certificate)
- Select a host app to run. Quick Look extensions are app extensions — you can either create a minimal host app or set the extension to run with a host app target. If you don't have a host app, create a simple macOS app target in the project and add the two extensions as embedded app extensions.
- Build the workspace (`Cmd-B`). You do not need a distribution certificate to build locally; Xcode will sign with a development identity (or a generic identity) for running on your machine.

8) Test Quick Look with qlmanage
- Install or run the host app so the extensions are available. Then run these commands to clear Quick Look caches and preview a sample file:

```bash
qlmanage -r
qlmanage -r cache
qlmanage -d 4 -p /path/to/sample.xd
```

- Alternatively use the helper script in the repo:
  - `bash scripts/ql_test.sh /path/to/sample.xd`

9) Logs & debugging
- Use the Console app to watch QuickLookUIService logs or run:

```bash
log stream --predicate 'process contains "QuickLook" OR process contains "QuickLookUIService"' --style syslog
```

10) Signing for distribution (what needs a certificate)
- To distribute or install the app/extension system-wide you must sign and notarize with an Apple Developer certificate (Developer ID). Those steps must be performed on a machine with your Apple Developer credentials and provisioning profiles; see the section below for exact commands to run locally.

Local commands you will run when ready to sign/notarize

- Verify codesign:
  codesign --verify --deep --strict --verbose=4 /path/to/YourApp.app
- Gatekeeper test:
  spctl -a -v --type exec /path/to/YourApp.app
- Notarize (example, requires Apple ID / app-specific password):
  xcrun altool --notarize-app -f YourApp.zip --primary-bundle-id com.qbrkts.quicklookxd -u "apple@you.com" -p "APP-SPECIFIC-PASSWORD"

What I did NOT change (requires local decisions or certificates)
- I did not add code signing identities or provisioning profiles to the Xcode project (you must configure these locally).
- I did not notarize any build artifacts.

Files added in this follow-up commit
- Extensions/Bridging-Header.h  (imports SSZipArchive for Swift usage)
- scripts/ql_test.sh            (helper script to clear caches and run qlmanage)
- Extensions/README.md          (this expanded instructions file)

If you want I can continue and:
- Optionally modify the Xcode project file (project.pbxproj) directly in this branch so the new targets are preconfigured. I avoided making direct pbxproj edits here because manual verification in Xcode is easier and safer.
- Add a minimal host app target to the project and wire both extensions into it so the workspace builds out-of-the-box (I can do that if you prefer — confirm and I’ll update the project file in the branch).

If you'd like me to proceed to update the project.pbxproj to add the targets automatically, reply and I will make that change in the branch. Otherwise, follow the steps above locally and let me know any build errors you hit — I’ll iterate quickly to fix them.
