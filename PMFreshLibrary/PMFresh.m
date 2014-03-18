//
//  PMFresh.m
//  PMFresh
//
//  Created by Igor Milakovic on 12/03/14.
//  Copyright (c) 2014 Pliable Matter. All rights reserved.
//

#import "PMFresh.h"

// NSUserDefaults key.
#define FRESH_LAST_DOWNLOAD_DATE_KEY    @"kFreshLastDownloadDateKey"

// Used as a name suffix for the new package that will be unzipped.
#define FRESH_PACKAGE_TEMP_SUFFIX       @"_temp"

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
    }
    return self;
}

#pragma mark - Public

- (void)update
{
    PMLog(@"Update started...");
    
    NSDate *lastDownloadDate = [[NSUserDefaults standardUserDefaults] objectForKey:FRESH_LAST_DOWNLOAD_DATE_KEY];
    PMLog(@"Last download date: %@", [self stringFromDate:lastDownloadDate]);
    
    // Request package header to check if it was modified.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.remotePackageUrl]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod:@"HEAD"];
    [request setValue:[self stringFromDate:lastDownloadDate] forHTTPHeaderField:@"If-Modified-Since"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        [self downloadPackageFromRemoteUrl];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if (operation.response.statusCode == 304)
        {
            PMLog(@"Package has not been modified");
        }
        else
        {
            [self copyPackageFromBundleIfNeeded];
        }
    }];
    
    [operation start];
}

#pragma mark - Package

- (void)copyPackageFromBundleIfNeeded
{
    PMLog(@"Copying package from bundle if needed...");
    NSString *path = [[self documentsDirectoryPath] stringByAppendingPathComponent:self.packageName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        PMLog(@"Package already exists - no need to copy from bundle");
    }
    else
    {
        NSString *destinationPath = [[self documentsDirectoryPath] stringByAppendingPathComponent:self.localPackagePath.lastPathComponent];
        [[NSFileManager defaultManager] copyItemAtPath:self.localPackagePath toPath:destinationPath error:nil];
        PMLog(@"Package copied from bundle");
        
        [self unzipPackageAtPath:destinationPath];
    }
}

- (void)downloadPackageFromRemoteUrl
{
    PMLog(@"Downloading package from remote URL...");
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.remotePackageUrl]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
     
    NSString *path = [[self documentsDirectoryPath] stringByAppendingPathComponent:self.remotePackageUrl.lastPathComponent];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        PMLog(@"Download succeeded!");
        [self unzipPackageAtPath:path];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:FRESH_LAST_DOWNLOAD_DATE_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        PMLog(@"Download failed with error: %@", error);
        
        // Remove zip file because download failed.
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead)
    {
        PMLog(@"Download progress: %.2f%%", 100.0 * (float)totalBytesRead / totalBytesExpectedToRead);
    }];
    
    [operation start];
}

- (BOOL)removeOldPackageIfNeeded
{
    NSString *packagePath = [[self documentsDirectoryPath] stringByAppendingPathComponent:self.packageName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:packagePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:packagePath error:nil];
        PMLog(@"Old package removed");
        
        return YES;
    }
    
    return NO;
}

- (void)renameNewPackageAtPath:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSString *packagePath = [[self documentsDirectoryPath] stringByAppendingPathComponent:self.packageName];
        
        [[NSFileManager defaultManager] moveItemAtPath:path toPath:packagePath error:nil];
        PMLog(@"New package renamed");
        
        // User can access package path on the default location.
        _packagePath = nil;
        _packagePath = packagePath;
        PMLog(@"Package is now accessible at default location: %@", self.packagePath);
        
        PMLog(@"Update finished!");
    }
}

- (void)unzipPackageAtPath:(NSString *)path
{
    PMLog(@"Unzipping package...");
    NSString *destinationPath = [[self documentsDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", self.packageName, FRESH_PACKAGE_TEMP_SUFFIX]];
    [SSZipArchive unzipFileAtPath:path toDestination:destinationPath delegate:self];
}

#pragma mark - Private

- (NSString *)documentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}

- (NSString *)stringFromDate:(NSDate *)date
{
    // Conversion to Last-Modified-Date format.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    return [[dateFormatter stringFromDate:date] stringByAppendingString:@" GMT"];
}

#pragma mark - SSZipArchiveDelegate

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    PMLog(@"Package unzipped");
    
    // Remove zip file.
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
    // Remove __MACOSX folder.
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzippedPath error:nil];
    
    for (NSString *filepath in content)
    {
        if ([filepath isEqualToString:@"__MACOSX"])
        {
            NSString *removePath = [unzippedPath stringByAppendingPathComponent:filepath];
            [[NSFileManager defaultManager] removeItemAtPath:removePath error:nil];
            break;
        }
    }
    
    // User can access package path on the temporary location.
    _packagePath = nil;
    _packagePath = unzippedPath;
    PMLog(@"Package is now accessible at temporary location: %@", self.packagePath);
    
    // If old package existed, rename new package after delay (timeout interval) to make sure that old package is safely deleted.
    // Else simply rename the new package to default name.
    if ([self removeOldPackageIfNeeded])
    {
        [self performSelector:@selector(renameNewPackageAtPath:) withObject:unzippedPath afterDelay:self.timeoutInterval];
    }
    else
    {
        [self renameNewPackageAtPath:unzippedPath];
    }
}

@end
