//
//  DetailMachineDataViewController.swift
//  ImageMachine
//
//  Created by Fereizqo Sulaiman on 24/04/20.
//  Copyright © 2020 Fereizqo Sulaiman. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos
import CoreData

protocol detailMachineDelegate {
    // Protocol for update data
    func updateData(content: [String])
}

class DetailMachineDataViewController: UIViewController {
    
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var machineImageButton: UIButton!
    @IBOutlet weak var deleteImageButton: UIButton!
    
    var machine: Machines?
    var imagePHAsset = [PHAsset]()
    var photoArray = [UIImage]()
    var detailMachine = [ "123", "Test", "Type A", "4123","22/12/2020" ]
    let content = [ "ID", "Name", "Type", "QR Code","Last maintenance date" ]
    var editVc: EditViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        detailCollectionView.delegate = self
        detailCollectionView.dataSource = self
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.allowsSelection = false
        detailTableView.isScrollEnabled = false
        self.detailTableView.tableFooterView = UIView()
        
        // Retrieve certain machine data details
        guard let selectedMachine = machine else { return }
        detailMachine.removeAll()
        detailMachine = coreDataRequest.shared.retrieveCertainMachine(id:selectedMachine.id)
        detailTableView.reloadData()
    }
    
    @IBAction func editBarButtonTapped(_ sender: UIBarButtonItem) {
        // Edit bar action
        
        // Initiate go to edit navigation controller
        let nc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editNavViewController") as! UINavigationController
        nc.modalPresentationStyle = .fullScreen
        nc.modalTransitionStyle = .crossDissolve
        // Passing data
        let vc = nc.viewControllers.first as! EditViewController
        vc.machine = machine
        vc.detailMachineDelegates = self
        
        self.present(nc, animated: true, completion: nil)
    }
    
    @IBAction func machineImageButtonTapped(_ sender: UIButton) {
        // Add machine image button action
        
        // Initiate image picker
        let imagePicker = ImagePickerController(selectedAssets: imagePHAsset)
        
        // Image picker config
        imagePicker.settings.selection.max = 10
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.selection.unselectOnReachingMax = true

        self.presentImagePicker(imagePicker,select: { (asset) in
            // Select asset action
            if self.imagePHAsset.count < 10 {
                self.imagePHAsset.append(asset)
            }
        }, deselect: { (asset) in
            // Deselect asset action
            self.imagePHAsset = self.imagePHAsset.filter { $0 != asset }
        }, cancel: { (assets) in
            // Cancel action
            for asset in assets {
                self.imagePHAsset = self.imagePHAsset.filter { $0 != asset }
            }
        }, finish: { (assets) in
            // Done action
            self.convertAssetToImages()
        })
    }
    
    @IBAction func deleteImageButtonTapped(_ sender: UIButton) {
        // Delete image button action
        
        // Make alert promp
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure want to delete the pho?", preferredStyle: .actionSheet)
        // Delete action
        alert.addAction(UIAlertAction(title: "Delete photo", style: .destructive, handler: { action in
            // Remove all photo data and reload collection view
            self.photoArray.removeAll()
            self.imagePHAsset.removeAll()
            self.detailCollectionView.reloadData()
            alert.dismiss(animated: true, completion: nil)
        }))
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        // Present alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func convertAssetToImages() -> Void {
        // Make sure the photo array is'nt ovewrite
        self.photoArray.removeAll()
        if imagePHAsset.count != 0 {
            for i in 0 ..< imagePHAsset.count {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                
                // PHImage config
                option.isSynchronous = true
                option.deliveryMode = .highQualityFormat
                option.resizeMode = .exact
                
                // Convert PHAsset into UIImage
                manager.requestImage(for: imagePHAsset[i], targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: option, resultHandler: {(result, info) -> Void in
                    thumbnail = result!
                })
                self.photoArray.append(thumbnail)
            }
            // Reload collection view
            detailCollectionView.reloadData()
        }
        
    }
}

// MARK: - TableView data source
extension DetailMachineDataViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return number of row
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell
        let cell = detailTableView.dequeueReusableCell(withIdentifier: "detailMachineCell", for: indexPath) as! DetailMachineDataTableViewCell
        
        cell.titleLabel.text = content[indexPath.row]
        cell.detailLabel.text = detailMachine[indexPath.row]
        cell.detailLabel.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        cell.detailLabel.numberOfLines = 0
        
        return cell
    }
}

// MARK: - CollectionView data source

extension DetailMachineDataViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Configure the cell
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "detailCollectionCell", for: indexPath) as! DetailMachineDataCollectionViewCell
        cell.machineImage.image = photoArray[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Configure the layout
        
        // 5 items per section
        let size = view.frame.size.width/6
        return CGSize(width: size, height: size)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Do action when selecting item
        
        // Initiate go to image navigation controller
        let nc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageNavViewController") as! UINavigationController
        nc.modalPresentationStyle = .overCurrentContext
        nc.modalTransitionStyle = .crossDissolve
        // Pass image data
        let vc = nc.viewControllers.first as! ImageViewController
        vc.image = photoArray[indexPath.row]
        
        self.present(nc, animated: true, completion: nil)
    }
}

// MARK: - Protocol delegate
extension DetailMachineDataViewController: detailMachineDelegate {
    func updateData(content: [String]) {
        detailMachine.removeAll()
        detailMachine.append(contentsOf: content)
        detailTableView.reloadData()
    }
}
