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
    return 1.f/denominator;
    
}

- (void)mightCrashTestWitha:(NSString *)a b:(NSString *)b{
    NSLog(@"mightCrashTest");
}

- (NSString *)mightCrashTest{
//    NSLog(@"mightCrashTestClass");
    NSString *str = @"abc";
    NSLog(@"Pstr:%p",str);
    return str;
}

- (void)mightCrashTestVoid{
    NSLog(@"mightCrashTestVoid");
}

- (void)mightCrashTestWithOneParam:(NSString *)a{
    NSLog(@"one param a is %@",a);
}

- (void)mightCrashTestWithTwoParams:(NSString *)a b:(NSString *)b{
    NSLog(@"two params a is %@\n b is %@",a,b);
}

- (instancetype)initWithName:(NSString *)name{
    if (self = [super init]) {
        NSLog(@"name is %@",name);
    }
    return self;
}


@end
