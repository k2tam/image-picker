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
    
    let circleIndexLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))

    var indexLabel: Int? {
        didSet {
            if let indexSelected = indexLabel {
                
                //configure circleIndexLabel for the current cell and add to this cell
                circleIndexLabel.center = self.contentView.center
                circleIndexLabel.textAlignment = .center
                circleIndexLabel.backgroundColor = UIColor(red: 60/255, green: 77/255, blue: 110/255, alpha: 1.0)
                circleIndexLabel.textColor = .white
                circleIndexLabel.font = UIFont.boldSystemFont(ofSize: 14)
                circleIndexLabel.layer.cornerRadius = circleIndexLabel.frame.size.width / 2
                circleIndexLabel.clipsToBounds = true
                circleIndexLabel.text = String(indexSelected+1)
                
                self.addSubview(circleIndexLabel)
            }else{
                circleIndexLabel.removeFromSuperview()
            }
        }
    }
    
    var imageRequestID: PHImageRequestID = PHInvalidImageRequestID //ID of uninitialized imgRequest id
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true

    }
    override func prepareForReuse() {
        
    }
    
    func cancelImageRequest() {
            if imageRequestID != PHInvalidImageRequestID {
                PHImageManager.default().cancelImageRequest(imageRequestID)
                imageRequestID = PHInvalidImageRequestID
            }
        }
  
}
