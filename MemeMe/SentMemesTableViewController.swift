//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Borys Tkachenko on 10/6/17.
//  Copyright © 2017 Borys Tkachenko. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {
    let reusableCellId = "SentMemeTableViewCell"
    
    var memes = [Meme]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("--",memes.count)
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reusableCellId) as! SentMemeTableViewCell
        cell.topTextLabel.text = memes[indexPath.row].topText
        cell.bottomTextLabel.text = memes[indexPath.row].bottomText
        cell.memeImageView.image = memes[indexPath.row].memedImage
        return cell
    }

}
