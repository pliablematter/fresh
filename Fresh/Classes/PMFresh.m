//
//  PMFresh.m
//  PMFresh
//
//  Created by Igor Milakovic on 12/03/14.
//  Updated by Doug Burns on 2/19/15 and beyond.
//  Copyright (c) 2019 Pliable Matter LLC. All rights reserved.
//

#import "PMFresh.h"
#import "DCTar.h"

// NSUserDefaults key.
#define FRESH_LAST_DOWNLOAD_DATE_SUFFIX    @"FreshLastDownloadDate"

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
        [self installPackageFromBundleIfNeeded];
    }
    return self;
}

- (id)initWithPackageName:(NSString *)packageName remotePackageUrl:(NSString *)remotePackageUrl localPackagePath:(NSString *)localPackagePath securityApplicationGroupIdentifier:(NSString*)groupId
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
        
        NSURL *containerUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupId];
        _packagePath = [NSString stringWithFormat:@"%@/%@", containerUrl.path, self.packageName];
        
        // Ensure that expanded package files are available
        [self installPackageFromBundleIfNeeded];
    }
    return self;
}

#pragma mark - Public

- (void)update
{
    [self updateWithHeaders:NULL];
}

- (void)updateWithHeaders:(NSDictionary*)headers
{
    PMLog(@"Update started.");
    [self updateFromBundle];
    
    NSString *lastModified = [self lastModifiedDate];
    
    // Request package header to check if it was modified.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.remotePackageUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.timeoutInterval];
    [request setValue:lastModified forHTTPHeaderField:@"If-Modified-Since"];
    
    if(headers) {
        for(id key in headers) {
            [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    NSLog(@"Sending request with headers %@ for package %@", [request allHTTPHeaderFields], self.packageName);
    
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
                PMLog(@"Package %@ has not been modified.", self.packageName);
                [self installPackageFromBundleIfNeeded];
            }
            else
            {
                PMLog(@"Unexpected status code %ld returned while attempting to download package %@.", httpResponse.statusCode, self.packageName);
                [self installPackageFromBundleIfNeeded];
            }
        }
        else
        {
            PMLog(@"Error while downloading package %@. %@", self.packageName, connectionError.description);
            [self installPackageFromBundleIfNeeded];
        }
    }];
}

- (void) resetLastDownloadDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:[self lastDownloadDateKey]];
    [defaults synchronize];
}

#pragma mark - Package

- (BOOL)savePackage:(NSData*)data
{
    NSError *err = nil;
    @try {
        BOOL success = [DCTar decompressData:data toPath:self.packagePath error:nil];
        if(success) {
            PMLog(@"Package %@ saved to %@", self.packageName, self.packagePath);
            return YES;
        }
        else
        {
            PMLog(@"Package %@ could not be extraced. %@", self.packageName, err.localizedDescription);
            return NO;
        }
    }
    @catch(NSException* e) {
        PMLog(@"Package for %@ could not be extraced. Make sure that it's a tarred gzip archive.", self.packageName);
        return NO;
    }
}

- (BOOL)packageExists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:self.packagePath];
}

#pragma mark - Private

- (void) updateFromBundle
{
    NSString *bundleLastModifiedString = [self bundlePackageLastModifiedDate];
    if(bundleLastModifiedString)
    {
        NSLog(@"Checking whether bundle package for %@ is newer than last installed package.", self.packageName);
        
        NSLog(@"Bundle last modified: %@", bundleLastModifiedString);
        NSDate *bundleLastModified = [self dateForDateString:bundleLastModifiedString];
        
        NSString *installedLastModifiedString = [self lastModifiedDate];
        NSDate *installedLastModified = [self dateForDateString:installedLastModifiedString];
        
        NSComparisonResult comparison = [installedLastModified compare:bundleLastModified];
        
        if(comparison == NSOrderedAscending)
        {
            NSLog(@"Bundle package last modified date %@ is newer than installed package last modified date %@ for package %@. Installing package from bundle.", bundleLastModified, installedLastModified, self.packageName);
            [self installPackageFromBundle];
        }
        else
        {
            NSLog(@"Installed package is newer than bundle package for %@. Skipping update from bundle.", self.packageName);
        }
    }
    else
    {
        NSLog(@"Package %@ does not have a .meta file. Skipping update from bundle.", self.packageName);
    }
    
    
    // Read the meta file if it exists
}

- (NSString*)lastDownloadDateKey
{
    return [NSString stringWithFormat:@"%@%@", self.packageName, FRESH_LAST_DOWNLOAD_DATE_SUFFIX];
}

- (void)updateModificationDateWithHeaders:(NSDictionary*)headers
{
    NSString *lastModified = [headers valueForKey:@"Last-Modified"];
    [self saveLastModifiedDate:lastModified];
}

- (void)installPackageFromBundleIfNeeded
{
    PMLog(@"Copying package from bundle if needed for %@.", self.packageName);
    
    if(![self packageExists])
    {
        [self installPackageFromBundle];
    }
    else
    {
        PMLog(@"Package for %@ exists in documents directory. No need to retrieve from bundle.", self.packageName);
    }
}

- (void) installPackageFromBundle
{
    if([[NSFileManager defaultManager] fileExistsAtPath:self.localPackagePath])
    {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:self.localPackagePath];
        [self savePackage:data];
        PMLog(@"Package installed from bundle for %@", self.packageName);
        NSString *lastModified = [self bundlePackageLastModifiedDate];
        if(lastModified)
        {
            [self saveLastModifiedDate:lastModified];
        }
    }
    else
    {
        PMLog(@"Default package for %@ does not exist in bundle so it cannot be installed.", self.packageName);
    }
}

- (NSString *)documentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}

- (NSString*) bundlePackageLastModifiedDate {
    NSString *metaPath = [NSString stringWithFormat:@"%@.meta", self.localPackagePath];
    if([[NSFileManager defaultManager] fileExistsAtPath:metaPath]) {
        NSData *metaJson = [NSData dataWithContentsOfFile:metaPath];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:metaJson options:kNilOptions error:nil];
        return [json valueForKey:@"Last-Modified"];
    }
    return nil;
}

- (NSDate*) dateForDateString:(NSString*)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

- (void) saveLastModifiedDate:(NSString*)lastModified {
    if(lastModified)
    {
        [[NSUserDefaults standardUserDefaults] setObject:lastModified forKey:[self lastDownloadDateKey]];
        PMLog(@"Saving last download date %@ for key %@", lastModified, [self lastDownloadDateKey]);
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self lastDownloadDateKey]];
        PMLog(@"Attempted to save nil last modified fdate for package %@. This library may not work as expected.", self.packageName);
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) lastModifiedDate
{
    NSString *lastModified = [[NSUserDefaults standardUserDefaults] objectForKey:[self lastDownloadDateKey]];
    PMLog(@"Returning saved lastModified date: %@ for key %@", lastModified, [self lastDownloadDateKey]);
    return lastModified;
}



@end
