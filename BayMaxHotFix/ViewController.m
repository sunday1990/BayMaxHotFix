//
//  ViewController.m
//  BayMaxHotFix
//
//  Created by ccSunday on 2018/3/10.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "ViewController.h"
#import "MightyCrash.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    MightyCrash *crash = [[MightyCrash alloc]init];
    [crash divideUsingDenominator:0];
//    [SVProgressHUD showSuccessWithStatus:@"方法添加成功"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self haha];
}

- (void)haha{
    NSLog(@"haha，点击了屏幕");
}


@end
