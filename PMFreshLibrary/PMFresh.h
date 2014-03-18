//
//  PMFresh.h
//  PMFresh
//
//  Created by Igor Milakovic on 12/03/14.
//  Copyright (c) 2014 Pliable Matter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking.h>
#import <SSZipArchive.h>

/*
 Default timeout interval for deleting old package.
 */
#define DEFAULT_TIMEOUT_INTERVAL 2.0

/*
 Logging convenience methods. Set 1 to enable log or 0 to disable.
 */
#define LOG_ENABLED 1

#if LOG_ENABLED
#define PMLog(args,...) NSLog(@"[%@] %@", NSStringFromClass(self.class), [NSString stringWithFormat:(args), ##__VA_ARGS__])
#else
#define PMLog(args,...)
#endif

@interface PMFresh : NSObject <SSZipArchiveDelegate>

/*
 Path to local package - in case there is no Internet connection available and package has never been downloaded before.
 */
@property (strong, nonatomic) NSString *localPackagePath;

/*
 Package name is the last part of path to unzipped resources. Useful if ZIP does not contain root directory.
 */
@property (strong, nonatomic) NSString *packageName;

/*
 Full path to the unzipped package - always use this one to fetch your resources!
 */
@property (strong, nonatomic, readonly) NSString *packagePath;

/*
 URL to package on remote server.
 */
@property (strong, nonatomic) NSString *remotePackageUrl;

/*
 Timeout interval used to safely delete old package. Default is set to 2.0 seconds.
 */
@property (assign, nonatomic) NSTimeInterval timeoutInterval;

/*
 Default initializer.
 */
- (id)initWithPackageName:(NSString *)packageName remotePackageUrl:(NSString *)remotePackageUrl localPackagePath:(NSString *)localPackagePath;

/*
 Update method. Call it whenever you need, for example in applicationDidBecomeActive: method.
 */
- (void)update;

@end
