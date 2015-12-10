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

+ (NSString *)pacificoFontPath
{
    NSArray *caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *pacificoFontPath = [[caches firstObject] stringByAppendingPathComponent:@"Pacifico.ttf"];
    return pacificoFontPath;
}

@end
