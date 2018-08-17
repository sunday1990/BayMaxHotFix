//
//  BayMaxHotFix.m
//  BayMaxHotFix
//
//  Created by ccSunday on 2018/3/10.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BayMaxHotFix.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "VKMsgSend.h"
#import "Aspects.h"

@implementation BayMaxHotFix

static NSDictionary *_wrapObj(id obj) {
    return @{@"__obj": obj};
}

void (*action)(id, SEL,...) = (void (*)(id, SEL, ...))objc_msgSend;

static id formatJSToOC(JSValue *jsval)
{
    id obj = [jsval toObject];
    //    if (!obj || [obj isKindOfClass:[NSNull class]]) return _nilObj;
    //
    //    if ([obj isKindOfClass:[JPBoxing class]]) return [obj unbox];
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < [(NSArray*)obj count]; i ++) {
            [newArr addObject:formatJSToOC(jsval[i])];
        }
        return newArr;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        if (obj[@"__obj"]) {
            id ocObj = [obj objectForKey:@"__obj"];
            //            if ([ocObj isKindOfClass:[JPBoxing class]]) return [ocObj unbox];
            return ocObj;
        } else if (obj[@"__clsName"]) {
            return NSClassFromString(obj[@"__clsName"]);
        }
        //        if (obj[@"__isBlock"]) {
        //            Class JPBlockClass = NSClassFromString(@"JPBlock");
        //            if (JPBlockClass && ![jsval[@"blockObj"] isUndefined]) {
        //                return [JPBlockClass performSelector:@selector(blockWithBlockObj:) withObject:[jsval[@"blockObj"] toObject]];
        //            } else {
        //                return genCallbackBlock(jsval);
        //            }
        //        }
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        for (NSString *key in [obj allKeys]) {
            [newDict setObject:formatJSToOC(jsval[key]) forKey:key];
        }
        return newDict;
    }
    return obj;
}

+ (BayMaxHotFix *)sharedInstance
{
    static BayMaxHotFix *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)evalString:(NSString *)javascriptString
{
    [[self context] evaluateScript:javascriptString];
}

+ (JSContext *)context
{
    static JSContext *_context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _context = [[JSContext alloc] init];
        //设置异常
        [_context setExceptionHandler:^(JSContext *context, JSValue *value) {
            NSLog(@"Oops: %@", value);
        }];
    });
    return _context;
}


//所有修复的方法最终会调用这里，行为为前、后、替换
+ (void)_fixWithMethod:(BOOL)isClassMethod aspectionOptions:(AspectOptions)option instanceName:(NSString *)instanceName selectorName:(NSString *)selectorName fixImpl:(JSValue *)fixImpl {
    Class klass = NSClassFromString(instanceName);
    if (isClassMethod) {
        klass = object_getClass(klass);
    }
    SEL sel = NSSelectorFromString(selectorName);
    [klass aspect_hookSelector:sel withOptions:option usingBlock:^(id<AspectInfo> aspectInfo){
        //将instance、实例和原始的invocation传递出去，在外界进行处理
        [fixImpl callWithArguments:@[aspectInfo.instance, aspectInfo.originalInvocation, aspectInfo.arguments]];
    } error:nil];
}

+ (id)_runClassWithClassName:(NSString *)className selector:(NSString *)selector obj1:(id)obj1 obj2:(id)obj2 {
    Class klass = NSClassFromString(className);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [klass performSelector:NSSelectorFromString(selector) withObject:obj1 withObject:obj2];
#pragma clang diagnostic pop
}

+ (id)_runInstanceWithInstance:(id)instance selector:(NSString *)selector obj1:(id)obj1 obj2:(id)obj2 {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [instance performSelector:NSSelectorFromString(selector) withObject:obj1 withObject:obj2];
#pragma clang diagnostic pop
}

+ (id)_createInstanceWithClassName:(NSString *)className selector:(NSString *)selector param:(id)param{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    Class kclass = NSClassFromString(className);
    id kInstance = [kclass alloc];
    return  [kInstance performSelector:NSSelectorFromString(selector) withObject:param];
#pragma clang diagnostic pop

}

