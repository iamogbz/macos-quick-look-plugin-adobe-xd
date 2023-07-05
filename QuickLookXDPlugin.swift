//
//  QuickLookXDPlugin.swift
//  QuickLookXD
//
//  Created by Ogbizi on 2023-07-02.
//
import QuickLook
import QuickLookUI
import QuickLookThumbnailing
import SSZipArchive

@available(macOS 12.0, *)
class QuickLookXDPlugin: NSViewController, QLPreviewingController {
    let imageFileNamePreview = "preview.png"
    let imageFileNameThumbnail = "thumbnail.png"

    override var nibName: NSNib.Name? {
        return NSNib.Name("QuickLookXDPlugin")
    }

    override func loadView() {
        super.loadView()
        // Do any additional setup after loading the view.
    }

    func extractImageOfFile(at url: URL, imageFileName: String, completionHandler handler: @escaping (String?, Error?) -> Void) {
        let xdFilePath = url.absoluteString

        if !url.isFileURL {
            let errorMsg = "Provided URL is not a file path: \(xdFilePath)"
            handler(nil, errorMsg as? Error)
        }

        let tempDirectory = NSTemporaryDirectory()

        NSLog("extract image of file: \(xdFilePath) -> \(tempDirectory)")

        SSZipArchive.unzipFile(atPath: xdFilePath, toDestination: tempDirectory)

        let imageFilePath = "\(tempDirectory)/\(imageFileName)"

        handler(imageFilePath, nil)
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        NSLog("prepare preview: \(url)")
        extractImageOfFile(at: url, imageFileName: self.imageFileNamePreview) { _, error in
           handler(error)
        }
    }

    /*
     Use a QLPreviewProvider to provide data-based previews.

     To set up your extension as a data-based preview extension:

     - Modify the extension's Info.plist by setting
       <key>QLIsDataBasedPreview</key>
       <true/>

     - Add the supported content types to QLSupportedContentTypes array in the extension's Info.plist.

     - Change the NSExtensionPrincipalClass to this class.
       e.g.
       <key>NSExtensionPrincipalClass</key>
       <string>${PRODUCT_BUNDLE_IDENTIFIER}.QuickLookXDPlugin</string>

     - Implement providePreview(for:)
     - Implement provideThumbnail(for:)
     */
    func providePreview(for request: QLFilePreviewRequest, completionHandler: @escaping (QLPreviewReply?, Error?) -> Void) {
        NSLog("provide preview: \(request.fileURL)")
        let imageFileName = self.imageFileNamePreview
        extractImageOfFile(at: request.fileURL, imageFileName: imageFileName) { imageFilePath, error in
            if (error != nil) {
                completionHandler(nil, error)
            } else if (imageFilePath == nil) {
                let errorMsg = "Failed to extract from XD file: \(imageFileName)"
                completionHandler(nil, errorMsg as? Error)
            } else {
                let reply = QLPreviewReply(fileURL: URL(string: imageFilePath!)!)
                completionHandler(reply, nil)
            }
        }
    }

    func provideThumbnail(for request: QLFileThumbnailRequest, completionHandler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        NSLog("provide thumbnail: \(request.fileURL)")
        let imageFileName = self.imageFileNameThumbnail
        extractImageOfFile(at: request.fileURL, imageFileName: imageFileName) { imageFilePath, error in
            if (error != nil) {
                completionHandler(nil, error)
            } else if (imageFilePath == nil) {
                let errorMsg = "Failed to extract from XD file: \(imageFileName)"
                completionHandler(nil, errorMsg as? Error)
            } else {
                let reply = QLThumbnailReply(imageFileURL: URL(string: imageFilePath!)!)
                completionHandler(reply, nil)
            }
        }
    }
}
