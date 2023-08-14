//
//  ViewController.swift
//  KhangLD
//
//  Created by k2 tam on 08/08/2023.
//

import UIKit
import Photos
// multi cell tableivew


class ViewController: UIViewController {
    @IBOutlet weak var imgPickerView: UIView!
    @IBOutlet weak var imgCollectionView: UICollectionView!
    @IBOutlet weak var displayImgView: UIImageView!
    
    var vm: PhotoPickerViewModel?
    private var isPickerFull: Bool = false
    
    
    //Constraints of imgPickerView
    @IBOutlet weak var imgPickerViewHeightConstraint: NSLayoutConstraint!
    
    //Constraints for ic handle
    @IBOutlet weak var icHandleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var icHandleHeightConstraint: NSLayoutConstraint!
    
    
    var screenHeight : CGFloat = 0.0
    let itemPerRow: CGFloat =  3.0
    let insetsSection = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
    let distanceBetweenImg: CGFloat = 8.68
    let manager = PHImageManager.default()
    
    private var items: [PhotoPickerItem] = []
    private let photoViewModel = PhotoPickerViewModel()
    
    
    var panGestureRecognizer = UIPanGestureRecognizer()
    private var isShowImages: Bool = false{
        didSet {
            guard let vm = vm else {
                return
            }
            
            if (vm.items.isEmpty && isShowImages) {
                vm.populatePhotos()
                //                populatePhotos()
                return
            }
            
            if(isShowImages) {
                performShowPicker()
                
            }else{
                performDismissPicker()
            }
        }
    }
    
    
    private var cellSize: CGSize {
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
        screenHeight = view.frame.size.height
        setupVM()
        setupImagePickerView()
        setUpImageCollectionView()
        
    }
    
    private func setupVM(){
        vm = PhotoPickerViewModel()
        vm?.delegate = self
    }
    
    @IBAction func imgBtnPressed(_ sender: UIButton) {
        isShowImages = !isShowImages
    }
    
    private func setupImagePickerView() {
        
        
        imgPickerViewHeightConstraint.constant = 0
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        panGestureRecognizer.delegate = self
        
        imgPickerView.addGestureRecognizer(panGestureRecognizer)
        
        
        imgPickerView.isUserInteractionEnabled = true
        imgPickerView.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        self.view.bringSubviewToFront(imgPickerView)
        let translation = sender.translation(in: self.view)
                
        let pointToMedium = self.screenHeight * 0.9
        let pointToFull = self.screenHeight * 0.55
        
        let heightFull = self.screenHeight * 0.9
        let heightMedium = self.screenHeight * 0.5
        
        
        
        DispatchQueue.main.async {
            self.imgPickerViewHeightConstraint.constant -= translation.y
            
            
            if(sender.state == .ended){
                print("Finger on")
            }
            
            //Ensure imgPickerView in min height
            if(self.imgPickerViewHeightConstraint.constant < heightMedium){
                self.imgPickerViewHeightConstraint.constant = heightMedium
                return
            }
            
            //Ensure imgPickerView in max height
            if(self.imgPickerViewHeightConstraint.constant > heightFull){
                self.imgPickerViewHeightConstraint.constant = heightFull
                return
            }
 
            
            if(self.imgPickerViewHeightConstraint.constant > pointToFull  && !self.isPickerFull) {
                self.imgPickerViewHeightConstraint.constant = heightFull
                self.isPickerFull = true
                
                self.smoothConstraintTraslation()
                
                return
            }
            
            
            if(self.imgPickerViewHeightConstraint.constant < pointToMedium && self.isPickerFull ){
                self.imgPickerViewHeightConstraint.constant = self.screenHeight * 0.5
                self.isPickerFull = false
                
                self.smoothConstraintTraslation()
                
                return
                
            }
        }
        
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    private func setUpImageCollectionView() {
        imgCollectionView.delegate = self
        imgCollectionView.dataSource = self
        
        imgCollectionView.register(UINib(nibName: K.Cells.takePhotoCollectionViewCellNibName, bundle: nil), forCellWithReuseIdentifier: K.Cells.takePhotoCollectionViewCellID)
    }
    
    
}

//UI Methods
extension ViewController {
    
    func smoothConstraintTraslation() {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    func performShowPicker() {
        icHandleTopConstraint.constant = 5
        icHandleHeightConstraint.constant = 7
        
        
        imgPickerViewHeightConstraint.constant = screenHeight/2
        
        smoothConstraintTraslation()
        
        
    }
    
    func performDismissPicker() {
        icHandleTopConstraint.constant = 0
        icHandleHeightConstraint.constant = 0
        
        imgPickerViewHeightConstraint.constant = 0
        
        smoothConstraintTraslation()
        
    }
    
    
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = vm?.items[indexPath.row] else {
            return UICollectionViewCell()
        }
        
        switch item {
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

extension ViewController: UIGestureRecognizerDelegate {
    
}

extension ViewController: PhotoPickerDelegate {
    
    
    func presentSettingAlert(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func didGetImg() {
        
        imgCollectionView.reloadData()
        performShowPicker()
    }
}


extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = vm?.items[indexPath.row] else {
            return
        }
        
        switch item {
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
            
            performDismissPicker()
            
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
        performDismissPicker()
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{
            return
        }
        
        displayImgView.image = image
    }
}