+ (void)fixIt
{
    /**类方法、实例方法替换*/
    [self context][@"fixInstanceMethodBefore"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:NO aspectionOptions:AspectPositionBefore instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    [self context][@"fixInstanceMethodReplace"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:NO aspectionOptions:AspectPositionInstead instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    [self context][@"fixInstanceMethodAfter"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:NO aspectionOptions:AspectPositionAfter instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    [self context][@"fixClassMethodBefore"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:YES aspectionOptions:AspectPositionBefore instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    [self context][@"fixClassMethodReplace"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:YES aspectionOptions:AspectPositionInstead instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    [self context][@"fixClassMethodAfter"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:YES aspectionOptions:AspectPositionAfter instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    /**类方法调用（无参、1参、2参）*（有返回值，无返回值）*/
    [self context][@"runClassWithNoParamter"] = ^id(NSString *className, NSString *selectorName) {
        return [self _runClassWithClassName:className selector:selectorName obj1:nil obj2:nil];
    };
    
    [self context][@"runClassWith1Paramter"] = ^id(NSString *className, NSString *selectorName, id obj1) {
        return [self _runClassWithClassName:className selector:selectorName obj1:obj1 obj2:nil];
    };
    
    [self context][@"runClassWith2Paramters"] = ^id(NSString *className, NSString *selectorName, id obj1, id obj2) {
        return [self _runClassWithClassName:className selector:selectorName obj1:obj1 obj2:obj2];
    };
    
    [self context][@"runVoidClassWithNoParamter"] = ^(NSString *className, NSString *selectorName) {
        [self _runClassWithClassName:className selector:selectorName obj1:nil obj2:nil];
    };
    
    [self context][@"runVoidClassWith1Paramter"] = ^(NSString *className, NSString *selectorName, id obj1) {
        [self _runClassWithClassName:className selector:selectorName obj1:obj1 obj2:nil];
    };
    
    [self context][@"runVoidClassWith2Paramters"] = ^(NSString *className, NSString *selectorName, id obj1, id obj2) {
        [self _runClassWithClassName:className selector:selectorName obj1:obj1 obj2:obj2];
    };
    
    /**实例方法调用（实例、1参、2参）*（有返回值，无返回值）*/
    [self context][@"runInstanceWithNoParamter"] = ^id(id instance, NSString *selectorName) {
        return [self _runInstanceWithInstance:instance selector:selectorName obj1:nil obj2:nil];
    };
    [self context][@"runInstanceWith1Paramter"] = ^id(id instance, NSString *selectorName, id obj1) {
        return [self _runInstanceWithInstance:instance selector:selectorName obj1:obj1 obj2:nil];
    };
    
    [self context][@"runInstanceWith2Paramters"] = ^id(id instance, NSString *selectorName, id obj1, id obj2) {
        return [self _runInstanceWithInstance:instance selector:selectorName obj1:obj1 obj2:obj2];
    };
    
    [self context][@"runVoidInstanceWithNoParamter"] = ^(id instance, NSString *selectorName) {
        [self _runInstanceWithInstance:instance selector:selectorName obj1:nil obj2:nil];
    };
    
    [self context][@"runVoidInstanceWith1Paramter"] = ^(id instance, NSString *selectorName, id obj1) {
        [self _runInstanceWithInstance:instance selector:selectorName obj1:obj1 obj2:nil];
    };
    
    [self context][@"runVoidInstanceWith2Paramters"] = ^(id instance, NSString *selectorName, id obj1, id obj2) {
        [self _runInstanceWithInstance:instance selector:selectorName obj1:obj1 obj2:obj2];
    };
#pragma mark支持动态创建对象，调用对象方法
     /**手动创建对象*/
    [self context][@"createInstance"] = ^id(NSString *className,NSString * methodInit,id param){
        return [self _createInstanceWithClassName:className selector:methodInit param:param];
    };
    /**手动创建一个类，现在可以先不支持*/
    
    /**手动调用invoke*/
    [self context][@"runInvocation"] = ^(NSInvocation *invocation) {
        [invocation invoke];
    };
  
    [[self context] evaluateScript:@"var console = {}"];
    
    [self context][@"console"][@"log"] = ^(id message) {
        NSLog(@"Javascript log: %@",message);
    };
}

@end
