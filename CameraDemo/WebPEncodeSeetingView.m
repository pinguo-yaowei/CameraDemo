//
//  WebPEncodeSeetingView.m
//  CameraDemo
//
//  Created by weirdln on 14-10-16.
//  Copyright (c) 2014年 weirdln. All rights reserved.
//

#import "WebPEncodeSeetingView.h"
#import "UIImageTools.h"

@implementation WebPEncodeSeetingView
@synthesize slider1 = slider1;
@synthesize slider2 = slider2;
@synthesize slider3 = slider3;
@synthesize slider4 = slider4;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        float width = frame.size.width;
        
        [self addSubview:[UILabel labelWithFrame:CGRectMake(width - 200, 80, 80, 25) text:@"lossless"
                                   textAlignment:NSTextAlignmentRight withTag:0]];
        [self addSubview:[UILabel labelWithFrame:CGRectMake(width - 40, 80, 40, 25) text:@"1"
                                   textAlignment:NSTextAlignmentLeft withTag:1]];
        
        slider1 = [[UISlider alloc] initWithFrame:CGRectMake(width - 120, 80, 80, 25)];
        slider1.tag = 1;
        slider1.minimumValue = 0;
        slider1.maximumValue = 1;
        slider1.value = 1;
        [slider1 addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider1];
        
        [self addSubview:[UILabel labelWithFrame:CGRectMake(width - 200, 130, 80, 25) text:@"quality"
                                   textAlignment:NSTextAlignmentRight withTag:0]];
        [self addSubview:[UILabel labelWithFrame:CGRectMake(width - 40, 130, 40, 25) text:@"75"
                                   textAlignment:NSTextAlignmentLeft withTag:2]];
        slider2 = [[UISlider alloc] initWithFrame:CGRectMake(width - 120, 130, 80, 25)];
        slider2.tag = 2;
        slider2.minimumValue = 0;
        slider2.maximumValue = 100;
        slider2.value = 75;
        [slider2 addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider2];
        
        [self addSubview:[UILabel labelWithFrame:CGRectMake(width - 200, 180, 80, 25) text:@"method"
                                   textAlignment:NSTextAlignmentRight withTag:0]];
        [self addSubview:[UILabel labelWithFrame:CGRectMake(width - 40, 180, 40, 25) text:@"0"
                                   textAlignment:NSTextAlignmentLeft withTag:3]];
        slider3 = [[UISlider alloc] initWithFrame:CGRectMake(width - 120, 180, 80, 25)];
        slider3.tag = 3;
        slider3.minimumValue = 0;
        slider3.maximumValue = 6;
        [slider3 addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider3];
        
        [self addSubview:[UILabel labelWithFrame:CGRectMake(width - 200, 230, 80, 25) text:@"preset"
                                   textAlignment:NSTextAlignmentRight withTag:0]];
        [self addSubview:[UILabel labelWithFrame:CGRectMake(width - 40, 230, 40, 25) text:@"0"
                                   textAlignment:NSTextAlignmentLeft withTag:4]];
        slider4 = [[UISlider alloc] initWithFrame:CGRectMake(width - 120, 230, 80, 25)];
        slider4.tag = 4;
        slider4.minimumValue = 0;
        slider4.maximumValue = 5;
        [slider4 addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider4];
    }
    return self;
}


- (IBAction)updateValue:(UISlider *)sender
{
    int selectedValue = (int)sender.value; //读取滑块的值
    sender.value = selectedValue;

    [((UILabel *)[self viewWithTag:sender.tag]) setText:[NSString stringWithFormat:@"%d",selectedValue]];
}


@end
