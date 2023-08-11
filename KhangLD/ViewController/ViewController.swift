//
//  ViewController.swift
//  KhangLD
//
//  Created by k2 tam on 08/08/2023.
//

import UIKit
import Photos
// multi cell tableivew
enum PhotoPickerItem {
    case takePhoto
    case libraryPhoto(PHAsset)
}

class ViewController: UIViewController {
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imgPickerView: UIView!
    @IBOutlet weak var imgCollectionView: UICollectionView!
    @IBOutlet weak var displayImgView: UIImageView!
    @IBOutlet weak var imgPickerViewBottomConstraint: NSLayoutConstraint!
    
    let screenHeight = UIScreen.main.bounds.height
    
    let itemPerRow: CGFloat =  3.0
    let insetsSection = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
    let distanceBetweenImg: CGFloat = 8.68
    let manager = PHImageManager.default()
    
    private var items: [PhotoPickerItem] = []
    private let photoViewModel = PhotoCollectionViewModel()
    
    var panGesture = UIPanGestureRecognizer()

    
    
    var isShowImages: Bool = false {
        didSet {
            if items.isEmpty {
                populatePhotos()
                return
            }
            
            if(isShowImages) {
                animateShowPicker()

            }else{
                animateDismissPicker()
            }
        }
    }
    
    
    var cellSize: CGSize {
        get {

            let insetsLeftRight = insetsSection.left + insetsSection.right
            let distanceBetweenImgs = Double(itemPerRow-1) * distanceBetweenImg
            let availableWidth = view.frame.width - Double(insetsLeftRight) - distanceBetweenImgs
            let width = availableWidth / Double(itemPerRow)
            
            
            return CGSize(width: width, height: width)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePickerView()
        setUpImageCollectionView()
        
    }
    
    @IBAction func imgBtnPressed(_ sender: UIButton) {
        isShowImages = !isShowImages
        
    }
    
    func setupImagePickerView() {
        //Set off set for image picker view
        imgPickerViewBottomConstraint.constant = -(0.5*screenHeight)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        imgPickerView.isUserInteractionEnabled = true
        imgPickerView.addGestureRecognizer(panGesture)
        
    }
    
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        self.view.bringSubviewToFront(imgPickerView)
        let translation = sender.translation(in: self.view)
        imgPickerView.center = CGPoint(x: imgPickerView.center.x + translation.x, y: imgPickerView.center.y + translation.y)
        print(translation.y)
        
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func setUpImageCollectionView() {
        imgCollectionView.delegate = self
        imgCollectionView.dataSource = self
        
        imgCollectionView.register(UINib(nibName: K.Cells.takePhotoCollectionViewCellNibName, bundle: nil), forCellWithReuseIdentifier: K.Cells.takePhotoCollectionViewCellID)
    }
    
    private func populatePhotos(){
        
        
        if #available(iOS 15, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) {[weak self] authStatus in
                if(authStatus == PHAuthorizationStatus.authorized){
                    
                    self?.photoViewModel.fetchAssets { [weak self] imgAssets in
                        DispatchQueue.main.async {
                            
                            self?.items.append(.takePhoto)
                            
                            for imgAsset in imgAssets {
                                self?.items.append(.libraryPhoto(imgAsset))
                                
                            }
                            
                            self?.imgCollectionView.reloadData()
                            self?.animateShowPicker()
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
}


//UI Methods
extension ViewController {
    
    //        self.imgPickerView.constant = 350
    //
    //           UIView.animate(withDuration: 0.2) {
    //               self.view.layoutIfNeeded()
    //           }
    
    func animateShowPicker() {
        self.imgPickerViewBottomConstraint.constant = 0
        
       UIView.animate(withDuration: 0.2) {
           self.view.layoutIfNeeded()
       }

    }
    
    func animateDismissPicker() {
        self.imgPickerViewBottomConstraint.constant = -(screenHeight*0.5)
        
        

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
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
        
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.items[indexPath.row] {
        case .libraryPhoto(let asset):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCellId", for: indexPath) as? PhotoCollectionViewCell else {
                fatalError("ImageCollectionViewCellId not found")
            }
            
            // Cancel any previous request for this cell
            cell.cancelImageRequest()
            
            //Add thumbnail img to cells
            let imgRequestID = manager.requestImage(for: asset, targetSize: CGSize(width: 450 , height: 450), contentMode: .aspectFill, options: nil) { [weak cell] image, _ in
                DispatchQueue.main.async {
                    
                    cell?.photoImageView.image = image
                    
                }
            }
            
            cell.imageRequestID = imgRequestID  // Store the request ID in the cell

            
            cell.layer.cornerRadius = 8.0
            cell.layer.masksToBounds = true
            
            return cell
        case .takePhoto:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Cells.takePhotoCollectionViewCellID, for: indexPath) as? TakePhotoCollectionViewCell else {
                fatalError("TakePhotoCollectionViewCell not found")
            }
            
            cell.imgView.image = UIImage(named: "cameraIcon")
            cell.layer.cornerRadius = 8.0
            cell.layer.masksToBounds = true
            
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insetsSection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insetsSection.left
    }
}


extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.items[indexPath.row] {
        case .takePhoto:
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            present(picker, animated: true)
            return
        case .libraryPhoto(let asset):
            
            manager.requestImage(for: asset, targetSize: CGSize(width: displayImgView.frame.width , height: displayImgView.frame.height), contentMode: .aspectFill, options: nil) { [weak self] image, _ in
                DispatchQueue.main.async {
                    
                    self?.displayImgView.image = image
                }
            }
            
            animateDismissPicker()
            
            return
        }
        
    }
}

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        picker.dismiss(animated: true)
        animateDismissPicker()
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{
            return
        }
        
        displayImgView.image = image
    }
}

