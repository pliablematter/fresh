//
//  PMFresh.m
//  PMFresh
//
//  Created by Igor Milakovic on 12/03/14.
//  Updated by Doug Burns on 2/19/15.
//  Copyright (c) 2015 Pliable Matter. All rights reserved.
//

#import "PMFresh.h"
#import "DCTar.h"

// NSUserDefaults key.
#define FRESH_LAST_DOWNLOAD_DATE_KEY    @"kFreshLastDownloadDateKey"

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
        
        // Set to default timeout interval.
        self.timeoutInterval = DEFAULT_TIMEOUT_INTERVAL;
        
        // Set to default package path.
        _packagePath = [[self documentsDirectoryPath] stringByAppendingPathComponent:self.packageName];
        
        // Ensure that expanded package files are available
        [self retrievePackageFromBundleIfNeeded];
    }
    return self;
}

#pragma mark - Public

- (void)update {
    [self updateWithHeaders:NULL];
}

- (void)updateWithHeaders:(NSDictionary*)headers
{
    PMLog(@"Update started.");
    
    NSString *lastDownloadDate = [[NSUserDefaults standardUserDefaults] objectForKey:FRESH_LAST_DOWNLOAD_DATE_KEY];
    PMLog(@"Last download date: %@", lastDownloadDate);
    
    // Request package header to check if it was modified.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.remotePackageUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.timeoutInterval];
    [request setValue:lastDownloadDate forHTTPHeaderField:@"If-Modified-Since"];
    
    if(headers) {
        for(id key in headers) {
            [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    NSLog(@"Sending request with headers %@", [request allHTTPHeaderFields]);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        
        if(!connectionError)
        {
            if(httpResponse.statusCode == 200)
            {
                BOOL success = [self savePackage:data];
                if(success)
                {
                    [self updateModificationDateWithHeaders:httpResponse.allHeaderFields];
                }
            }
            else if (httpResponse.statusCode == 304)
            {
                PMLog(@"Package has not been modified.");
                [self retrievePackageFromBundleIfNeeded];
            }
            else
            {
                PMLog(@"Unexpected status code %ld returned while attempting to download package.", httpResponse.statusCode);
                [self retrievePackageFromBundleIfNeeded];
            }
        }
        else
        {
            PMLog(@"Error while downloading package. %@", connectionError.description);
            [self retrievePackageFromBundleIfNeeded];
        }
    }];
}

#pragma mark - Package

- (BOOL)savePackage:(NSData*)data
{
    NSError *err = nil;
    @try {
        BOOL success = [DCTar decompressData:data toPath:self.packagePath error:nil];
        if(success) {
            PMLog(@"Package saved to %@", self.packagePath);
            return YES;
        }
        else
        {
            PMLog(@"Package could not be extraced. %@", err.localizedDescription);
            return NO;
        }
    }
    @catch(NSException* e) {
        PMLog(@"Packed could not be extraced. Make sure that it's a tarred gzip archive.");
        return NO;
    }
}

- (BOOL)packageExists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:self.packagePath];
}

#pragma mark - Private

- (void)updateModificationDateWithHeaders:(NSDictionary*)headers
{
    NSString *lastModified = [headers valueForKey:@"Last-Modified"];
    
    if(lastModified)
    {
        [[NSUserDefaults standardUserDefaults] setObject:lastModified forKey:FRESH_LAST_DOWNLOAD_DATE_KEY];
        PMLog(@"Saving last download date %@", lastModified);
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:FRESH_LAST_DOWNLOAD_DATE_KEY];
        PMLog(@"Response does not include a Last-Modified header. This library may not work as excpected.");
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)retrievePackageFromBundleIfNeeded
{
    PMLog(@"Copying package from bundle if needed.");
    
    if(![self packageExists])
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:self.localPackagePath])
        {
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:self.localPackagePath];
            [self savePackage:data];
            PMLog(@"Package retrieved from bundle");
        }
        else
        {
            PMLog(@"Default package does not exist in bundle so it cannot be retrieved.");
        }
    }
    else
    {
        PMLog(@"Package exists in documents directory. No need to retrieve from bundle.");
    }
}

- (NSString *)documentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}

@end
