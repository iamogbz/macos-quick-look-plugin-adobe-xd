//
//  Document.h
//  QuickLookXD
//
//  Created by Ogbizi on 2023-07-06.
//

#ifndef Document_h
#define Document_h


#endif /* Document_h */

//  Constants
#define IMAGE_PREVIEW_FILENAME @"preview.png"
#define IMAGE_THUMBNAIL_FILENAME @"thumbnail.png"

/// Extract image from adobe xd document treating it as a zip file
/// - Parameters:
///   - docURL: url to XD file that can be unzipped
///   - imageFileName: relative path to image file to fetch from unzipped document e.g. "preview.png", "thumbnail.png"
///   - fallbackImageFileName: relative path to alternative image file if initial can not be read
CGImageRef GetImageFromDocument(NSURL* docURL, NSString *imageFileName, NSString *fallbackImageFileName);
