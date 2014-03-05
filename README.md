Fresh is a library that keeps your iOS application's content up-to-date without running your own web application and server. Just host your content on Amazon S3 or any standards-compliant web server and you're ready to go.

## Here's how it works

1. Zip up your content and upload it S3 or a standards compliant web server (we refer to this zip file as a package below)
2. Include a default copy of the package in the app bundle you distribute. This will be used if a network connection isn't available the first time your app loads.
3. Instantiate PMFresh in your app delegate and provide the remote content URL, name of the default package (in your bundle) and the name of the directory where you'd like to have the package expanded.
4. Call [fresh update] whenever you want to check for updated content. (applicationDidBecomeActive is a good place for this.)
5. Fresh will make sure that the latest available version of your content is available to your app in its Documents directory.


## FAQ
### How will it know that my content changed?
Each time you call [fresh update], Fresh will sent a GET request with the If-Modified-Since header to the remote address. The value of the header will be the Last-Modified date that was returned the last time a package was successfully downloaded. If the remote packages's modification date is new than the date provided then it will be returned. Otherwise, the server will return a status of ??? Not Modified, with an empty response. This provides a bandwidth-friendly way to check for changes.
