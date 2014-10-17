//
//  CameraViewController.m
//  CameraDemo
//
//  Created by weirdln on 14-10-7.
//  Copyright (c) 2014年 weirdln. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraManager.h"
#import "CameraSettingViewController.h"
#import "CameraCaptureShowViewController.h"

@interface CameraViewController ()<CameraManagerDelegate>
{
    CameraManager *cameraManager;
    NSDictionary       *flashSetting;
}

@property (weak,nonatomic) IBOutlet UIButton *flashBtn,*switchBtn,*captureBtn,*settingBtn;
@property (weak,nonatomic) IBOutlet UIImageView *preImageView;

- (IBAction)btnAction:(UIButton *)sender;

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;


@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    flashSetting = @{@(0) : @"flash-off.png",
                     @(1) : @"flash-on.png",
                     @(2) : @"flash-auto.png",};
    self.view.autoresizesSubviews = YES;
    
//    UIButton *flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 20, 25)];
//    flashBtn.tag = 0;
//    //    flashBtn.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.height/2 - 80);
//    [flashBtn setBackgroundImage:[UIImage imageNamed:@"flash-off.png"] forState:UIControlStateNormal];
//    [flashBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:flashBtn];
//    
//    UIButton *switchBtn = [[UIButton alloc] initWithFrame:CGRectMake(260, 20, 40, 20)];
//    switchBtn.tag = 1;
////    switchBtn.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.height/2 - 80);
//    [switchBtn setBackgroundImage:[UIImage imageNamed:@"front-camera.png"] forState:UIControlStateNormal];
//    [switchBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:switchBtn];
//    
//    UIButton *captureBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
//    captureBtn.tag = 2;
//    captureBtn.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.height/2 - 80);
//    [captureBtn setBackgroundImage:[UIImage imageNamed:@"btn_cam_pressed.png"] forState:UIControlStateNormal];
//    [captureBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:captureBtn];
//    
//    UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
//    settingBtn.tag = 3;
////    settingBtn.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.height/2 - 80);
//    [settingBtn setBackgroundImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
//    [settingBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:settingBtn];
    
    
    cameraManager = [[CameraManager alloc] init];
    [cameraManager switchCamera];
    cameraManager.cameraDelegate = self;
    [cameraManager setupPreView:self.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [cameraManager startCamera];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    [cameraManager endCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- rotate相关
- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    [cameraManager changePreviewOrientation:toInterfaceOrientation];
//}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [cameraManager changePreviewOrientation:[self interfaceOrientation]];
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    [cameraManager changePreviewOrientation:[self interfaceOrientation]];
//}


- (IBAction)btnAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 0:
        {
            static NSInteger flashIndex = 0;

            flashIndex ++;
            if(flashIndex >= 3)
                flashIndex = 0;
            UIImage *newImage = [UIImage imageNamed:[flashSetting objectForKey:@(flashIndex)]];
            [sender setBackgroundImage:newImage forState:UIControlStateNormal];
            [cameraManager setupFlashMode:flashIndex];

        }
            break;
        case 1:
        {
            [cameraManager switchCamera];
        }
            break;
        case 2:
        {
            [cameraManager capturePicture];
        }
            break;
        case 3:
        {
            NSDictionary *currentDict = [cameraManager cameraSetting];
            CameraSettingViewController *settingViewController = [[CameraSettingViewController alloc] init];
            [settingViewController setupCurrentSetting:currentDict];
            [self.navigationController pushViewController:settingViewController animated:YES];
        }
            break;
        default:
            break;
    }
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    [cameraManager setupFocusMode:AVCaptureFocusModeAutoFocus
                       exposeMode:AVCaptureExposureModeAutoExpose
                          atPoint:touchPoint];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([[touch.view class] isSubclassOfClass:[UIButton class]])
        return NO;
    return YES;
}



// 完成拍照的处理
- (void)finishCapturePicture:(UIImage *)image
{
//    [self displayImage:image];
//    return;
//    image = [UIImage imageNamed:@"btn_cam_pressed"];
    NSDate *beforeDate = [NSDate date];
    
//    NSLog(@"%@ \t %.0f",[UIImage getTimeNow],[[NSDate date] timeIntervalSince1970]*1000);
    NSLog(@"origin jpeg image size = %lf Mb。",[UIImageJPEGRepresentation(image, 1.0) length] / (1024.0 * 1024.0));

    
    NSLog(@"begin  convert image to webp!");
    [UIImage imageToWebP:image quality:0 alpha:1 preset:WEBP_PRESET_DEFAULT completionBlock:^(NSData *result) {
        NSLog(@"finish convert,image size = %f Mb",[result length] / (1024 * 1024.0));
        NSLog(@"it take time : %.0f ms",[[NSDate date] timeIntervalSinceDate:beforeDate]*1000);
        
        NSString *filePath = [NSObject getDocumentsPath:@"test.webp"];
        if([result writeToFile:filePath atomically:YES])
        {
            [self finishSavePictureToPath:filePath];
        }
    }
            failureBlock:^(NSError *error)
     {
         
     }];
}

- (void)finishSavePictureToPath:(NSString *)filePath
{
    CameraCaptureShowViewController *showViewController = [[CameraCaptureShowViewController alloc] init];
    [self.navigationController pushViewController:showViewController animated:YES];
    [showViewController setOriginImagePath:filePath];
}

- (void)displayImage:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSLog(@"finish image data size = %f",[imageData length] / (1024 * 1024.0));
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.preImageView.frame = CGRectMake(0, screenSize.width - 100, 120, 100);
    }
    else
    {
        self.preImageView.frame = CGRectMake(0, screenSize.height - 120, 100, 120);
    }
    self.preImageView.image = image;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
