//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Borys Tkachenko on 10/6/17.
//  Copyright © 2017 Borys Tkachenko. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UIViewController {

    var memes = [Meme]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
    }

}