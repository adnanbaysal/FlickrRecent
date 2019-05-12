//
//  TableViewController.swift
//  PhotosList
//
//  Created by Adnan Baysal on 11.05.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, TableViewCellDelegate {
    
    private var photos: [UIImage] = []
    private var titles: [String] = []
    private var fileURLs: [URL] = []
    
    func updateTable() {
        loadImages()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
    }
    
    private func loadImages() {
        (photos, titles, fileURLs) = FlickrDataManager.downloadedPhotos()
    }
    
    // MARK: - TableViewCellDelegate methods
    func didRequestDelete(_ cell: TableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let row = indexPath.row
            var fileURL = fileURLs[row]
            FlickrDataManager.deleteFile(fileURL)
            fileURL = URL(string: fileURL.absoluteString.replacingOccurrences(of: ".jpg", with: ".txt"))!
            FlickrDataManager.deleteFile(fileURL)
            fileURLs.remove(at: row)
            photos.remove(at: row)
            titles.remove(at: row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadedItemCell", for: indexPath) as! TableViewCell
        cell.tableCellImageView.image = photos[indexPath.row]
        cell.tableCellLabel.text = titles[indexPath.row]
        cell.delegate = self
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? TableViewCell {
            let destination = segue.destination as! ImageViewController
            let indexPath = tableView.indexPath(for: cell)!
            let image = photos[indexPath.row]
            destination.image = image
        }
    }
    
}
