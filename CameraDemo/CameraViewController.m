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
    cameraManager.cameraDelegate = self;
    [cameraManager setupPreView:self.view];
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

- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [cameraManager changePreviewOrientation:toInterfaceOrientation];
}


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
            [cameraManager switchFlashMode:flashIndex];

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
            CameraSettingViewController *settingViewController = [[CameraSettingViewController alloc] init];
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
    [cameraManager switchFocusMode:AVCaptureFocusModeAutoFocus
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
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
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
