//
//  PMFresh.m
//  PMFresh
//
//  Created by Igor Milakovic on 12/03/14.
//  Copyright (c) 2014 Pliable Matter. All rights reserved.
//

#import "PMFresh.h"

@implementation PMFresh

#pragma mark - Init

- (id)initWithPackageName:(NSString *)packageName remotePackageUrl:(NSString *)remotePackageUrl localPackagePath:(NSString *)localPackagePath
{
    self = [super init];
    if (self)
    {
        self.packageName = packageName;
        self.remotePackageUrl = remotePackageUrl;
        self.localPackagePath = localPackagePath;
        
        [self update];
    }
    return self;
}

#pragma mark - Public

- (void)update
{
    
}

@end
