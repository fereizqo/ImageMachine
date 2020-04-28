//
//  MachineDataTableViewController.swift
//  ImageMachine
//
//  Created by Fereizqo Sulaiman on 24/04/20.
//  Copyright © 2020 Fereizqo Sulaiman. All rights reserved.
//

import UIKit
import CoreData

class MachineDataTableViewController: UITableViewController {
    
    var machines: [NSManagedObject] = []
    var machinesArray: [Machines] = []
    
    // Setup after load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        machinesArray = coreDataRequest.shared.retrieve()
        tableView.reloadData()
    }

    // Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return machinesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "machineDataCell", for: indexPath) as! MachineDataTableViewCell
        
        cell.titleLabel.text = machinesArray[indexPath.row].name
        cell.subtitleLabel.text = machinesArray[indexPath.row].id
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var detailMachines: Machines
        detailMachines = machinesArray[indexPath.row]
        
        performSegue(withIdentifier: "goToDetail", sender: detailMachines)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailMachineDataViewController, let detailMachines = sender as? Machines {
            vc.machine = detailMachines
        }
    }
    
    @IBAction func addBarButtonTapped(_ sender: UIBarButtonItem) {
        let nc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editNavViewController") as! UINavigationController
        nc.modalPresentationStyle = .fullScreen
        nc.modalTransitionStyle = .crossDissolve
        self.present(nc, animated: true, completion: nil)
    }
}
