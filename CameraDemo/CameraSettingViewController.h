//
//  CameraSettingViewController.h
//  CameraDemo
//
//  Created by weirdln on 14-10-9.
//  Copyright (c) 2014年 weirdln. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraSettingViewController : UIViewController

/**
 *  设置当前设置状态，用于初始化现实
 *
 *  @param currentSetting 设置
 */
- (void)setupCurrentSetting:(NSDictionary *)currentSetting;

@end
