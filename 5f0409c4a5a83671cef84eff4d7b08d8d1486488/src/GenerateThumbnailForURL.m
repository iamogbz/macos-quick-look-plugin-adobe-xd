#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Cocoa/Cocoa.h>
#include "Document.h"

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  
  CGImageRef image = GetImageFromDocument((NSURL *)url, IMAGE_THUMBNAIL_FILENAME, IMAGE_PREVIEW_FILENAME);
  
  if (!image) {
    [pool release];
    NSLog(@"Exiting because no image retrieved from document.");
    return noErr;
  }
  
  CGSize imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
  CGFloat scaleFactor = MIN(maxSize.width / imageSize.width, maxSize.height / imageSize.height);
  CGSize canvasSize = CGSizeMake(imageSize.width * scaleFactor, imageSize.height * scaleFactor);
  
  // Thumbnail will be drawn with maximum resolution for desired thumbnail request
  // Here we create a graphics context to draw the Quick Look Thumbnail in.
  CGContextRef cgContext = QLThumbnailRequestCreateContext(thumbnail, canvasSize, false, NULL);
  if(cgContext) {
    CGRect canvas = CGRectMake(0, 0, canvasSize.width, canvasSize.height);
    CGContextDrawImage(cgContext, canvas, image);
    
    // When we are done with our drawing code QLThumbnailRequestFlushContext() is called to flush the context
    QLThumbnailRequestFlushContext(thumbnail, cgContext);
    
    CFRelease(cgContext);
  }
  
  [pool release];
  return noErr;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
  // implement only if supported
}

