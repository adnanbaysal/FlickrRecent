//
//  FlickrDataManager.swift
//  PhotosList
//
//  Created by Adnan Baysal on 11.05.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import Foundation
import UIKit

struct FlickrDataManager {
    private static let fileManager = FileManager.default
    private static let downloadsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
    static func downloadLargeImage(_ url: URL) -> UIImage? {
        var url2str = url.absoluteString
        url2str = url2str.replacingOccurrences(of: "_m.jpg", with: "_b.jpg")
        let largeURL = URL(string: url2str)!
        do {
            let data = try Data(contentsOf: largeURL)
            return UIImage(data: data)
        } catch {
            print("Large image cannot be downloaded: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func saveLargeImage(_ image: UIImage, fileNamed: String, title: String) {
        let fileNameGood = fileNamed.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "/", with: "")
        let fileURL = downloadsDirectory.appendingPathComponent(fileNameGood, isDirectory: false)
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
            } catch {
                print("Existing file could not be deleted: \(error.localizedDescription)")
                return
            }
        }
        fileManager.createFile(atPath: fileURL.path, contents: image.jpegData(compressionQuality: 1.0), attributes: nil)
        let titleFilePath = fileURL.absoluteString.replacingOccurrences(of: ".jpg", with: ".txt")
        do {
            try title.write(to: URL(string: titleFilePath)!, atomically: true, encoding: .utf8)
        } catch {
            print("Cannot write title file: \(error.localizedDescription)")
        }
    }
    
    static func downloadedFileNames() -> [String] {
        do {
            let allFiles = try fileManager.contentsOfDirectory(atPath: downloadsDirectory.path)
            let photoFiles = allFiles.filter { $0.hasSuffix(".jpg") }
            return photoFiles
        } catch {
            print("Error reading file names: \(error.localizedDescription)")
            return []
        }
    }
    
    static func downloadedPhotos() -> ([UIImage], [String], [URL]) {
        do {
            let allFiles = try fileManager.contentsOfDirectory(atPath: downloadsDirectory.path)
            let photoFiles = allFiles.filter { $0.hasSuffix(".jpg") }
            let titleFiles = allFiles.filter { $0.hasSuffix(".txt") }
            var photos = [UIImage]()
            var titles = [String]()
            var photoURLs = [URL]()
            for photoFile in photoFiles {
                let photoURL = downloadsDirectory.appendingPathComponent(photoFile, isDirectory: false)
                if let photo = UIImage(contentsOfFile: photoURL.path) {
                    for titleFile in titleFiles {
                        if titleFile.replacingOccurrences(of: ".txt", with: "") == photoFile.replacingOccurrences(of: ".jpg", with: "") {
                            let titleURL = downloadsDirectory.appendingPathComponent(titleFile, isDirectory: false)
                            do {
                                let title = try String(contentsOf: titleURL)
                                photos.append(photo)
                                titles.append(title)
                                photoURLs.append(photoURL)
                            } catch {
                                print("title file cannot be read: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                }
            }
            return (photos, titles, photoURLs)
        } catch {
            print("Files cannot be loaded from Downloads directory: \(error.localizedDescription)")
            return ([],[],[])
        }
    }
    
    static func deleteFile(_ url: URL) {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("Cannot delete file: \(error.localizedDescription)")
        }
    }
}
