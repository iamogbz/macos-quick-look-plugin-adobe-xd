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

/// Get preview or thumbnail image from adobe xd file
CGImageRef GetImageFromDocument(NSURL* docURL, NSString *imageFileName, NSString *fallbackImageFileName);
