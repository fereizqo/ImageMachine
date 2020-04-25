//
//  EditViewController.swift
//  ImageMachine
//
//  Created by Fereizqo Sulaiman on 24/04/20.
//  Copyright © 2020 Fereizqo Sulaiman. All rights reserved.
//

import UIKit
import CoreData

class EditViewController: UIViewController {

    @IBOutlet weak var editTableView: UITableView!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    let header = [ "ID", "Name", "Type", "QR Code","Last maintenance date" ]
    var content = ["","","","",""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Appearance
        doneBarButton.isEnabled = false
        
        // Tableview
        editTableView.delegate = self
        editTableView.dataSource = self
        editTableView.tableFooterView = UIView()
        
        // Dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        
    }
    
    
    @IBAction func doneBarButtonTapped(_ sender: UIBarButtonItem) {
        save(content: content)
        print("save succes")
    }
    
    @IBAction func cancelBarButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Alert", message: "Are you sure want to discard?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { action in
            self.navigationController?.dismiss(animated: true, completion: nil)
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func save(content: [String]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Machine", in: managedContext)!
        let machine = NSManagedObject(entity: entity, insertInto: managedContext)
        
        machine.setValue(content[1], forKeyPath: "id")
        machine.setValue(content[2], forKeyPath: "name")
        machine.setValue(content[3], forKeyPath: "type")
        machine.setValue(Int(content[4]), forKeyPath: "qrCode")
        machine.setValue(content[5], forKeyPath: "dateMaintenance")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}

extension EditViewController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return header.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = editTableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath) as! EditTableViewCell
        
        // Setup appearance
        cell.selectionStyle = .none
        cell.titleEditLabel.text = header[indexPath.row]
        cell.fillTextField.autocorrectionType = .no
        cell.fillTextField.autocapitalizationType = .none
        
        // Tagged each textfield
        let textField = cell.viewWithTag(1) as! UITextField
        textField.tag = indexPath.row
        textField.text = content[indexPath.row]
        textField.delegate = self
        
        return cell
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Change keyboard type
        if textField.tag == 3 {
            textField.keyboardType = .numberPad
            textField.reloadInputViews()
        } else if textField.tag == 4 {
            textField.setDatePicker(target: self, selector: #selector(tapDone))
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        content[textField.tag] = textField.text ?? ""
        print("Content: \(content)")
        
        // Checking the textfield has been filled
        for i in content {
            if i != "" {
                doneBarButton.isEnabled = true
            } else if i == "" {
                doneBarButton.isEnabled = false
            }
        }
    }
    
    @objc func tapDone() {
//        let cell = editTableView.dequeueReusableCell(withIdentifier: "editCell") as! EditTableViewCell
//        let textField = cell.viewWithTag(1) as! UITextField
//        textField.delegate = self
//        if let datePicker = textField.inputView as? UIDatePicker {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateStyle = .medium
//            textField.text = dateFormatter.string(from: datePicker.date)
//            print("done : \(dateFormatter.string(from: datePicker.date))")
//        }
//        textField.resignFirstResponder()
    }
    
    
}
