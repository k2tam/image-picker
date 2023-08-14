//
//  PhotoCollectionVM.swift
//  KhangLD
//
//  Created by k2 tam on 09/08/2023.
//

import Foundation
import Photos
import UIKit

protocol PhotoPickerDelegate {
    func didGetImg() -> Void
    func presentSettingAlert(alert: UIAlertController) -> Void
}

enum PhotoPickerItem {
    case takePhoto
    case libraryPhoto(PHAsset)
}

class PhotoPickerViewModel: NSObject, PHPhotoLibraryChangeObserver {
    //    private var imageAssets: [PHAsset] = []
    
    var items: [PhotoPickerItem] = []
    var delegate: PhotoPickerDelegate?
    
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func populatePhotos(){
        if #available(iOS 15, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) {[weak self] authStatus in
                if(authStatus == PHAuthorizationStatus.authorized){
                    
                    self?.fetchAssets { [weak self] imgAssets in
                        DispatchQueue.main.async {
                            
                            self?.items.append(.takePhoto)
                            
                            for imgAsset in imgAssets {
                                self?.items.append(.libraryPhoto(imgAsset))
                                
                            }
                            
                            self?.delegate?.didGetImg()
                            
                        }
                    }
                }else if(authStatus == PHAuthorizationStatus.denied){
                    DispatchQueue.main.async {
                        self?.showSettingsAlert()
                        
                    }
                }
            }
        }else{
            
        }
    }
    
    func fetchAssets(completion: @escaping ([PHAsset]) -> Void) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchLimit = 50 // Fetch up to 50 images at a time (you can adjust this based on your needs)
        var fetchIndex = 0 // Initialize the fetchIndex to 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            var assets: [PHAsset] = []
            
            
            let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
            let totalCount = fetchResult.count
            
            while true {
                
                
                // Check if there are no more assets to fetch
                if fetchIndex >= totalCount {
                    break
                }
                
                // Calculate the range for the current batch
                let endIndex = min(fetchIndex + fetchLimit, totalCount)
                
                // Enumerate through the assets in the current batch
                for index in fetchIndex..<endIndex {
                    let asset = fetchResult.object(at: index)
                    assets.append(asset)
                }
                
                
                // Update fetchIndex for the next batch
                fetchIndex = endIndex
                
            }
            //Once all assets are fetched, update the UI on the main thread
            completion(assets)
            
        }
        
    }
    
    
    // Fetch assets again when photo lybrary did change
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Handle photo library changes here
        // You can call your existing fetchAssets method to update items
        // Reload your collection view or update UI accordingly
        fetchAssets { [weak self] imgAssets in
            DispatchQueue.main.async {
                self?.items.removeAll()
                self?.items.append(.takePhoto)
                
                for imgAsset in imgAssets {
                    self?.items.append(.libraryPhoto(imgAsset))
                }
                
                self?.delegate?.didGetImg()
            }
        }
    }
    
    func showSettingsAlert() {
        let alert = UIAlertController(
            title: "Permission Required",
            message: "Please allow access to your photos in Settings to use this feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        })
        
        
        self.delegate?.presentSettingAlert(alert: alert)
        
    }
}

