//
//  PhotoCollectionVM.swift
//  KhangLD
//
//  Created by k2 tam on 09/08/2023.
//

import Foundation
import Photos

class PhotoCollectionViewModel {
    //    private var imageAssets: [PHAsset] = []
    
    var items: [PhotoPickerItem] = []
    
    
    

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
}
