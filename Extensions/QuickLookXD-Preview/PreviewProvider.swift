//
// PreviewProvider.swift
// QuickLookXD-Preview
//
// Skeleton for a QLPreviewProvider that tries to extract a preview PNG from the .xd archive and embed it in a simple HTML preview.
// Uses the system unzip tool for streaming a candidate preview image out of the .xd. Replace with ZIPFoundation/SSZipArchive for production.
//

import QuickLookPreviewing
import UniformTypeIdentifiers
import Foundation

class PreviewProvider: QLPreviewProvider {
    override func providePreview(for request: QLFilePreviewRequest, _ handler: @escaping (Error?) -> Void) {
        // Try to extract preview.png from the .xd
        var html: String
        if let data = extractPreviewPNG(from: request.fileURL) {
            let base64 = data.base64EncodedString()
            html = """
            <!doctype html>
            <html>
              <head>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width,initial-scale=1"/>
                <style>
                  body { font-family: -apple-system, system-ui, "Helvetica Neue"; color: #222; margin: 20px; }
                  .box { border: 1px solid #ddd; padding: 20px; border-radius: 8px; background: #fafafa; }
                  img { max-width: 100%; height: auto; display: block; margin: 0 auto; }
                </style>
              </head>
              <body>
                <div class="box">
                  <h1>Adobe XD preview</h1>
                  <p>Filename: \(request.fileURL.lastPathComponent)</p>
                  <img src="data:image/png;base64,\(base64)" alt="preview" />
                </div>
              </body>
            </html>
            """
        } else {
            html = """
            <!doctype html>
            <html>
              <head>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width,initial-scale=1"/>
                <style>
                  body { font-family: -apple-system, system-ui, "Helvetica Neue"; color: #222; margin: 20px; }
                  .box { border: 1px solid #ddd; padding: 20px; border-radius: 8px; background: #fafafa; }
                </style>
              </head>
              <body>
                <div class="box">
                  <h1>Adobe XD preview — skeleton</h1>
                  <p>Filename: \(request.fileURL.lastPathComponent)</p>
                  <p>No embedded preview image found in the .xd. Implement extraction of preview assets from the archive to render real previews.</p>
                </div>
              </body>
            </html>
            """
        }

        if let data = html.data(using: .utf8) {
            request.setDataRepresentation(data, contentType: UTType.html)
            handler(nil)
        } else {
            handler(NSError(domain: "QLPreview", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to produce HTML preview"]))
        }
    }

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
