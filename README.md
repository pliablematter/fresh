Fresh is a library that helps to keep your iOS application's content up-to-date without having to run your own web application and server. Just host your content on Amazon S3 or any standards-compliant web server and you're ready to go.

## Here's how it works

1. Tar and gzip your content and upload it S3 or a standards compliant web server (we refer to this .tgz file as a package below)
2. Include a default copy of the package in the app bundle you distribute. This ensures that some content is always available. It is used if a network connection isn't available the first time your app loads.
3. Instantiate PMFresh in your app delegate and provide the remote content URL, name of the default package (in your bundle) and the name of the directory where you'd like to have the package expanded.
4. Call [fresh update] whenever you want to check for updated content. (applicationDidBecomeActive is a good place for this)
5. Fresh will make sure that the latest available version of your content is available to your app in its Documents directory.

## Getting Started

The remote and local packages *must* be a tarred gzip, otherwise extraction will fail.

You can .tgz a file or entire directory like this:

```
tar -zcvf file.tgz file_to_compress
```
```
tar -zcvf directory.tgz directory_to_compress
```
(It's the same command for both)

For a basic setup that checks for new content and startup, you could add the following to your app delegate


```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.fresh = [[PMFresh alloc] initWithPackageName:@"content"
                                     remotePackageUrl:@"http://s3.amazonaws.com/pm-fresh/content.gz"
                                     localPackagePath:[[NSBundle mainBundle] pathForResource:@"content" ofType:@"gz"]];
    
    ...
}

```

or if your app is using a container for storing data it would be:

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.fresh = [[PMFresh alloc] initWithPackageName:@"content"
                                              remotePackageUrl:@"http://s3.amazonaws.com/pm-fresh/content.gz"
                                              localPackagePath:[[NSBundle mainBundle] pathForResource:@"content" ofType:@"gz"]
                            				  securityApplicationGroupIdentifier:@"group.com.pliablematter.fresh"];
}
}
```


```objc
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.fresh update];
}
```

You can get the local package path like this:

```objc
NSString *packagePath = self.fresh.packagePath;
```

**See the PMFresh directory for a working example.**

## Custom save
By default, Fresh unzips and saves data to the app's Documents directory using the package name as the filename. You can override this behavior to do things such as updating a local database. Just subclass PMFresh and override these functions: 
* `(void)savePackage:(NSData*)data` - Process and save the data. For example, decompress it, decrypt it, and or save it to the filesystem or a database.
* `(BOOL)packageExists` - Return `YES` if the package has ever been saved, or `NO` if it has not. In your implementation you may do things like query for the existence of a file, or query the database for certain records.

## .meta file
By default, Fresh will only use the package that's shipped in the bundle for the first install, or to "restore" if there's an error downloading the remote package. If you include a [package_name].meta file with a Last-Modified key it will handle the local bundle package as if it's a remote resource. This can help you (and your users) save bandwidth since it will install from the local bundle instead of the remote server when the local version is newer. For example, you could ship an app update with the latest content and users who updated the app would get that content immediately. A week later, after the majority of your users had updated, you could push the latest content to your server, at which point any users that had not yet updated would download it. You probably won't always have an app update planned at the same time you want to release content, but when you do following this process can prevent the same content from being downloaded twice (once bundled in the app, again over the network).

The .meta should be JSON, with the same name as your package with a .meta extension. So if your package is named `file.gz` then the .meta file would be `file.gz.meta`. The JSON must included a `Last-Modified` with a date in the same format and time zone as your server. The date must be later (to the second) than the last modified date of the file on the server or it will get downloaded from the server instead.

Example `file.gz.meta`:
```json
{"Last-Modified": "Sat, 10 Nov 2018 14:46:48 GMT"}
```

## FAQ
### How will it know that my content has changed?
Each time you call [fresh update], Fresh will send a GET request with the If-Modified-Since header to the remote address. The value of the header will be the Last-Modified date that was returned the last time a package was successfully downloaded. If the remote packages's modification date is new than the date provided then it will be returned. Otherwise, the server will return a status of "304 Not Modified", with an empty response. This provides a bandwidth-friendly way to check for changes.
### Why am I seeing the log message 'Package could not be unzipped. Verify that it is gzip format.
By default, Fresh only supports gzipped content. Make sure that the content is [gzipped (.gz)](http://en.wikipedia.org/wiki/Gzip) and not pkzipped (.zip) (which is the default for Mac and Windows). Alternatively, you can handle custom data types by overriding the `savePackage` and `packageExists` functions as described above.
### Why am I seeing 'Unexpected status code 403 returned while attempting to download package.' in the log?
This means that the webserver does not have permission to read the file. Make sure that it's readable by the account your web server is running as, or globally readable if you're using S3.
