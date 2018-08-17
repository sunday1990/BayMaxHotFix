//
//  MightyCrash.h
//  BayMaxHotFix
//
//  Created by ccSunday on 2018/3/10.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MightyCrash : NSObject
- (float)divideUsingDenominator:(NSInteger)denominator;
- (NSString *)mightCrashTest;

- (void)mightCrashTestVoid;
- (void)mightCrashTestWithOneParam:(NSString *)a;
- (void)mightCrashTestWithTwoParams:(NSString *)a b:(NSString *)b;
- (instancetype)initWithName:(NSString *)name;
@end
