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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadedBigImageView.backgroundColor = .black
        downloadedBigImageView.image = image
    }

}
