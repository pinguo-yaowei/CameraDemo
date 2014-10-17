//
//  UIImageTools.m
//  CameraDemo
//
//  Created by weirdln on 14-10-15.
//  Copyright (c) 2014年 weirdln. All rights reserved.
//

#import "UIImageTools.h"
#import <objc/runtime.h>

@implementation UIImageAdditionInfo

- (float)compressRate
{
    return self.webpFileSize / self.fileSize;
}

- (NSString *)description
{
    NSString *descriptionStr = [NSString stringWithFormat:
                                @"  文件格式：%@\n"
                                "   图片尺寸：%.0f * %.0f \n"
                                "   文件大小：%.0f kb\n"
                                "   jpeg文件大小：%.0f kb\n"
                                "   webp文件大小：%.0f kb\n"
                                "   压缩比：%.2f%%\n"
                                "   编码耗时：%.0f ms\n"
                                "   解码耗时：%.0f ms\n",
                                self.fileType,
                                self.imageSize.width,self.imageSize.height,
                                self.fileSize,
                                self.jpegFileSize,
                                self.webpFileSize,
                                self.compressRate * 100,
                                self.encodeTime,
                                self.decodeTime
                                ];
    return descriptionStr;
}


@end

@implementation UIImage (UIImageTools)
@dynamic additionInfo;

- (UIImageAdditionInfo *)additionInfo
{
    return objc_getAssociatedObject(self, @"additionInfo");
}

- (void)setAdditionInfo:(UIImageAdditionInfo *)additionInfo {
    objc_setAssociatedObject(self, @"additionInfo", additionInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)imageSize
{
//    uint64_t fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[UIImage getDocumentsPath:@"test"] error:nil] fileSize];
//    NSLog(@"file size = %f",fileSize / (1024 * 1024.0));
//    
//    NSData * fileImageData = [NSData dataWithContentsOfFile:[UIImage getDocumentsPath:@"test"]];
//    NSLog(@"file imageData size = %f",[fileImageData length] / (1024 * 1024.0));

    NSData *imageData = UIImageJPEGRepresentation(self, 1.0);

    return [imageData length] / (1024.0 * 1024.0);
}

- (float)bitmapSize
{
    int  perMBBytes = 1024*1024;
    
    CGImageRef cgimage = self.CGImage;
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;
    
    long lPixelsPerMB  = perMBBytes / bytes_per_pixel;
    
    long totalPixel = CGImageGetWidth(cgimage) * CGImageGetHeight(cgimage);
    
    float totalFileMB = totalPixel * 1.0 /lPixelsPerMB;
    
//    NSLog(@"Finish size:totalPixel = %ld ,totalFileMB = %f",totalPixel, totalFileMB);
    return totalFileMB;
}

+ (UIImage *)fixImageOrientation:(UIImageOrientation)imageOrientation withSouceImage:(UIImage *)srcImage
{
    CGImageRef imgRef = srcImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = 1;
    CGFloat boundHeight;
    UIImageOrientation orient = imageOrientation;
    switch (orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
           // PGAssert(NO, @"@Invalid image orientation");
            break;
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}

@end







#pragma mark - UILabel
@implementation UILabel  (Util)

+ (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
                  textColor:(UIColor *)textColor
                       font:(UIFont *)font
                  backColor:(UIColor*)backColor
              textAlignment:(NSTextAlignment)textAlignment
                    withTag:(int)tag
{
    __autoreleasing UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.tag = tag;
    label.text=text;
    label.textAlignment=textAlignment;
    if(backColor)
        label.backgroundColor=backColor;
    if(font)
        label.font=font;
    if(textColor)
        label.textColor=textColor;
    return label;
}

+ (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
              textAlignment:(NSTextAlignment)textAlignment
                    withTag:(int)tag
{
    return [[self class] labelWithFrame:frame text:text textColor:[UIColor greenColor] font:nil backColor:[UIColor clearColor] textAlignment:textAlignment withTag:tag];
}


@end




@implementation NSObject (Tools)

+ (NSString *)getDocumentsPath:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    return [docDir stringByAppendingPathComponent:fileName ? fileName: @""];
}


static  NSDateFormatter * formatter;
+ (NSString *)getTimeNow
{
    formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    
    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    NSLog(@"%@ \n %lld", timeNow,[timeNow longLongValue]);
    return timeNow;
}

+ (NSTimeInterval)getTimeGap:(NSDate *)endDate formDate:(NSDate *)startDate
{
    formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];

    NSTimeInterval time=[endDate timeIntervalSinceDate:startDate];

    return time;
}

@end
