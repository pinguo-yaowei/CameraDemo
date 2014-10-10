//
//  CameraManager.h
//  CameraDemo
//
//  Created by weirdln on 14-10-7.
//  Copyright (c) 2014年 weirdln. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CameraManagerDelegate;
@interface CameraManager : NSObject

/**
 *  相机相关操作代理
 */
@property (weak, nonatomic) id <CameraManagerDelegate> cameraDelegate;

/**
 *  用于保存相机的设置，修改时进行更新
 */
@property (strong, nonatomic) NSMutableDictionary *cameraSetting;

/**
 *  相机开始运行
 */
- (void)startCamera;

/**
 *  相机停止
 */
- (void)endCamera;

/**
 *  设置摄像头的预览界面
 *
 *  @param view 需要将layer加载的view
 */
- (void)setupPreView:(UIView *)view;

/**
 *  改变屏幕方向
 *
 *  @param interfaceOrientation 新的方向
 */
- (void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation;

/**
 *  拍照操作
 */
- (void)capturePicture;

/**
 *  切换前后摄像头（如果可用）
 */
- (void)switchCamera;

/**
 *  切换闪光灯模式
 *
 *  @param newMode 新的模式
 */
- (void)switchFlashMode:(AVCaptureFlashMode)newMode;

/**
 *  设置相机的聚焦方式和曝光方式
 *
 *  @param focusMode  聚焦方式
 *  @param exposeMode 曝光方式
 *  @param focusPoint 需要的点
 */
- (void)switchFocusMode:(AVCaptureFocusMode)focusMode
             exposeMode:(AVCaptureExposureMode)exposeMode
                atPoint:(CGPoint)point;

@end



@protocol CameraManagerDelegate <NSObject>

/**
 *  完成拍照后的回调
 *
 *  @param image 拍照获取到的图片
 */
- (void)finishCapturePicture:(UIImage *)image;

@end
