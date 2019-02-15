//
//  EMAppDelegate.m
//  Emax_DebugKit
//
//  Created by chen0108_mbp on 12/24/2018.
//  Copyright (c) 2018 chen0108_mbp. All rights reserved.
//

#import "EMAppDelegate.h"
#import "EMDebugKit.h"


@interface EMAppDelegate ()<UIGestureRecognizerDelegate>



@end

@implementation EMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIGestureRecognizer *ges =  [EMDebugManager setupTriggerGestureTapCount:3 password:@"2"];
    ges.delegate = self;
    [self.window addGestureRecognizer:ges];
    
    [EMLogManager setRedirectLogState:RedirectLogToFile];
    
    [EMAppLanguage setCustomLanguageEnable:YES];
    [EMAppLanguage setSupportLanguageDictionary:@{@"zh-":@"zh-Hans",
                                                  @"de-":@"de",
                                                  @"ja-":@"ja",
                                                  @"ru-":@"ru-RU",
                                                  @"fr-":@"fr",
                                                  @"el-":@"el-GR",
                                                  }];

    [EMFactoryManager setDefaulFactoryMode:YES];
    [EMFactoryManager modeChangedHander:^{
        [EMDebugManager exitApplication];
    }];
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIControl class]]){
        return NO;
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
