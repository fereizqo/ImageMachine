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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            coreDataRequest.shared.delete(id: "\(machinesArray[indexPath.row].id)")
            machinesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
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
    
    @IBAction func sortBarButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sort Data", message: "Let's sort data by:", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "ID", style: .default, handler: { action in
            self.machinesArray = coreDataRequest.shared.retrieveSort(SortBy: "id")
            self.tableView.reloadData()
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Name", style: .default, handler: { action in
            self.machinesArray = coreDataRequest.shared.retrieveSort(SortBy: "name")
            self.tableView.reloadData()
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
