//
//  UIFont+CMCustom.m
//  CMCustomFont
//
//  Created by CMBaiDu on 15/8/26.
//  Copyright (c) 2015年 CMBaiDu. All rights reserved.
//

#import "UIFont+CMCustom.h"

@import CoreText;

@implementation UIFont (CMCustom)

+ (void)load
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[UIFont pacificoFontPath]])
    {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"Pacifico" ofType:@"ttf"];
        
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:[UIFont pacificoFontPath] error:&error];
        if (error)
        {
            NSLog(@"%s, Failed to copies Pacifico.ttf to sandbox", __FUNCTION__);
        }
    }
    
    [self registerPacificoFonts];
}

#define kCMRegisterFontsForURL 0
+ (void)registerPacificoFonts
{
    CFErrorRef error;
    
#if kCMRegisterFontsForURL
    NSURL *pacificoFontUrl = [NSURL fileURLWithPath:[UIFont pacificoFontPath]];
    if (!CTFontManagerRegisterFontsForURL((CFURLRef)pacificoFontUrl, kCTFontManagerScopeNone, &error))
    {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
#else
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[UIFont pacificoFontPath]];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGFontRef graphicsFont = CGFontCreateWithDataProvider(provider);
    
    if(!CTFontManagerRegisterGraphicsFont(graphicsFont, &error))
    {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    
    CFRelease(graphicsFont);
    CFRelease(provider);
#endif
}

+ (UIFont *)pacificoFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Pacifico" size:fontSize];
}

+ (UIFont *)windsongFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Windsong" size:fontSize];
}

+ (void)registerDynamicFontWithPostScript:(NSString *)fontName
                             withFontSize:(CGFloat)fontSize
                             withCallback:(void(^)(UIFont *font))callback
{
    if ([self isExistWithPostScript:fontName])
    {
        if (callback)
        {
            callback([UIFont fontWithName:fontName size:fontSize]);
        }
    }
    else
    {
        [self registerFontWithFontName:fontName withCallback:^(BOOL isSuccess) {
            
            if (callback)
            {
                UIFont *font = isSuccess ? [UIFont fontWithName:fontName size:fontSize] : nil;
                callback(font);
            }
        }];
    }
}

#pragma mark - Utility Methods
+ (NSString *)pacificoFontPath
{
    NSArray *caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *pacificoFontPath = [[caches firstObject] stringByAppendingPathComponent:@"Pacifico.ttf"];
    return pacificoFontPath;
}

+ (BOOL)isExistWithPostScript:(NSString *)fontName
{
    UIFont* aFont = [UIFont fontWithName:fontName size:12.];
    return aFont && ([aFont.fontName compare:fontName] == NSOrderedSame || [aFont.familyName compare:fontName] == NSOrderedSame);
}

/*!
 *    @brief 下载并注册字体
 *
 *    @desc  demo: https://developer.apple.com/library/ios/samplecode/DownloadFont/Introduction/Intro.html#//apple_ref/doc/uid/DTS40013404
 *
 *    @param fontName font's PostScript name
 */
+ (void)registerFontWithFontName:(NSString *)fontName
                    withCallback:(void(^)(BOOL isSuccess))callback
{
    // Create a dictionary with the font's PostScript name.
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:fontName, kCTFontNameAttribute, nil];
    
    // Create a new font descriptor reference from the attributes dictionary.
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attrs);
    
    NSMutableArray *descs = [NSMutableArray arrayWithCapacity:0];
    [descs addObject:(__bridge id)desc];
    CFRelease(desc);
    
    __block BOOL errorDuringDownload = NO;
    
    // Start processing the font descriptor..
    // This function returns immediately, but can potentially take long time to process.
    // The progress is notified via the callback block of CTFontDescriptorProgressHandler type.
    // See CTFontDescriptor.h for the list of progress states and keys for progressParameter dictionary.
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler( (__bridge CFArrayRef)descs, NULL,  ^(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
        
        if (state == kCTFontDescriptorMatchingDidBegin) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                
                NSLog(@"Begin Matching");
            });
        } else if (state == kCTFontDescriptorMatchingDidFinish) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                
                // Log the font URL in the console
                CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, 0., NULL);
                CFStringRef fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute);
                NSLog(@"%@", (__bridge NSString *)(fontURL));
                CFRelease(fontURL);
                CFRelease(fontRef);
                
                if (!errorDuringDownload) {
                    NSLog(@"%@ downloaded", fontName);
                }
                
                if (callback) {
                    callback(!errorDuringDownload);
                }
            });
        } else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                
                NSLog(@"Begin Downloading");
            });
        } else if (state == kCTFontDescriptorMatchingDidFinishDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                
                NSLog(@"Finish downloading");
            });
        } else if (state == kCTFontDescriptorMatchingDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                
                double progressValue = [[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingPercentage] doubleValue];
                NSLog(@"Downloading %.0f%% complete", progressValue);
            });
        } else if (state == kCTFontDescriptorMatchingDidFailWithError) {

            errorDuringDownload = YES;
            dispatch_async( dispatch_get_main_queue(), ^ {
                
                NSError *error = [(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingError];
                NSLog(@"Download error: %@", [error description]);
            });
        }
        
        return (bool)YES;
    });
}

@end
