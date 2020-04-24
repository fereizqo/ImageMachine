//
//  DetailMachineDataViewController.swift
//  ImageMachine
//
//  Created by Fereizqo Sulaiman on 24/04/20.
//  Copyright © 2020 Fereizqo Sulaiman. All rights reserved.
//

import UIKit

class DetailMachineDataViewController: UIViewController {

    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    let content = [ "ID", "Name", "Type", "QR Code","Last maintenance date" ]
    let dummy = [ "123", "Test", "Type A", "4123","22/12/2020" ]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        detailTableView.delegate = self
        detailTableView.dataSource = self
        self.detailTableView.tableFooterView = UIView()
    }
    
    @IBAction func editBarButtonTapped(_ sender: UIBarButtonItem) {
        let nc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editNavViewController") as! UINavigationController
        nc.modalPresentationStyle = .fullScreen
        nc.modalTransitionStyle = .crossDissolve
        self.present(nc, animated: true, completion: nil)
    }
}

extension DetailMachineDataViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailTableView.dequeueReusableCell(withIdentifier: "detailMachineCell", for: indexPath) as! DetailMachineDataTableViewCell
        
        cell.titleLabel.text = content[indexPath.row]
        cell.detailLabel.text = dummy[indexPath.row]
        
        return cell
    }
}
