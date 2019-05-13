//
//  MyFlickrFetcher.swift
//  PhotosList
//
//  Created by Adnan Baysal on 10.05.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import Foundation
import UIKit

class FlickrFetcher {
    // Change this flickr request URL daily, from : https://www.flickr.com/services/api/explore/?method=flickr.photos.getRecent
    private let requestURLString = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=fc00137457f82899c4f4f0fe5e25e851&per_page=21&page=1&format=json&nojsoncallback=1&auth_token=72157708409712155-45fcb41be5c7bb81&api_sig=634d39e1c2bdfb04d860c020d5e49af6"
    
    var photoURLs: [URL]!
    var photos: [UIImage] = []
    var photoTitles: [String] = []
    
    func fetchPhotos(_ completion: @escaping () -> Void ) {
        let requestURL = URL(string: requestURLString)
        photos = [UIImage]()
        photoURLs = [URL]()
        do {
            let requestResult = try String(contentsOf: requestURL!, encoding: .ascii)
            let data = requestResult.data(using: String.Encoding.utf8)!
            var dictionary: [String:AnyObject]!
            do{
                dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                if dictionary["stat"] as! String == "ok" {
                    let photosJSON = dictionary["photos"]
                    let photoArray = photosJSON!["photo"] as! [[String: AnyObject]]

                    for photoObj in photoArray {
                        DispatchQueue.main.async {
                            do {
                                let url = self.getPhotoURL(photoObj)
                                let photoTitle = photoObj["title"] as? String ?? " "
                                let imageData = try Data(contentsOf: url)
                                let image = UIImage(data: imageData)!
                                self.photos.append(image)
                                self.photoURLs.append(url)
                                self.photoTitles.append(photoTitle)
                            } catch {
                                print("image data cannot be read")
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                fatalError("JSONSerialization failed: \(error.localizedDescription)")
            }
        } catch {
            fatalError("URL fetching failed: \(error.localizedDescription)")
        }
    }
    
    private func getPhotoURL(_ photoObj: [String: AnyObject]) -> URL {
        let photoID = photoObj["id"] as! String
        let farm = photoObj["farm"] as! Int
        let server = photoObj["server"] as! String
        let secret = photoObj["secret"] as! String
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_m.jpg")!
    }
}

