//
//  CodeReaderViewController.swift
//  ImageMachine
//
//  Created by Fereizqo Sulaiman on 25/04/20.
//  Copyright © 2020 Fereizqo Sulaiman. All rights reserved.
//

import UIKit
import AVFoundation

class CodeReaderViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var machinesArray: [Machines] = []
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Get the back camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // Set the input device into current session
            captureSession.addInput(input)
            
            // Initialize AVCaptureMetaDataOutput and set it as the output devices to the capture session.
            let captureMetaDataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetaDataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetaDataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch  {
            print("There is an input error: \(error)")
            return
        }
        
        // Initialize the video preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture
        captureSession.startRunning()
        
        // Move the message to the front
        view.bringSubviewToFront(messageLabel)
        
        
        // Initialize QRcode frame to highlight the QRcode
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup every loading the view.
        
        // Update machine array data
        machinesArray = coreDataRequest.shared.retrieve()
    }
    
    func qrCodeMatch(machine: Machines) {
        // Make alert promp
        let alertPrompt = UIAlertController(title: "Detail Machine Data", message: "You're going to see \(machine.name) detail machine data ", preferredStyle: .actionSheet)
        
        // Confirm action
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailMachineData") as! DetailMachineDataViewController
            vc.modalPresentationStyle = .popover
            vc.modalTransitionStyle = .crossDissolve
            vc.machine = machine
            self.present(vc, animated: true, completion: nil)
        })
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        // Present alert
        present(alertPrompt, animated: true, completion: nil)
    }

}

extension CodeReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if metadataObject array is not nil
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadataObject
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // If found metadata is equal to the QR code metadata
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                
                // Go to detailPage if found machine's QR code number
                let stringMetadata = metadataObj.stringValue
                let intMetadata = (stringMetadata as NSString?)?.integerValue
                
                for i in machinesArray {
                    if i.qrCode == intMetadata {
                        qrCodeMatch(machine: i)
                        print("boom")
                    }
                }
                
            }
        }
        
    }
}
