//
//  AppDelegate.m
//  PMFresh
//
//  Created by Igor Milakovic on 12/03/14.
//  Updated by Doug Burns on 2/19/15.
//  Copyright (c) 2015 Pliable Matter. All rights reserved.
//

#import "AppDelegate.h"
#import "PMFresh.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.fileFresh = [[PMFresh alloc] initWithPackageName:@"file"
                                     remotePackageUrl:@"https://s3.amazonaws.com/pm-fresh/file.tgz"
                                     localPackagePath:[[NSBundle mainBundle] pathForResource:@"file" ofType:@"tgz"]];
    
    self.directoryFresh = [[PMFresh alloc] initWithPackageName:@"directory"
                                         remotePackageUrl:@"https://s3.amazonaws.com/pm-fresh/directory.tgz"
                                         localPackagePath:[[NSBundle mainBundle] pathForResource:@"directory" ofType:@"tgz"]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:[[UIViewController alloc] init]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
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
    [self.directoryFresh update];
    [self.fileFresh updateWithHeaders:@{@"Test1": @"123", @"Test2": @"ABC"}];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
