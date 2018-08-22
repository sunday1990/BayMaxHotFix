//
//  ZGPatchEngine.m
//  BayMaxHotFix
//
//  Created by zhugefang on 2018/8/17.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "ZGPatchEngine.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation ZGPatchEngine
static JSContext *_context;
static NSString *_regexStr = @"(?<!\\\\)\\.\\s*(\\w+)\\s*\\(";
static NSString *_replaceStr = @".__c(\"$1\")(";
static NSRegularExpression* _regex;
static NSObject *_nullObj;
static NSObject *_nilObj;
static NSMutableDictionary *_registeredStruct;
static NSMutableDictionary *_currInvokeSuperClsName;
static char *kPropAssociatedObjectKey;
static BOOL _autoConvert;
static BOOL _convertOCNumberToString;
static NSString *_scriptRootDir;
static NSMutableSet *_runnedScript;

static NSMutableDictionary *_JSOverideMethods;
static NSMutableDictionary *_TMPMemoryPool;
static NSMutableDictionary *_propKeys;
static NSMutableDictionary *_JSMethodSignatureCache;
static NSLock              *_JSMethodSignatureLock;
static NSRecursiveLock     *_JSMethodForwardCallLock;
static NSMutableDictionary *_protocolTypeEncodeDict;
static NSMutableArray      *_pointersToRelease;

+ (void)startEngine{
    if (![JSContext class] || _context) {
        return;
    }
    
    JSContext *context = [[JSContext alloc] init];
    
    context[@"_OC_defineClass"] = ^(NSString *classDeclaration, JSValue *instanceMethods, JSValue *classMethods) {
        // return defineClass(classDeclaration, instanceMethods, classMethods);
        return nil;
    };
    
    context[@"_OC_defineProtocol"] = ^(NSString *protocolDeclaration, JSValue *instProtocol, JSValue *clsProtocol) {
//        // return defineProtocol(protocolDeclaration, instProtocol,clsProtocol);
        return nil;
    };
    
    context[@"_OC_callI"] = ^id(JSValue *obj, NSString *selectorName, JSValue *arguments, BOOL isSuper) {
//        // return callSelector(nil, selectorName, arguments, obj, isSuper);
        return nil;
    };
    context[@"_OC_callC"] = ^id(NSString *className, NSString *selectorName, JSValue *arguments) {
        // return callSelector(className, selectorName, arguments, nil, NO);
        return nil;
    };
    context[@"_OC_formatJSToOC"] = ^id(JSValue *obj) {
        // return formatJSToOC(obj);
        return nil;
    };
    
    context[@"_OC_formatOCToJS"] = ^id(JSValue *obj) {
        // return formatOCToJS([obj toObject]);
        return nil;
    };
    
    context[@"_OC_getCustomProps"] = ^id(JSValue *obj) {
//        id realObj = formatJSToOC(obj);
        // return objc_getAssociatedObject(realObj, kPropAssociatedObjectKey);
        return nil;
    };
    
    context[@"_OC_setCustomProps"] = ^(JSValue *obj, JSValue *val) {
//        id realObj = formatJSToOC(obj);
//        objc_setAssociatedObject(realObj, kPropAssociatedObjectKey, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    };
    
    context[@"__weak"] = ^id(JSValue *jsval) {
//        id obj = formatJSToOC(jsval);
        // return [[JSContext currentContext][@"_formatOCToJS"] callWithArguments:@[formatOCToJS([JPBoxing boxWeakObj:obj])]];
        return nil;
    };
    
    context[@"__strong"] = ^id(JSValue *jsval) {
//        id obj = formatJSToOC(jsval);
        // return [[JSContext currentContext][@"_formatOCToJS"] callWithArguments:@[formatOCToJS(obj)]];
        return nil;
    };
    
    context[@"_OC_superClsName"] = ^(NSString *clsName) {
        Class cls = NSClassFromString(clsName);
        // return NSStringFromClass([cls superclass]);
        return nil;
    };
    
    context[@"autoConvertOCType"] = ^(BOOL autoConvert) {
//        _autoConvert = autoConvert;
    };
    
    context[@"convertOCNumberToString"] = ^(BOOL convertOCNumberToString) {
//        _convertOCNumberToString = convertOCNumberToString;
    };
    
    context[@"include"] = ^(NSString *filePath) {
//        NSString *absolutePath = [_scriptRootDir stringByAppendingPathComponent:filePath];
//        if (!_runnedScript) {
//            _runnedScript = [[NSMutableSet alloc] init];
//        }
//        if (absolutePath && ![_runnedScript containsObject:absolutePath]) {
//            [JPEngine _evaluateScriptWithPath:absolutePath];
//            [_runnedScript addObject:absolutePath];
//        }
    };
    
    context[@"resourcePath"] = ^(NSString *filePath) {
        // return [_scriptRootDir stringByAppendingPathComponent:filePath];
    };
    
    context[@"dispatch_after"] = ^(double time, JSValue *func) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [func callWithArguments:nil];
        });
    };
    
    context[@"dispatch_async_main"] = ^(JSValue *func) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [func callWithArguments:nil];
        });
    };
    
    context[@"dispatch_sync_main"] = ^(JSValue *func) {
        if ([NSThread currentThread].isMainThread) {
            [func callWithArguments:nil];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [func callWithArguments:nil];
            });
        }
    };
    
    context[@"dispatch_async_global_queue"] = ^(JSValue *func) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [func callWithArguments:nil];
        });
    };
    context[@"releaseTmpObj"] = ^void(JSValue *jsVal) {
        if ([[jsVal toObject] isKindOfClass:[NSDictionary class]]) {
//            void *pointer =  [(JPBoxing *)([jsVal toObject][@"__obj"]) unboxPointer];
//            id obj = *((__unsafe_unretained id *)pointer);
//            @synchronized(_TMPMemoryPool) {
//                [_TMPMemoryPool removeObjectForKey:[NSNumber numberWithInteger:[(NSObject*)obj hash]]];
//            }
        }
    };
    
    context[@"_OC_log"] = ^() {
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
//            id obj = formatJSToOC(jsVal);
//            NSLog(@"JSPatch.log: %@", obj == _nilObj ? nil : (obj == _nullObj ? [NSNull null]: obj));
        }
    };
    
    context[@"_OC_catch"] = ^(JSValue *msg, JSValue *stack) {
        _exceptionBlock([NSString stringWithFormat:@"js exception, \nmsg: %@, \nstack: \n %@", [msg toObject], [stack toObject]]);
    };
    
    context.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        NSLog(@"%@", exception);
        _exceptionBlock([NSString stringWithFormat:@"js exception: %@", exception]);
    };
    
    _nullObj = [[NSObject alloc] init];
    context[@"_OC_null"] = formatOCToJS(_nullObj);
    
    _context = context;
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"JSPatch" ofType:@"js"];
    if (!path) _exceptionBlock(@"can't find JSPatch.js");
    NSString *jsCore = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    
    if ([_context respondsToSelector:@selector(evaluateScript:withSourceURL:)]) {
        [_context evaluateScript:jsCore withSourceURL:[NSURL URLWithString:@"JSPatch.js"]];
    } else {
        [_context evaluateScript:jsCore];
    }
}

