//
//  Document.m
//  QuickLookXD
//
//  Created by Ogbizi on 2023-07-06.
//

#include <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>
#include "SSZipArchive.h"
#include "Document.h"


CGImageRef GetImageFromDocument(NSURL* docURL, NSString *imageFileName, NSString *fallbackImageFileName) {
    // path to local XD file
    NSString *zipPath = docURL.path;
    // folder to unzip the file into
    NSString *zipFileName = [docURL.pathComponents lastObject];
    // full path to unzip location in the user tmp directory
    NSString *unzippedPath = [NSString stringWithFormat:@"%@/%@/", NSTemporaryDirectory(), zipFileName];
    // unzip the file and check for success
    BOOL success = [SSZipArchive unzipFileAtPath:zipPath toDestination:unzippedPath];
    if (!success) {
        NSLog(@"Failed to unzip the file at path: %@", zipPath);
    }
    
    NSString *imageFilePath = [unzippedPath stringByAppendingPathComponent:imageFileName];
    BOOL imageFileExists = [[NSFileManager defaultManager] fileExistsAtPath:imageFilePath];
    
    if (!imageFileExists) {
        NSLog(@"No image file found at: %@", imageFilePath);

        imageFilePath = [unzippedPath stringByAppendingPathComponent:fallbackImageFileName];
        imageFileExists = [[NSFileManager defaultManager] fileExistsAtPath:imageFilePath];
        
        if (!imageFileExists) {
            NSLog(@"No image file found at: %@", imageFilePath);
            return NULL;
        }
    }
    
    NSLog(@"Found image file at: %@", imageFilePath);
    
    CGDataProviderRef provider = CGDataProviderCreateWithFilename(imageFilePath.UTF8String);
    CGImageRef image = CGImageCreateWithPNGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
    return image;
}
