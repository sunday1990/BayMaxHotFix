//
//  AppDelegate.m
//  BayMaxHotFix
//
//  Created by ccSunday on 2018/3/10.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "AppDelegate.h"
#import "BayMaxHotFix.h"
#import "ViewController.h"
#import "ZGPatchEngine.h"
#import "JPEngine.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [BayMaxHotFix fixIt];

    [JPEngine startEngine];
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    [JPEngine evaluateScript:script];

    
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
//    view.backgroundColor = [UIColor redColor];
//    [self.view addSubview:view];

    
//    NSString *fixScriptString =
//    @"\
//    var obj = createInstance('MightyCrash','initWithName:','李四');\
//    console.log(obj);\
//    fixInstanceMethodAfter('ViewController','haha',function(instance, originInvocation, originArguments){\
//        console.log('点击了屏幕');\
//        runVoidClassWith1Paramter('SVProgressHUD','showSuccessWithStatus:','patch成功');\
//        var view = createInstance('UIView','initWithFrame:',{x:0,y:0,width:100,height:100});\
//        runVoidInstanceWith1Paramter(view,'setBackgroundColor:',runClassWithNoParamter('UIColor','redColor'));\
//        console.log(view);\
//    });\
//    \
//    ";
//    
//
//    [BayMaxHotFix evalString:fixScriptString];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[ViewController alloc]init];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
