//
//  MightyCrash.m
//  BayMaxHotFix
//
//  Created by ccSunday on 2018/3/10.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "MightyCrash.h"

@implementation MightyCrash
// 传一个 0 就 gg 了
- (float)divideUsingDenominator:(NSInteger)denominator
{
    [self performSelector:NSSelectorFromString(@"11")];
    return 1.f/denominator;
    
}

- (void)mightCrashTestWitha:(NSString *)a b:(NSString *)b{
    NSLog(@"mightCrashTest");
}

+ (void)mightCrashTest{
    NSLog(@"mightCrashTestClass");
}


@end
