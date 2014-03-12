//
//  PMFresh.h
//  PMFresh
//
//  Created by Igor Milakovic on 12/03/14.
//  Copyright (c) 2014 Pliable Matter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMFresh : NSObject

@property (strong, nonatomic) NSString *packageName;
@property (strong, nonatomic) NSString *remotePackageUrl;
@property (strong, nonatomic) NSString *localPackagePath;

- (id)initWithPackageName:(NSString *)packageName remotePackageUrl:(NSString *)remotePackageUrl localPackagePath:(NSString *)localPackagePath;

- (void)update;

@end
