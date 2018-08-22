//
//  ZGPatchEngine.h
//  BayMaxHotFix
//
//  Created by zhugefang on 2018/8/17.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface ZGPatchEngine : NSObject
+ (void)startEngine;
+ (JSValue *)evaluateScript:(NSString *)script;

@end
