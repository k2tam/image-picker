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
    
    private let transparentView = UIView()

    
    
    var indexLabel: Int? {
        didSet {
            if let indexSelected = indexLabel {
                
                transparentView.frame = contentView.bounds
                transparentView.backgroundColor = UIColor(white: 1, alpha: 0.5)
                
                let circleIndexLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                circleIndexLabel.center = transparentView.center
                circleIndexLabel.textAlignment = .center
                circleIndexLabel.backgroundColor = UIColor(red: 60/255, green: 77/255, blue: 110/255, alpha: 1.0)
                circleIndexLabel.textColor = .white
                circleIndexLabel.font = UIFont.boldSystemFont(ofSize: 14)
                circleIndexLabel.layer.cornerRadius = circleIndexLabel.frame.size.width / 2
                circleIndexLabel.clipsToBounds = true
                circleIndexLabel.text = String(indexSelected + 1)
                
                transparentView.addSubview(circleIndexLabel)
                contentView.addSubview(transparentView)
            }else{
                transparentView.removeFromSuperview()
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
