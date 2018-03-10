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
- (void)mightCrashTestWitha:(NSString *)a b:(NSString *)b;
+ (void)mightCrashTest;

@end
