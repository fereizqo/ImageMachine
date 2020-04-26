//
//  ImageViewController.swift
//  ImageMachine
//
//  Created by Fereizqo Sulaiman on 26/04/20.
//  Copyright © 2020 Fereizqo Sulaiman. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var machineImage: UIImageView!
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        machineImage.image = image
    }
    
    
    @IBAction func backBarButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
