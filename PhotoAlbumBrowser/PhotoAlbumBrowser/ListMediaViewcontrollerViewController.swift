//
//  ListMediaViewcontrollerViewController.swift
//  PhotoAlbumBrowser
//
//  Created by  on 9/23/15.
//  Copyright © 2015 KZ. All rights reserved.
//

import UIKit
import Photos

class ListMediaViewcontrollerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    //views
    @IBOutlet weak var clvListMedia: UICollectionView!
    
    
    //data
    var assetsFetchResults : PHFetchResult = PHFetchResult()
    var assetCollection : PHAssetCollection = PHAssetCollection()
    let imageManager : PHCachingImageManager = PHCachingImageManager()
    var AssetGridThumbnailSize: CGSize = CGSizeZero
    
    //MARK - View Utils
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let scale = UIScreen.mainScreen().scale
        let cellSize = (clvListMedia.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        
        AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    //MARK - CollectionView Delegate - Datasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsFetchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let strCellIdentifier = "MediaCollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(strCellIdentifier, forIndexPath: indexPath) as! MediaCollectionViewCell
        
        // Increment the cell's tag
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let asset = assetsFetchResults[indexPath.item]
        imageManager.requestImageForAsset(asset as! PHAsset, targetSize: AssetGridThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, dict) -> Void in
            // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
            if (cell.tag == currentTag) {
                cell.settingCellContent(image!)
            }
        }
        
        return cell
    }
    
    //MARK - View Utils
    func setData () {
    
    }
}
