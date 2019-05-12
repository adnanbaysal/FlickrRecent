# FlickrRecent
An iOS app to fetch and download recent Flickr photos

App is tab based. When app launches, Recent tap opens and fetches 21 recent photos from Flicker using photos.getRecent api.

If user taps any photo on recent tab, high resolution image is shown bigger and that image is downloaded to the disk.

Downloaded images can be seen or deleted on Downloads tab.

App uses open api_key from Flickr which changes daily. So in order to test the app, "requestURLString" under "FlickrRecent/Flickr/FlickrFetcher.swift" should be changed and recompiled. 
