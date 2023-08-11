//
//  PhotoCollectionViewCell.swift
//  KhangLD
//
//  Created by k2 tam on 08/08/2023.
//

import UIKit
import Foundation
import Photos

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    var imageRequestID: PHImageRequestID = PHInvalidImageRequestID //ID of uninitialized imgRequest id

    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func cancelImageRequest() {
            if imageRequestID != PHInvalidImageRequestID {
                PHImageManager.default().cancelImageRequest(imageRequestID)
                imageRequestID = PHInvalidImageRequestID
            }
        }
  
}
