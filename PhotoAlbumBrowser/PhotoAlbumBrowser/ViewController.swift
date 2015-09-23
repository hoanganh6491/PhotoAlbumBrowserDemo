//
//  ViewController.swift
//  PhotoAlbumBrowser
//
//  Created by  on 9/23/15.
//  Copyright © 2015 KZ. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PHPhotoLibraryChangeObserver {

    //views
    @IBOutlet weak var tbvOrderList: UITableView!
    
    
    //data
    var arrAlbumCategory = ["AllPhotos", "Smart Album", "Album"]
    var arrMediaContents : [PHFetchResult] = []
    
    enum TableViewCellIdentifier : String {
        case AllPhotos  = "AllPhotosCellIdentifier"
        case SmartAlbum = "SmartAlbumCellIdentifier"
        case Album      = "AlbumCellIdentifier"
    }
    
    enum NaviSegueIdentifier : String {
        case ShowAllPhoto   = "showAllPhoto"
        case ShowByOrder    = "showByOrder"
    }
    
    //MARK - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        gettingAllMediaFile()
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK - Navigation Controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == NaviSegueIdentifier.ShowAllPhoto.rawValue {
            let listMediaViewController = segue.destinationViewController as! ListMediaViewcontrollerViewController
            
            // Fetch all assets, sorted by date created.
            let options :PHFetchOptions = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            listMediaViewController.assetsFetchResults = PHAsset.fetchAssetsWithOptions(options)
        } else if segue.identifier == NaviSegueIdentifier.ShowByOrder.rawValue {
            let listMediaViewController = segue.destinationViewController as! ListMediaViewcontrollerViewController
            
            let indexPath : NSIndexPath = sender as! NSIndexPath
            let fetchResult = arrMediaContents[indexPath.section - 1]
            let collection = fetchResult[indexPath.row]
            if collection.isKindOfClass(PHAssetCollection) {
                let assetCollection = collection as! PHAssetCollection
                let assetsFetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
                
                listMediaViewController.assetsFetchResults = assetsFetchResult
                listMediaViewController.assetCollection = assetCollection
            }
        }
    }
    
    //MARK - TableView Delegate - Datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return arrAlbumCategory.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            let fetchResult = arrMediaContents[section - 1];
            return fetchResult.count
        } else {
            let fetchResult = arrMediaContents[section - 1];
            return fetchResult.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var strCellIdentifier = ""
        if indexPath.section == 0 {
            strCellIdentifier = TableViewCellIdentifier.AllPhotos.rawValue
            let cell = tableView.dequeueReusableCellWithIdentifier(strCellIdentifier, forIndexPath: indexPath)
            
            cell.textLabel?.text = "All Photos"
            
            return cell
        } else if indexPath.section == 1 {
            strCellIdentifier = TableViewCellIdentifier.SmartAlbum.rawValue
            let cell = tableView.dequeueReusableCellWithIdentifier(strCellIdentifier, forIndexPath: indexPath)
            
            let fetchResult = arrMediaContents[indexPath.section - 1]
            let collection = fetchResult[indexPath.row]
            cell.textLabel?.text = collection.localizedTitle
            
            return cell
        } else {
            strCellIdentifier = TableViewCellIdentifier.Album.rawValue
            let cell = tableView.dequeueReusableCellWithIdentifier(strCellIdentifier, forIndexPath: indexPath)
            
            let fetchResult = arrMediaContents[indexPath.section - 1]
            let collection = fetchResult[indexPath.row]
            cell.textLabel?.text = collection.localizedTitle
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrAlbumCategory[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tbvOrderList.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            self.performSegueWithIdentifier(NaviSegueIdentifier.ShowAllPhoto.rawValue, sender: indexPath)
        } else {
            self.performSegueWithIdentifier(NaviSegueIdentifier.ShowByOrder.rawValue, sender: indexPath)
        }
    }
    //MARK - View Utils

    
    //MARK - PhotosFramework handler
    func gettingAllMediaFile () {
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.AlbumRegular, options: nil)
        arrMediaContents.append(smartAlbums)
        
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
        arrMediaContents.append(topLevelUserCollections)
        
        tbvOrderList.reloadData()
    }
    
    
    //MARK - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(changeInstance: PHChange) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let updatedCollectionsFetchResults: NSMutableArray = []
            for collectionsFetchResult in self.arrMediaContents {
                let changeDetails : PHFetchResultChangeDetails = changeInstance.changeDetailsForFetchResult(collectionsFetchResult)!
                if changeDetails.hasIncrementalChanges {
                    if updatedCollectionsFetchResults.count > 0 {
                        updatedCollectionsFetchResults.removeAllObjects()
                    }
                    updatedCollectionsFetchResults.addObjectsFromArray(self.arrMediaContents)
                    updatedCollectionsFetchResults.replaceObjectAtIndex(self.arrMediaContents.indexOf(collectionsFetchResult)!, withObject: changeDetails.fetchResultAfterChanges)
                }
            }
            if updatedCollectionsFetchResults.count > 0 {
                self.arrMediaContents.removeAll(keepCapacity: false)
                for obj in updatedCollectionsFetchResults {
                    self.arrMediaContents.append(obj as! PHFetchResult)
                }
                self.tbvOrderList.reloadData()
            }
        }
    }
}

