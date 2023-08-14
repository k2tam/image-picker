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

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true

    }
    
    
    func cancelImageRequest() {
            if imageRequestID != PHInvalidImageRequestID {
                PHImageManager.default().cancelImageRequest(imageRequestID)
                imageRequestID = PHInvalidImageRequestID
            }
        }
  
}
