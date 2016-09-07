//
//  ViewController.m
//  YCSwitch
//
//  Created by Durand on 26/8/16.
//  Copyright © 2016年 com.Durand. All rights reserved.
//

#import "ViewController.h"
#import "YCSwitch.h"

@interface ViewController ()
@property (nonatomic,strong) YCSwitch *ycSwitch;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _ycSwitch = [[YCSwitch alloc] initWithFrame:CGRectMake(100, 100, 90, 40) thumbSize:CGSizeMake(52, 34) trackThickHeight:26];
    [_ycSwitch setWillBePressedHandler:^(BOOL statusWillBe) {
        NSLog(@"willBeOn: %d",statusWillBe);
    }];
    [self.view addSubview:_ycSwitch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
