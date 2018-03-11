//
//  ViewController.m
//  BayMaxHotFix
//
//  Created by ccSunday on 2018/3/10.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "ViewController.h"
#import "MightyCrash.h"
#import "BayMaxHotFix.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    MightyCrash *crash = [[MightyCrash alloc]init];
    [crash divideUsingDenominator:0];
    
//    NSString *fixScriptString = @"\
//        runInstanceWithNoParamter(crash,'mightCrashTest');\
//    ";
//    [BayMaxHotFix evalString:fixScriptString];
//    [crash performSelector:NSSelectorFromString(@"fffd")];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
