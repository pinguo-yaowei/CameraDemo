//
//  UIImageTools.h
//  CameraDemo
//
//  Created by weirdln on 14-10-15.
//  Copyright (c) 2014年 weirdln. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+WebP.h"

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width


@interface UIImageAdditionInfo : NSObject

@property (nonatomic,strong) NSString *fileType;
@property (nonatomic) float fileSize;
@property (nonatomic) float jpegFileSize;
@property (nonatomic) float webpFileSize;
@property (nonatomic) float compressRate;
@property (nonatomic) float encodeTime;
@property (nonatomic) float decodeTime;
@property (nonatomic) CGSize imageSize;


@end

@interface UIImage (UIImageTools)

@property (nonatomic,strong)UIImageAdditionInfo *additionInfo;

- (float)imageSize;

+ (UIImage *)fixImageOrientation:(UIImageOrientation)imageOrientation withSouceImage:(UIImage *)srcImage;


@end











#pragma mark - UILabel
@interface UILabel (Util)

+ (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
                  textColor:(UIColor *)textColor
                       font:(UIFont *)font
                  backColor:(UIColor*)backColor
              textAlignment:(NSTextAlignment)textAlignment
                    withTag:(int)tag;

+ (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
              textAlignment:(NSTextAlignment)textAlignment
                    withTag:(int)tag;

@end




@interface NSObject (Tools)

+ (NSString *)getDocumentsPath:(NSString *)fileName;

+ (NSString *)getTimeNow;

+ (NSTimeInterval)getTimeGap:(NSDate *)endDate formDate:(NSDate *)startDate;

@end