//
//  ImageViewController.swift
//  PhotosList
//
//  Created by Adnan Baysal on 12.05.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var downloadedBigImageView: UIImageView!
    
    var image: UIImage?
    
    private let minZoom: CGFloat = 0.5
    private let maxZoom: CGFloat = 4.0
    private var currentZoom: CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadedBigImageView.backgroundColor = .black
        downloadedBigImageView.image = image
    }

    @IBAction func zoomImage(_ sender: UIPinchGestureRecognizer) {
        currentZoom += (sender.scale - 1) * 0.3 // to slow down zoom amount
        if currentZoom < minZoom {
            currentZoom = minZoom
        } else if currentZoom > maxZoom {
            currentZoom = maxZoom
        }
        downloadedBigImageView.transform = CGAffineTransform(scaleX: currentZoom, y: currentZoom)
    }
}
