//
//  BayMaxHotFix.h
//  BayMaxHotFix
//
//  Created by ccSunday on 2018/3/10.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MightyCrash.h"

@interface BayMaxHotFix : NSObject

+ (void)fixIt;

+ (void)evalString:(NSString *)javascriptString;

@end
