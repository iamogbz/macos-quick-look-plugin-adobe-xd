//
// ThumbnailProvider.swift
// QuickLookXD-Thumbnail
//
// Skeleton for a QLThumbnailProvider that attempts to extract a preview PNG from the .xd (zip) and draw it.
// For local testing this uses the system unzip tool to stream a candidate PNG out of the archive.
// Replace the extraction logic with a library (ZIPFoundation / SSZipArchive) for production use.
//

import QuickLookThumbnailing
import CoreGraphics
import AppKit

class ThumbnailProvider: QLThumbnailProvider {
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        let size = request.maximumSize

        // Try to extract a preview image from the .xd file
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
                let rep = image.bestRepresentation(for: CGRect(origin: .zero, size: size), context: nil, hints: nil)
                let imageRect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: size))
                #if os(macOS)
                image.draw(in: imageRect)
                #else
                // Fallback drawing path
                #endif
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

    // Simple helper that attempts to stream common preview image paths from the .xd archive using the system unzip tool.
    // This is intended for a skeleton/demo only. Use a proper zip library for robust extraction in production.
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

        for entry in candidatePaths {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
            process.arguments = ["-p", url.path, entry]

            let outPipe = Pipe()
            process.standardOutput = outPipe
            process.standardError = Pipe()

            do {
                try process.run()
            } catch {
                continue
            }
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                let data = outPipe.fileHandleForReading.readDataToEndOfFile()
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

        return nil
    }
}
