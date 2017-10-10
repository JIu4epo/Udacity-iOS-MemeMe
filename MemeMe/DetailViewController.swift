//
//  DetailViewController.swift
//  MemeMe
//
//  Created by Borys Tkachenko on 10/10/17.
//  Copyright © 2017 Borys Tkachenko. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        imageView.image = meme.memedImage
    }


}
