//
//  CameraManager.m
//  CameraDemo
//
//  Created by weirdln on 14-10-7.
//  Copyright (c) 2014年 weirdln. All rights reserved.
//

#import "CameraManager.h"
#import <ImageIO/ImageIO.h>

@interface CameraManager ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession      *session;
    AVCaptureDevice       *device;
    AVCaptureDeviceInput  *deviceInput;
    AVCaptureVideoPreviewLayer *preview;
    AVCaptureStillImageOutput   *captureOutput;
    AVCaptureVideoDataOutput *videoOutput;
}
@end

@implementation CameraManager

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setupCaptureSession];
        
        [self setupImageOutput];
    }
    return self;
}

- (void)dealloc
{
    [device removeObserver:self forKeyPath:@"adjustingFocus"];
}

#pragma mark -- setup

// 设置session和输入
- (void)setupCaptureSession
{
    NSError *error = nil;
    
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 监听自动对焦
    [device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
    
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if ([session canAddInput:deviceInput])
    {
        [session addInput:deviceInput];
    }
}

//对焦回调
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"adjustingFocus"] )
    {
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        NSLog(@"Is adjusting focus? %@", adjustingFocus ? @"YES" : @"NO");
        NSLog(@"Change dictionary: %@", change);

    }
}

// 设置图像输出
- (void)setupImageOutput
{
    captureOutput = [[AVCaptureStillImageOutput alloc] init];
    [captureOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
    if ([session canAddOutput:captureOutput])
    {
        [session addOutput:captureOutput];
    }
}

// 设置视频输出
- (void)setupVideoOutput
{
    // 视频输出
    session.sessionPreset = AVCaptureSessionPresetMedium;
    videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    if ([session canAddOutput:videoOutput])
    {
        [session addOutput:videoOutput];
        
        // Configure your output.
        dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
        [videoOutput setSampleBufferDelegate:self queue:queue];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000 // 6.0sdk之前
        dispatch_release(queue);
#endif
        // Specify the pixel format
        videoOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    }
}

// 设置相机预览显示View
- (void)setupPreView:(UIView *)view
{
    if (!session || !view)
        return;
    
    preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preview.frame = view.bounds;
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    [view.layer addSublayer:preview];
    [view.layer insertSublayer:preview below:[[view.layer sublayers] objectAtIndex:0]];
}

- (void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"%@",NSStringFromCGRect(preview.frame));
    if (preview)
    {
        [[preview connection] setVideoOrientation:(AVCaptureVideoOrientation)interfaceOrientation];
    }
}



#pragma mark -- output
// 拍照片
- (void)capturePicture
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //get UIImage
    [captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                               completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error)
    {
         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments) {
             // Do something with the attachments.
         }
         
         // Continue as appropriate.
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *t_image = [UIImage imageWithData:imageData];
         
         UIImage *image = [[UIImage alloc]initWithCGImage:t_image.CGImage scale:1.0
                                              orientation:(UIImageOrientation)preview.connection.videoOrientation];
         
         if ([self.cameraDelegate respondsToSelector:@selector(finishCapturePicture:)])
             [self.cameraDelegate finishCapturePicture:image];
     }];
}



// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    

    NSLog(@"image data is %@",image);
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace)
    {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
    
    // Get the base address of the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize,
                                                              NULL);
    // Create a bitmap image from data supplied by our data provider
    CGImageRef cgImage =
    CGImageCreate(width,
                  height,
                  8,
                  32,
                  bytesPerRow,
                  colorSpace,
                  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  provider,
                  NULL,
                  true,
                  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    // Create and return an image object representing the specified Quartz image
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

#pragma mark -- control

- (void)startCamera
{
    [session startRunning];
}

- (void)endCamera
{
    [session stopRunning];
}

// 切换摄像头
- (void)switchCamera
{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount <= 1)
        return;
    
    NSError *error = nil;
    AVCaptureDevicePosition position = [deviceInput.device position];

    AVCaptureDevice *newInputDevice = position == AVCaptureDevicePositionFront ? [self backCamera] : [self frontCamera];
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newInputDevice error:&error];
    
    if (newVideoInput != nil)
    {
        [session beginConfiguration];
        [session removeInput:deviceInput];
        
        if ([session canAddInput:newVideoInput])
        {
            [session addInput:newVideoInput];
            deviceInput = newVideoInput;
            device = deviceInput.device;
        }
        else
        {
            [session addInput:deviceInput];
        }
        [session commitConfiguration];
    }
    else if (error)
    {
        NSLog(@"toggle carema failed, error = %@", error);
    }
    
}

- (AVCaptureDevice *)getCamereWithPosition:(AVCaptureDevicePosition )position
{
    for (AVCaptureDevice *dev in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo])
    {
        if ([dev position] == position)
            return dev;
    }
    return nil;
}

- (AVCaptureDevice *)frontCamera {
    return [self getCamereWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self getCamereWithPosition:AVCaptureDevicePositionBack];
}

// 切换闪光灯
- (void)switchFlashMode:(AVCaptureFlashMode)newMode
{
    if ([device hasFlash] && [device isFlashModeSupported:newMode])
    {
        [device lockForConfiguration:nil];
        device.flashMode = newMode;
        //    [device setTorchMode:AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
}

// 设置相机的聚焦方式和曝光方式
- (void)switchFocusMode:(AVCaptureFocusMode)focusMode
             exposeMode:(AVCaptureExposureMode)exposeMode
                atPoint:(CGPoint)point;
{
    NSError *error = nil;
    if ([device lockForConfiguration:&error])
    {
        if ([device isFocusModeSupported:focusMode] && [device isFocusPointOfInterestSupported])
        {
            [device setFocusMode:focusMode];
            [device setFocusPointOfInterest:point];
        }
        
        if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposeMode])
        {
            [device setExposureMode:exposeMode];
            [device setExposurePointOfInterest:point];
        }
        
        [device unlockForConfiguration];
    }
}




@end
