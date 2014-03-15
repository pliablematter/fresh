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

#define LOG_ENABLED 1

#if LOG_ENABLED
#define PMLog(args,...) NSLog(@"[%@] %@", NSStringFromClass(self.class), [NSString stringWithFormat:(args), ##__VA_ARGS__])
#else
#define PMLog(args,...)
#endif

@interface PMFresh : NSObject <SSZipArchiveDelegate>

@property (strong, nonatomic) NSString *packageName;
@property (strong, nonatomic) NSString *remotePackageUrl;
@property (strong, nonatomic) NSString *localPackagePath;

- (id)initWithPackageName:(NSString *)packageName remotePackageUrl:(NSString *)remotePackageUrl localPackagePath:(NSString *)localPackagePath;
- (void)update;

@end
