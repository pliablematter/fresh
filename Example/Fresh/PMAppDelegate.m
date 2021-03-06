//
//  PMAppDelegate.m
//  Fresh
//
//  Created by doug@pliablematter.com on 09/09/2018.
//  Copyright (c) 2018 doug@pliablematter.com. All rights reserved.
//

#import "PMAppDelegate.h"

@implementation PMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.fileFresh = [[PMFresh alloc] initWithPackageName:@"file"
                                         remotePackageUrl:@"https://s3.amazonaws.com/pm-fresh/file.tgz"
                                         localPackagePath:[[NSBundle mainBundle] pathForResource:@"file" ofType:@"tgz"]];
    NSLog(@"fileFresh package path is %@", self.fileFresh.packagePath);
    
    self.directoryFresh = [[PMFresh alloc] initWithPackageName:@"directory"
                                              remotePackageUrl:@"https://s3.amazonaws.com/pm-fresh/directory.tgz"
                                              localPackagePath:[[NSBundle mainBundle] pathForResource:@"directory" ofType:@"tgz"]];
    NSLog(@"directoryFresh package path is %@", self.directoryFresh.packagePath);
    
    self.containerFresh = [[PMFresh alloc] initWithPackageName:@"container"
                                              remotePackageUrl:@"https://s3.amazonaws.com/pm-fresh/file.tgz"
                                              localPackagePath:[[NSBundle mainBundle] pathForResource:@"file" ofType:@"tgz"]
                            securityApplicationGroupIdentifier:@"group.com.pliablematter.fresh"];
    
    
    
    
    
    // Override point for customization after application launch.
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
