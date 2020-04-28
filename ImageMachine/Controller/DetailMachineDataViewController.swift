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
    func updateData(content: [String])
}

class DetailMachineDataViewController: UIViewController {
    
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var machineImageButton: UIButton!
    @IBOutlet weak var machineImageView: UIImageView!
    
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
        self.detailTableView.tableFooterView = UIView()
        
        guard let selectedMachine = machine else { return }
        detailMachine.removeAll()
        detailMachine = coreDataRequest.shared.retrieveCertainMachine(id:selectedMachine.id)
        detailTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func sendMachineData(content: [String]) {
        detailMachine.removeAll()
        detailMachine = content
        print("sss")
    }
    
    @IBAction func editBarButtonTapped(_ sender: UIBarButtonItem) {
        let nc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editNavViewController") as! UINavigationController
        nc.modalPresentationStyle = .fullScreen
        nc.modalTransitionStyle = .crossDissolve
        let vc = nc.viewControllers.first as! EditViewController
        vc.machine = machine
        vc.detailMachineDelegates = self
        self.present(nc, animated: true, completion: nil)
    }
    
    @IBAction func machineImageButtonTapped(_ sender: UIButton) {
        let allAssets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        

        allAssets.enumerateObjects({ (asset, idx, stop) -> Void in
//            self.imagePHAsset.append(asset)
        })
        
        print("even assets: \(imagePHAsset.count)")
        
        let imagePicker = ImagePickerController(selectedAssets: imagePHAsset)
        imagePicker.settings.selection.max = 10
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.selection.unselectOnReachingMax = true

        self.presentImagePicker(imagePicker,select: { (asset) in
        }, deselect: { (asset) in
            
        }, cancel: { (assets) in
            
        }, finish: { (assets) in
            for i in 0 ..< assets.count {
                self.imagePHAsset.append(assets[i])
            }
            self.convertAssetToImages()
        }, completion: {
            print("photos selected")
        })
    }
    
    
    func convertAssetToImages() -> Void {
        if imagePHAsset.count != 0 {
            for i in 0 ..< imagePHAsset.count {
                let size = view.frame.size.width/6
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                
                option.isSynchronous = true
                manager.requestImage(for: imagePHAsset[i], targetSize: CGSize(width: size, height: size), contentMode: .aspectFill, options: option, resultHandler: {(result, info) -> Void in
                    thumbnail = result!
                })
                
                let imageData = thumbnail.jpegData(compressionQuality: 0.7)
                let newImageData = UIImage(data: imageData!)
                
                self.photoArray.append(newImageData! as UIImage)
            }
            detailCollectionView.reloadData()
        }
        
    }
}

extension DetailMachineDataViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = detailTableView.dequeueReusableCell(withIdentifier: "detailMachineCell", for: indexPath) as! DetailMachineDataTableViewCell
//        cell.detailLabel.font = UIFont.init(name: cell.detailLabel.font.fontName, size: 15)
        
        cell.titleLabel.text = content[indexPath.row]
        cell.detailLabel.text = detailMachine[indexPath.row]
        cell.detailLabel.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        cell.detailLabel.numberOfLines = 0
        
        return cell
    }
}

// CollectionView

extension DetailMachineDataViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "detailCollectionCell", for: indexPath) as! DetailMachineDataCollectionViewCell
        cell.machineImage.image = photoArray[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = view.frame.size.width/6
        return CGSize(width: size, height: size)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageNavViewController") as! UINavigationController
        nc.modalPresentationStyle = .overCurrentContext
        nc.modalTransitionStyle = .crossDissolve
        let vc = nc.viewControllers.first as! ImageViewController
        vc.image = photoArray[indexPath.row]
        self.present(nc, animated: true, completion: nil)
    }
}

extension DetailMachineDataViewController: detailMachineDelegate {
    func updateData(content: [String]) {
        detailMachine.removeAll()
        detailMachine.append(contentsOf: content)
        detailTableView.reloadData()
    }
}
