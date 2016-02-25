//
//  UIFont+CMCustom.h
//  CMCustomFont
//
//  Created by CMBaiDu on 15/8/26.
//  Copyright (c) 2015年 CMBaiDu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (CMCustom)

/*!
 *    @brief 通过网络下载或本地预置的字体文件设置自定义字体(pacifico)
 *
 *    @desc  需要CTFontManagerRegisterGraphicsFont/CTFontManagerRegisterFontsForURL向系统注册字体
 *
 *    @param fontSize 字体大小
 *
 *    @return 自定义字体pacificoFont
 */
+ (UIFont *)pacificoFontWithSize:(CGFloat)fontSize;

/*!
 *    @brief 通过设置plist自定义字体(windsongFont)
 *
 *    @desc  设置 UIAppFonts：[windsongFont]
 *
 *    @param fontSize 字体大小
 *
 *    @return 自定义字体windsongFont
 */
+ (UIFont *)windsongFontWithSize:(CGFloat)fontSize;

/*!
 *    @brief 通过font's PostScript name动态下载苹果提供的多种字体
 *
 *    @desc  字体列表 http://support.apple.com/kb/HT5484
 *
 *    @param fontSize 字体大小
 *
 *    @withCallback  回调返回请求的字体
 */
+ (void)registerDynamicFontWithPostScript:(NSString *)fontName
                             withFontSize:(CGFloat)fontSize
                             withCallback:(void(^)(UIFont *font))callback;

@end
