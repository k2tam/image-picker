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
    
    @IBOutlet weak var imgButtonsStackView: UIStackView!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    //Constraints of imgPickerView
    @IBOutlet weak var imgPickerViewHeightConstraint: NSLayoutConstraint!
    
    //Constraints for ic handle
    @IBOutlet weak var icHandleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var icHandleHeightConstraint: NSLayoutConstraint!
    
    //Constraints for stack of edit and send buttons
    @IBOutlet weak var buttonStackHeightConstraint: NSLayoutConstraint!
    
    
    var vm: PhotoPickerViewModel?
    
    private var isPickerFull: Bool = false
    private var isSelectedImg: Bool = false {
        
        didSet {
            if (isSelectedImg){
                buttonStackHeightConstraint.constant = screenHeight * 0.06
                
            }else {
                buttonStackHeightConstraint.constant = 0
                
            }
            
            smoothConstraintTraslation()
        }
    }
    private var isShowImages: Bool = false{
        didSet {
            guard let vm = vm else {
                return
            }
            
            if (vm.items.isEmpty && isShowImages) {
                vm.populatePhotos()
                return
            }
            
            if(isShowImages) {
                performShowPicker()
                
            }else{
                performDismissPicker()
            }
        }
    }
    
    @IBAction func imgEditSendPressed(_ sender: UIButton) {
        if(sender.titleLabel?.text == "Send"){
            performDismissPicker()
        }else if (sender.titleLabel?.text == "Edit"){
            
        }
        
    }
    
    var screenHeight : CGFloat = 0.0
    let itemPerRow: CGFloat =  3.0
    let insetsSection = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
    let distanceBetweenImg: CGFloat = 8.68
    let manager = PHImageManager.default()
    
    private let photoViewModel = PhotoPickerViewModel()
    
    var panGestureRecognizer = UIPanGestureRecognizer()
    
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
        setupEditSendButtons()
        setupVM()
        setupImagePickerView()
        setupImageCollectionView()
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
    
    
    private func setupImageCollectionView() {
        imgCollectionView.delegate = self
        imgCollectionView.dataSource = self
        
        imgCollectionView.register(UINib(nibName: K.Cells.takePhotoCollectionViewCellNibName, bundle: nil), forCellWithReuseIdentifier: K.Cells.takePhotoCollectionViewCellID)
    }
}

//MARK: - UI Methods
extension ViewController {
    
    func setupEditSendButtons() {
        editButton.layer.cornerRadius =  8
        editButton.clipsToBounds = true
        
        sendButton.layer.cornerRadius = 8
        sendButton.clipsToBounds = true
    }
    
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
        
        guard let vm = self.vm else {
            print("No vm")
            return
        }
        
        //Remove all index label
        for assetSelected in vm.assetsSelected {
            if let cellSelected = imgCollectionView.cellForItem(at: IndexPath(row: assetSelected.cellIndex, section: 0)) as? PhotoCollectionViewCell {
                cellSelected.indexLabel = nil
            }
        }
        
        vm.assetsSelected = []
        
        
        icHandleTopConstraint.constant = 0
        icHandleHeightConstraint.constant = 0
        imgPickerViewHeightConstraint.constant = 0
        buttonStackHeightConstraint.constant = 0
        
        smoothConstraintTraslation()
        
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        self.view.bringSubviewToFront(imgPickerView)
        self.view.bringSubviewToFront(imgButtonsStackView)
        
        let translation = sender.translation(in: self.view)
        
        let pointToMedium = self.screenHeight * 0.9
        let pointToFull = self.screenHeight * 0.55
        
        let heightFull = self.screenHeight * 0.9
        let heightMedium = self.screenHeight * 0.5
        
        
        
        DispatchQueue.main.async {
            self.imgPickerViewHeightConstraint.constant -= translation.y
            
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
            
            return cell
        case .takePhoto:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Cells.takePhotoCollectionViewCellID, for: indexPath) as? TakePhotoCollectionViewCell else {
                fatalError("TakePhotoCollectionViewCell not found")
            }
            
            cell.imgView.image = UIImage(named: "cameraIcon")
            
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
            isSelectedImg = true
            
            
            guard let currentCell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else {
                print("Current cell is nil")
                return
            }
            
            guard let vm = self.vm else {
                print("")
                return
            }
            
            vm.toggleAssetSelection(indexCellSelected: indexPath.row, asset: asset, completion: {
                //cells to reload the label
                for cellToReload in vm.assetsSelected {
                    if let cell = collectionView.cellForItem(at: IndexPath(row: cellToReload.cellIndex, section: 0)) as? PhotoCollectionViewCell{
                        
                        //find first index of cellToReload in assetsSelected array
                        
                        
                        if let indexLabel = vm.assetsSelected.firstIndex(where: { assetSelected in
                            assetSelected.cellIndex == cellToReload.cellIndex
                        }){
                            cell.indexLabel = indexLabel
                            
                        }
                        
                        
                    }else{
                        fatalError("Not found cell with index \(indexPath.row)")
                    }
                }
            })
             
            return
        }
        
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    
}

extension ViewController: PhotoPickerModelDelegate {
    
    func unselectSelectedAsset(cellIndex: Int) {
        if let cell = imgCollectionView.cellForItem(at: IndexPath(row: cellIndex, section: 0)) as? PhotoCollectionViewCell{
            cell.indexLabel = nil
        }else {
            fatalError("Not found cell to unselect")
        }
    }
    
    
    func assetsSelectedDidChange() {
        guard let vm = vm else {
            fatalError("VM is nil")
        }
        
        let numOfSelectedIds = vm.assetsSelected.count
        
        
        
        //Show or Hide edit button base on images selected
        if(numOfSelectedIds > 1){
            editButton.isHidden = true
        }else if (numOfSelectedIds == 1) {
            editButton.isHidden = false
        }else if (numOfSelectedIds == 0){
            buttonStackHeightConstraint.constant = 0
            smoothConstraintTraslation()
        }
    }
    
    
    
    func presentSettingAlert(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
        
    }
    
    func didGetImg() {
        imgCollectionView.reloadData()
        performShowPicker()
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
