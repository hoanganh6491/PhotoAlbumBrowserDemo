//
//  MediaCollectionViewCell.swift
//  PhotoAlbumBrowser
//
//  Created by  on 9/23/15.
//  Copyright © 2015 KZ. All rights reserved.
//

import UIKit

class MediaCollectionViewCell: UICollectionViewCell {
    
    //view
    @IBOutlet weak var imgvCellImage: UIImageView!
    
    //data
    var imgCellContent : UIImage?
    
    //MARK - View Utils
    func settingCellContent (image : UIImage) {
        imgCellContent = image
        imgvCellImage.image = imgCellContent
    }
}
