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
    var machine: Machines?
    var detailMachineDelegates: detailMachineDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check wheter update or create new contact
        updateMachineData()
        
        // Appearance
        doneBarButton.isEnabled = false
        
        // Tableview delegate
        editTableView.delegate = self
        editTableView.dataSource = self
        editTableView.tableFooterView = UIView()
        
        // Dismiss keyboard
        self.hideKeyboardWhenTappedAround()
    }
    
    
    @IBAction func doneBarButtonTapped(_ sender: UIBarButtonItem) {
        // Done bar button action
        
        // Check it whether create or update machine data
        if let detailMachine = machine {
            coreDataRequest.shared.update(id: detailMachine.id, content: content)
            detailMachineDelegates.updateData(content: content)
        } else {
            coreDataRequest.shared.create(content: content)
        }
        // Dismiss view
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelBarButtonTapped(_ sender: UIBarButtonItem) {
        // Cancel bar button action
        
        // Make alert promp
        let alert = UIAlertController(title: "Alert", message: "Are you sure want to discard?", preferredStyle: .actionSheet)
        // Discard action
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { action in
            self.navigationController?.dismiss(animated: true, completion: nil)
            alert.dismiss(animated: true, completion: nil)
        }))
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        // Present alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateMachineData() {
        // Check wheter update or create new machine
        guard let detailMachine = machine else { return }
        
        // Update machine data
        // Date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        let date = dateFormatter.string(from: detailMachine.maintenanceDate)
        
        // Fill content with selected machine data
        content.removeAll()
        content.append(contentsOf: [detailMachine.id,
                       detailMachine.name,
                       detailMachine.type,
                       String(detailMachine.qrCode),
                       date])
    }
    
}


extension EditViewController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - TableView data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return number of row
        return header.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell
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
        
        // Insert unique ID
        if textField.tag == 0 {
            textField.isEnabled = false
            textField.minimumFontSize = 5
            textField.adjustsFontSizeToFitWidth = true
            let uuid = UUID().uuidString
            textField.text = uuid
            content[0] = uuid
            // If update data, used existing machine ID
            if let detailMachine = machine {
                textField.text = detailMachine.id
                content[0] = detailMachine.id
            }
        }

        return cell
    }
    
    // MARK: - Texfield Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Delegate when begin editing
        
        // Change keyboard type to Numpad
        if textField.tag == 3 {
            textField.keyboardType = .numberPad
            textField.reloadInputViews()
        } else if textField.tag == 4 {
            // Change keyboard type to DatePicker
            createToolbar(sender: textField)
            createPickerView(sender: textField)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Delegate when end editing
        
        // Filled specific content with specific textfield
        content[textField.tag] = textField.text ?? ""
        
        // Checking the textfield has been filled
        for i in content {
            if i != "" {
                doneBarButton.isEnabled = true
            } else if i == "" {
                doneBarButton.isEnabled = false
            }
        }
    }
    
    func createPickerView(sender: UITextField){
        // Make pickerView
        
        // Datepicker view
        let datePickerView : UIDatePicker = UIDatePicker()
        // Config datepicker
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        sender.inputView = datePickerView
        datePickerView.tag = sender.tag
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(caller:)), for: UIControl.Event.valueChanged)
    }
    
    func createToolbar(sender: UITextField){
        // Make toolbarView
        let datePickerToolbar = UIToolbar()
        datePickerToolbar.sizeToFit()
        
        // Done button action
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditViewController.dismissKeyboard(on:)))
        doneButton.tag = sender.tag

        datePickerToolbar.setItems([doneButton], animated: false)
        datePickerToolbar.isUserInteractionEnabled = true
        
        // Present datepicker
        sender.inputAccessoryView = datePickerToolbar
    }
    
    @objc func datePickerValueChanged(caller: UIDatePicker){
        // Datepicker config
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        // Datepicker print
        let indexRow = caller.tag
        let indexPath = IndexPath(row: indexRow, section: 0)
        let cell = editTableView.cellForRow(at: indexPath) as! EditTableViewCell
        cell.fillTextField.text = dateFormatter.string(from: caller.date)
    }
    
    @objc func dismissKeyboard(on: UIButton){
        // Dismiss keyboard
        view.endEditing(true)
    }
    
}