+ (JSValue *)evaluateScript:(NSString *)script
{
    return [self _evaluateScript:script withSourceURL:[NSURL URLWithString:@"main.js"]];
}

+ (JSValue *)_evaluateScript:(NSString *)script withSourceURL:(NSURL *)resourceURL
{
    if (!script || ![JSContext class]) {
        _exceptionBlock(@"script is nil");
        return nil;
    }
    [self startEngine];
    
    if (!_regex) {
        _regex = [NSRegularExpression regularExpressionWithPattern:_regexStr options:0 error:nil];
    }
    NSString *formatedScript = [NSString stringWithFormat:@";(function(){try{\n%@\n}catch(e){_OC_catch(e.message, e.stack)}})();", [_regex stringByReplacingMatchesInString:script options:0 range:NSMakeRange(0, script.length) withTemplate:_replaceStr]];
    @try {
        if ([_context respondsToSelector:@selector(evaluateScript:withSourceURL:)]) {
            return [_context evaluateScript:formatedScript withSourceURL:resourceURL];
        } else {
            return [_context evaluateScript:formatedScript];
        }
    }
    @catch (NSException *exception) {
        _exceptionBlock([NSString stringWithFormat:@"%@", exception]);
    }
    return nil;
}

static id formatOCToJS(id obj)
{
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDate class]]) {
        return nil;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return _convertOCNumberToString ? [(NSNumber*)obj stringValue] : obj;
    }
    if ([obj isKindOfClass:NSClassFromString(@"NSBlock")] || [obj isKindOfClass:[JSValue class]]) {
        return obj;
    }
    return nil;
}


static void (^_exceptionBlock)(NSString *log) = ^void(NSString *log) {
    NSCAssert(NO, log);
};

@end
