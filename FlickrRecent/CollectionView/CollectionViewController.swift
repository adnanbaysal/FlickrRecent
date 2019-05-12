//
//  CollectionViewController.swift
//  PhotosList
//
//  Created by Adnan Baysal on 9.05.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import UIKit

extension UIImage {
    func aspectRatio() -> CGFloat {
        return self.size.width / self.size.height
    }
}

class CollectionViewController: UICollectionViewController {
    
    struct ViewSettings {
        static let offsetDivider: CGFloat = 40
        static let numberOfPhotosPerRow: CGFloat = 3
    }
    
    private let fileManager = FileManager.default
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var flickrFetcher = FlickrFetcher()
    
    private var photoOffset: CGFloat = 0
    private var headerText: String = " "
    private var downloadedImages = [Bool]()
    private var selectedCellPath: IndexPath? {
        didSet {
            var indices: [IndexPath] = []
            if let selectedCellPath = selectedCellPath {
                indices.append(selectedCellPath)
            }
            if let oldValue = oldValue {
                indices.append(oldValue)
            }
            collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: indices)
            }) { _ in
                if let selectedCellPath = self.selectedCellPath {
                    self.collectionView.scrollToItem(at: selectedCellPath,
                                                     at: .centeredVertically,
                                                     animated: true)
                    let cell = self.collectionView(self.collectionView, cellForItemAt: selectedCellPath) as! CollectionViewCell
                    let row = selectedCellPath.row
                    if !self.downloadedImages[row] {
                        cell.downloadIndicator.startAnimating()
                        DispatchQueue.main.async {
                            let imageURL = self.flickrFetcher.photoURLs[row]
                            let largeImage = FlickrDataManager.downloadLargeImage(imageURL)
                            cell.downloadIndicator.stopAnimating()
                            if let largeImage = largeImage {
                                self.flickrFetcher.photos[row] = largeImage
                                self.collectionView.reloadItems(at: [selectedCellPath])
                                self.downloadedImages[row] = true
                                DispatchQueue.main.async {
                                    let title = self.flickrFetcher.photoTitles[row]
                                    FlickrDataManager.saveLargeImage(largeImage, fileNamed: imageURL.absoluteString, title: title)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let existingFiles = FlickrDataManager.downloadedFileNames()
        let reducedURLs = flickrFetcher.photoURLs.map { $0.absoluteString }
            .map { $0.replacingOccurrences(of: ":", with: "") }
            .map { $0.replacingOccurrences(of: "/", with: "") }
        for i in 0..<flickrFetcher.photoURLs.count {
            downloadedImages[i] = existingFiles.contains(reducedURLs[i])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        photoOffset = min(view.bounds.size.width, view.bounds.size.height) / ViewSettings.offsetDivider
        headerText = "Fetching recent Flickr photos"
        
        activityIndicator.startAnimating()
        flickrFetcher.fetchPhotos {
            self.activityIndicator.stopAnimating()
            self.headerText = "Tap any photo to download"
            self.collectionView.reloadData()
            self.downloadedImages = Array<Bool>(repeating: false,
                                                count: self.flickrFetcher.photos.count)
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrFetcher.photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentPhotoCell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .black
        cell.collectionPhotoView.image = flickrFetcher.photos[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "CollectionHeader",
                for: indexPath) as! HeaderCollectionReusableView
            header.backgroundColor = .darkGray
            header.headerLabel.text = headerText
            return header
        } else {
            fatalError("wrong header type")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath == selectedCellPath {
            selectedCellPath = nil
        } else {
            selectedCellPath = indexPath
        }
        return false
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath == selectedCellPath {
            let image = flickrFetcher.photos[indexPath.row]
            let aspectRatio = image.aspectRatio()
            let width = collectionView.bounds.size.width - 2 * photoOffset
            let height = width / aspectRatio
            return CGSize(width: width, height: height)
        }
        let numRows = ViewSettings.numberOfPhotosPerRow
        let photoWidth = (view.bounds.size.width - (numRows + 1) * photoOffset) / numRows
        return CGSize(width: photoWidth, height: photoWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: photoOffset, left: photoOffset, bottom: photoOffset, right: photoOffset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return photoOffset
    }
}
