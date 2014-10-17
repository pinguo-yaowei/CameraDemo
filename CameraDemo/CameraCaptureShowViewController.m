//
//  CameraCaptureShowViewController.m
//  CameraDemo
//
//  Created by weirdln on 14-10-15.
//  Copyright (c) 2014年 weirdln. All rights reserved.
//

#import "CameraCaptureShowViewController.h"
#import "UIImageTools.h"
#import "WebPEncodeSeetingView.h"

@interface CameraCaptureShowViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    UIScrollView *scrollView;
    UIImageView *showImageView;
    UIImage *originImage;
    UILabel *imageInfoLable;
    
    UIActivityIndicatorView *activityView;
    
    WebPEncodeSeetingView *encodeSeetingView;
    
    UIImageAdditionInfo *imageAdditionInfo;
}

@end

@implementation CameraCaptureShowViewController
- (id)init
{
    self = [super init];
    if (self)
    {
        imageAdditionInfo = [[UIImageAdditionInfo alloc] init];

        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(btnAction:)];
        
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.delegate = self;
        scrollView.maximumZoomScale = 2.0;
        scrollView.minimumZoomScale = 1;
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:scrollView];
        
        showImageView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
        [self.view addSubview:showImageView];
        
        imageInfoLable = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight - 120, ScreenWidth, 120)];
        imageInfoLable.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        imageInfoLable.backgroundColor = [UIColor clearColor];
        imageInfoLable.textColor = [UIColor cyanColor];
        imageInfoLable.font = [UIFont systemFontOfSize:12];
        imageInfoLable.numberOfLines = 0;
//        [imageInfoLable sizeThatFits:CGSizeMake(ScreenWidth, NSIntegerMax)];
        [self.view addSubview:imageInfoLable];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 50, ScreenHeight - 180, 33, 33)];
        button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        button.tag = 1;
        [button setBackgroundImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        button = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 50, ScreenHeight - 130, 33, 33)];
        button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        button.tag = 2;
        [button setBackgroundImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        button = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 50, ScreenHeight - 80, 33, 33)];
        button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        button.tag = 3;
        [button setBackgroundImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        encodeSeetingView = [[WebPEncodeSeetingView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:encodeSeetingView];
        encodeSeetingView.hidden = YES;
        
        activityView = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
        activityView.center = self.view.center;
        [self.view addSubview:activityView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        tapGesture.delegate = self;
        [tapGesture addTarget:self action:@selector(tapGesture:)];
        [self.view addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
      return showImageView;
}

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.view == self.view)
    {
        self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view isKindOfClass:[UISlider class]] || [touch.view isKindOfClass:[UIActivityIndicatorView class]])
        return NO;
    
    if(touch.view == encodeSeetingView)
    {
        encodeSeetingView.hidden = YES;
        return NO;
    }
    
    return YES;
}

- (IBAction)btnAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 0:
        {
            encodeSeetingView.hidden = NO;
        }
            break;
        case 1:
        {
            [self setOriginImagePath:[[NSBundle mainBundle] pathForResource:@"png-1" ofType:@"png"]];
            
            WebPConfig config;
            config.lossless = encodeSeetingView.slider1.value;
            config.quality = encodeSeetingView.slider2.value;
            config.method = encodeSeetingView.slider3.value;
            [self startEncodeImage:originImage webPConfig:config];
            
            [activityView startAnimating];
            [activityView startAnimating];
            self.navigationController.navigationBarHidden = YES;
        }
            break;
        case 2:
        {
            [self setOriginImagePath:[[NSBundle mainBundle] pathForResource:@"jpg-1" ofType:@"jpg"]];
            
            WebPConfig config;
            config.lossless = encodeSeetingView.slider1.value;
            config.quality = encodeSeetingView.slider2.value;
            config.method = encodeSeetingView.slider3.value;
            [self startEncodeImage:originImage webPConfig:config];
            
            [activityView startAnimating];
            [activityView startAnimating];
            self.navigationController.navigationBarHidden = YES;
        }
            break;
        case 3:
        {
            WebPConfig config;
            config.lossless = encodeSeetingView.slider1.value;
            config.quality = encodeSeetingView.slider2.value;
            config.method = encodeSeetingView.slider3.value;
            [self startEncodeImage:originImage webPConfig:config];
            
            [activityView startAnimating];
            self.navigationController.navigationBarHidden = YES;
        }
            break;
        default:
            
            break;
    }
}


- (void)setOriginImage:(UIImage *)image
{
    
}

- (void)setOriginImagePath:(NSString *)imagePath
{
    [self finishSavePictureToPath:imagePath];
}

- (void)finishSavePictureToPath:(NSString *)filePath
{
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    originImage = [UIImage imageWithData:imageData];
    showImageView.image = originImage;
    scrollView.contentSize = [originImage size];
    
    originImage.additionInfo = imageAdditionInfo;
    originImage.additionInfo.fileSize = [imageData length] / 1024.0;
    originImage.additionInfo.jpegFileSize = [UIImageJPEGRepresentation(originImage, 1.0) length] / 1024.0;
    originImage.additionInfo.fileType = [filePath pathExtension];
    originImage.additionInfo.imageSize = originImage.size;
    
//    [self startEncodeImage:originImage];
}

- (void)startEncodeImage:(UIImage *)image webPConfig:(WebPConfig)config
{
    NSDate *beforeDate = [NSDate date];
    WebPPreset preset = (WebPPreset)encodeSeetingView.slider4.value;
    
    NSLog(@"begin convert image to webp! origin jpeg image size = %f kb。", image.additionInfo.jpegFileSize);
    [UIImage imageToWebP:image webPConfig:config alpha:1 preset:preset completionBlock:^(NSData *result) {
        
        image.additionInfo.encodeTime = [[NSDate date] timeIntervalSinceDate:beforeDate]*1000;
        image.additionInfo.webpFileSize = [result length] / 1024.0;
        
        NSLog(@"finish convert,webp file size = %f kb,it take time : %.0f ms",image.additionInfo.encodeTime,
              image.additionInfo.webpFileSize);
        
        
        NSString *filePath = [NSObject getDocumentsPath:@"test.webp"];
        if([result writeToFile:filePath atomically:YES])
        {
            [self decodeWebpImage:[NSObject getDocumentsPath:@"test.webp"]];
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)startEncodeImage:(UIImage *)image
{
    WebPConfig config;
    config.quality = 75;
    [self startEncodeImage:image webPConfig:config];
}

- (void)decodeWebpImage:(NSString *)filePath
{
    NSLog(@"begin  convert image from webp!");
    NSDate *beforeDate = [NSDate date];
    [UIImage imageFromWebP:filePath completionBlock:^(UIImage *result) {
        NSLog(@"image data size = %f",[UIImageJPEGRepresentation(result, 1.0) length] / 1024.0);
        
        result = [UIImage fixImageOrientation:UIImageOrientationRight withSouceImage:result];
        result.additionInfo = imageAdditionInfo;
        result.additionInfo.decodeTime = [[NSDate date] timeIntervalSinceDate:beforeDate]*1000;
        result.additionInfo.imageSize = result.size;

        NSLog(@"finish convert! it take time : %.0f ms",result.additionInfo.decodeTime);

        [self displayImage:result];
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)displayImage:(UIImage *)image
{
    imageInfoLable.text = [NSString stringWithFormat:@"%@",image.additionInfo];
//    [imageInfoLable sizeToFit];
    showImageView.image = image;
    scrollView.contentSize = image.size;
    
    [activityView stopAnimating];
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
