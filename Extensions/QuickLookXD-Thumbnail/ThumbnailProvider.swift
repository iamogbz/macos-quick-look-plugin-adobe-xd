//
// ThumbnailProvider.swift
// QuickLookXD-Thumbnail
//
// Thumbnail provider updated to use SSZipArchive to extract a candidate preview PNG from the .xd archive.
// This extracts the archive to a temporary directory and looks for common preview paths, then reads the image into memory.
// Using SSZipArchive requires linking the SSZipArchive library/framework into the extension target.
//

import QuickLookThumbnailing
import CoreGraphics
import AppKit
import SSZipArchive

class ThumbnailProvider: QLThumbnailProvider {
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        let size = request.maximumSize

        // Try to extract a preview image from the .xd file using SSZipArchive
        var previewImage: NSImage? = nil
        if let data = extractPreviewPNG(from: request.fileURL) {
            previewImage = NSImage(data: data)
        }

        let reply = QLThumbnailReply(contextSize: size, isBitmap: true) { (context) -> Bool in
            guard let cgContext = context else { return false }

            // Fill background
            cgContext.setFillColor(CGColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0))
            cgContext.fill(CGRect(origin: .zero, size: size))

            if let image = previewImage {
                // Draw extracted preview scaled to fit
                let imageRect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: size))
                image.draw(in: imageRect)
            } else {
                // Draw a simple centered filename placeholder
                let fileURL = request.fileURL.lastPathComponent as NSString
                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = .center

                let attrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: min(size.width, size.height) * 0.12),
                    .foregroundColor: NSColor.white,
                    .paragraphStyle: paragraph
                ]

                let textRect = CGRect(x: 8, y: (size.height - 40) / 2.0, width: size.width - 16, height: 40)
                fileURL.draw(in: textRect, withAttributes: attrs)
            }

            return true
        }

        handler(reply, nil)
    }

    // Use SSZipArchive to extract to a temporary directory and find a candidate preview image
    private func extractPreviewPNG(from url: URL) -> Data? {
        let candidatePaths = [
            "preview.png",
            "previews/preview.png",
            "images/preview.png",
            "resources/preview.png",
            "artwork/preview.png",
            "previews/thumbnail.png",
            "thumbnail.png"
        ]

        let fm = FileManager.default
        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)

        do {
            try fm.createDirectory(at: tmpDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }

        // Unzip into tmpDir
        let success = SSZipArchive.unzipFile(atPath: url.path, toDestination: tmpDir.path)
        if !success {
            try? fm.removeItem(at: tmpDir)
            return nil
        }

        for entry in candidatePaths {
            let candidateURL = tmpDir.appendingPathComponent(entry)
            if fm.fileExists(atPath: candidateURL.path) {
                if let data = try? Data(contentsOf: candidateURL) {
                    // cleanup
                    try? fm.removeItem(at: tmpDir)
                    // Quick PNG signature check
                    if data.count > 8 {
                        let pngSig: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
                        let header = [UInt8](data.prefix(8))
                        if header == pngSig {
                            return data
                        }
                    }
                }
            }
        }

        try? fm.removeItem(at: tmpDir)
        return nil
    }
}
