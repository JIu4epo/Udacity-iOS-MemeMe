//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Borys Tkachenko on 10/6/17.
//  Copyright © 2017 Borys Tkachenko. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    let reusableCellId = "SentMemeCollectionViewCell"
    let detailViewControllerId = "DetailViewController"
    let space: CGFloat = 3.0
    
    var memes = [Meme]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        
        let widthDimension = (view.frame.size.width - (2 * space)) / 3.0

        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: widthDimension, height: widthDimension)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        
        self.collectionView?.reloadData()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController = self.storyboard!.instantiateViewController(withIdentifier: detailViewControllerId) as! DetailViewController
        detailViewController.meme = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailViewController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableCellId, for: indexPath) as! SentMemeCollectionViewCell
        let meme = memes[indexPath.row]
        
        cell.imageView.image = meme.memedImage
        
        return cell
    }
    
    
    
}
