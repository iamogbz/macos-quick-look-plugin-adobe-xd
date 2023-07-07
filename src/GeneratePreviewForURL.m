#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Cocoa/Cocoa.h>
#include "Document.h"


/* -----------------------------------------------------------------------------
 Generate a preview for file
 
 This function's job is to create preview for designated file
 ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  
  CGImageRef image = GetImageFromDocument((NSURL *)url, IMAGE_PREVIEW_FILENAME, IMAGE_THUMBNAIL_FILENAME);
  
  if (!image) {
    [pool release];
    NSLog(@"Exiting because no image retrieved from document.");
    return noErr;
  }
  
  CGSize imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
  
  // Preview will be drawn in a vectorized context
  // Here we create a graphics context to draw the Quick Look Preview in
  CGContextRef cgContext = QLPreviewRequestCreateContext(preview, imageSize, false, NULL);
  if(cgContext) {
    CGRect canvas = CGRectMake(0, 0, imageSize.width, imageSize.height);
    CGContextDrawImage(cgContext, canvas, image);
    
    // When we are done with our drawing code QLPreviewRequestFlushContext() is called to flush the context
    QLPreviewRequestFlushContext(preview, cgContext);
    
    CFRelease(cgContext);
  }
  
  [pool release];
  return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
  // implement only if supported
}
