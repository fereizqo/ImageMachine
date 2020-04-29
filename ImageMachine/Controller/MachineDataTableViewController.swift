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
        
        // Remove extra empty cell in teableview
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load saved machine data
        machinesArray = coreDataRequest.shared.retrieve()
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return number of section
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return number of row
        return machinesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "machineDataCell", for: indexPath) as! MachineDataTableViewCell
        
        cell.titleLabel.text = machinesArray[indexPath.row].name
        cell.subtitleLabel.text = machinesArray[indexPath.row].id
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do action when selecting row
        
        // Send selected machine data object over segue
        var detailMachines: Machines
        detailMachines = machinesArray[indexPath.row]
        performSegue(withIdentifier: "goToDetail", sender: detailMachines)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Do delete action in selected row
        if editingStyle == .delete {
            coreDataRequest.shared.delete(id: "\(machinesArray[indexPath.row].id)")
            machinesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Make row editable
        true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Initiate segue
        if let vc = segue.destination as? DetailMachineDataViewController, let detailMachines = sender as? Machines {
            vc.machine = detailMachines
        }
    }
    
    // MARK: - Button action outlet
    
    @IBAction func addBarButtonTapped(_ sender: UIBarButtonItem) {
        // Add bar button action
        
        // Initiate go to edit navigation controller
        let nc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editNavViewController") as! UINavigationController
        nc.modalPresentationStyle = .fullScreen
        nc.modalTransitionStyle = .crossDissolve
        self.present(nc, animated: true, completion: nil)
    }
    
    @IBAction func sortBarButtonTapped(_ sender: UIBarButtonItem) {
        // Sort  bar button action
        
        // Make alert promp
        let alert = UIAlertController(title: "Sort Data", message: "Let's sort data by:", preferredStyle: .actionSheet)
        // Sort by ID action
        alert.addAction(UIAlertAction(title: "ID", style: .default, handler: { action in
            self.machinesArray = coreDataRequest.shared.retrieveSort(SortBy: "id")
            self.tableView.reloadData()
            alert.dismiss(animated: true, completion: nil)
        }))
        // Sort by Name action
        alert.addAction(UIAlertAction(title: "Name", style: .default, handler: { action in
            self.machinesArray = coreDataRequest.shared.retrieveSort(SortBy: "name")
            self.tableView.reloadData()
            alert.dismiss(animated: true, completion: nil)
        }))
        // Present alert
        self.present(alert, animated: true, completion: nil)
    }
    
}
