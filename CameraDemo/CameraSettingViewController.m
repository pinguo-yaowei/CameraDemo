//
//  CameraSettingViewController.m
//  CameraDemo
//
//  Created by weirdln on 14-10-9.
//  Copyright (c) 2014年 weirdln. All rights reserved.
//

#import "CameraSettingViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CameraSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *settingTableView;
    NSDictionary *settingDict, *allSetOptions;
}

@end

@implementation CameraSettingViewController
- (id)init
{
    self = [super init];
    if (self)
    {
        allSetOptions = @{@(0) : @[AVCaptureSessionPresetPhoto,
                                   AVCaptureSessionPresetHigh,
                                   AVCaptureSessionPresetMedium,
                                   AVCaptureSessionPresetLow],
                          @(1) :  @[@(AVCaptureWhiteBalanceModeLocked),
                                    @(AVCaptureWhiteBalanceModeAutoWhiteBalance),
                                    @(AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance)]};
        
        settingDict = @{@(0) : [NSMutableDictionary dictionaryWithDictionary:
                                @{@"setName" : @"分辨率",
                                  @"setKey" : @"pixelType",
                                  @"currentIndex" : @(0),
                                  @"currentSetting" : AVCaptureSessionPresetPhoto}],
                        @(1) : [NSMutableDictionary dictionaryWithDictionary:
                                @{@"setName" : @"白平衡",
                                  @"setKey" : @"whiteBalanceMode",
                                  @"currentIndex" : @(0),
                                  @"currentSetting" : @(AVCaptureWhiteBalanceModeLocked)}]};
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(settingDone:)];
    
    settingTableView = [[UITableView alloc] initWithFrame:[self.view bounds]];
    settingTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    settingTableView.delegate = self;
    settingTableView.dataSource =self;
    [self.view addSubview:settingTableView];
}

- (void)setupCurrentSetting:(NSDictionary *)currentSetting
{
    [currentSetting enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"pixelType"])
        {
            [[settingDict objectForKey:@(0)] setObject:@([[allSetOptions objectForKey:@(0)] indexOfObject:obj]) forKey:@"currentIndex"];
            [[settingDict objectForKey:@(0)] setObject:obj forKey:@"currentSetting"];
        }
        else if ([key isEqualToString:@"whiteBalanceMode"])
        {
            [[settingDict objectForKey:@(1)] setObject:@([[allSetOptions objectForKey:@(1)] indexOfObject:obj]) forKey:@"currentIndex"];
            [[settingDict objectForKey:@(1)] setObject:obj forKey:@"currentSetting"];
        }
    }];
    
    [settingTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}


#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [settingDict count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary * dict = [settingDict objectForKey:@(indexPath.row)];
    id currentSetting = [dict objectForKey:@"currentSetting"];
    NSString *str = [currentSetting isKindOfClass:[NSString class]]?
                    currentSetting : [NSString stringWithFormat:@"%@",currentSetting];

    cell.textLabel.text = [dict objectForKey:@"setName"];
    cell.detailTextLabel.text = str;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * dict = [settingDict objectForKey:@(indexPath.row)];
    NSArray *allOptions = [allSetOptions objectForKey:@(indexPath.row)];
    
    NSInteger index = [[dict objectForKey:@"currentIndex"] integerValue];
    index ++;
    if(index >= [allOptions count]) index = 0;
    id Value = [allOptions objectAtIndex:index];
    
    [dict setObject:Value forKey:@"currentSetting"];
    [dict setObject:@(index) forKey:@"currentIndex"];
    
    [settingTableView reloadData];
}

// 完成按钮触发，给相机设置新的参数并回到相机界面
- (void)settingDone:(id)sender
{
    NSDictionary *setDoneDict =
    @{@"pixelType" : [[settingDict objectForKey:@(0)] objectForKey:@"currentSetting"],
      @"whiteBalanceMode" : [[settingDict objectForKey:@(1)] objectForKey:@"currentSetting"]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CameraSettingChanged" object:nil userInfo:setDoneDict];
    
    [self.navigationController popViewControllerAnimated:YES];
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
