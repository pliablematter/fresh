//
//  PMFresh.m
//  PMFresh
//
//  Created by Igor Milakovic on 12/03/14.
//  Copyright (c) 2014 Pliable Matter. All rights reserved.
//

#import "PMFresh.h"

#define FRESH_LAST_DOWNLOAD_DATE_KEY    @"kFreshLastDownloadDateKey"
#define FREST_PACKAGE_OLD_SUFFIX        @"_old" // Used for renaming the old package before unzipping new one

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
    }
    return self;
}

#pragma mark - Public

- (void)update
{
    PMLog(@"Update started...");
    
    NSDate *lastDownloadDate = [[NSUserDefaults standardUserDefaults] objectForKey:FRESH_LAST_DOWNLOAD_DATE_KEY];
    PMLog(@"Last download date: %@", [self stringFromDate:lastDownloadDate]);
    
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
        [self renameOldPackageIfNeeded];
        [self unzipPackageAtPath:path];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:FRESH_LAST_DOWNLOAD_DATE_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        PMLog(@"Download failed with error: %@", error);
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead)
    {
        PMLog(@"Download progress: %.2f%%", 100.0 * (float)totalBytesRead / totalBytesExpectedToRead);
    }];
    
    [operation start];
}

- (void)renameOldPackageIfNeeded
{
    NSString *packagePath = [[self documentsDirectoryPath] stringByAppendingPathComponent:self.packageName];
    NSString *oldPackagePath = [packagePath stringByAppendingString:FREST_PACKAGE_OLD_SUFFIX];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:packagePath])
    {
        [[NSFileManager defaultManager] moveItemAtPath:packagePath toPath:oldPackagePath error:nil];
        PMLog(@"Old package renamed");
    }
}

- (void)unzipPackageAtPath:(NSString *)path
{
    PMLog(@"Unzipping package...");
    [SSZipArchive unzipFileAtPath:path toDestination:[self documentsDirectoryPath] delegate:self];
}

#pragma mark - Private

- (NSString *)documentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}

- (NSString *)stringFromDate:(NSDate *)date
{
    // Conversion to Last-Modified-Date format
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
    
    // Remove zip file
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
    // Remove __MACOSX folder
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsDirectoryPath] error:nil];
    
    for (NSString *filepath in content)
    {
        if ([filepath isEqualToString:@"__MACOSX"])
        {
            NSString *removePath = [[self documentsDirectoryPath] stringByAppendingPathComponent:filepath];
            [[NSFileManager defaultManager] removeItemAtPath:removePath error:nil];
            break;
        }
    }
    
    // Remove old package
    NSString *oldPackagePath = [[unzippedPath stringByAppendingPathComponent:self.packageName] stringByAppendingString:FREST_PACKAGE_OLD_SUFFIX];
    if ([[NSFileManager defaultManager] fileExistsAtPath:oldPackagePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:oldPackagePath error:nil];
        PMLog(@"Old package removed");
    }
    
    PMLog(@"Update finished!");
}

@end
