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
        
        // Check edit or not
        editContact()
        
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
        if let detailMachine = machine {
            coreDataRequest.shared.update(id: detailMachine.id, content: content)
            detailMachineDelegates.updateData(content: content)
        } else {
            coreDataRequest.shared.create(content: content)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
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
    
    func editContact() {
        guard let detailMachine = machine else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        let date = dateFormatter.string(from: detailMachine.maintenanceDate)
        
        content.removeAll()
        content.append(contentsOf: [detailMachine.id,
                       detailMachine.name,
                       detailMachine.type,
                       String(detailMachine.qrCode),
                       date])
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
        
        // Insert unique ID
        if textField.tag == 0 {
            let uuid = UUID().uuidString
            textField.text = uuid
            if let detailMachine = machine {
                textField.text = detailMachine.id
            }
            textField.isEnabled = false
            content[0] = uuid
        }

        return cell
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Change keyboard type
        if textField.tag == 3 {
            textField.keyboardType = .numberPad
            textField.reloadInputViews()
        } else if textField.tag == 4 {
            createToolbar(sender: textField)
            createPickerView(sender: textField)
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
    
    func createPickerView(sender: UITextField){
        let datePickerView : UIDatePicker = UIDatePicker()

        datePickerView.datePickerMode = UIDatePicker.Mode.date
        sender.inputView = datePickerView
        datePickerView.tag = sender.tag
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(caller:)), for: UIControl.Event.valueChanged)
    }
    
    func createToolbar(sender: UITextField){
        let datePickerToolbar = UIToolbar()
        datePickerToolbar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditViewController.dismissKeyboard(on:)))
        doneButton.tag = sender.tag

        datePickerToolbar.setItems([doneButton], animated: false)
        datePickerToolbar.isUserInteractionEnabled = true

        sender.inputAccessoryView = datePickerToolbar
    }
    
    @objc func datePickerValueChanged(caller: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none

        let indexRow = caller.tag
        let indexPath = IndexPath(row: indexRow, section: 0)
        let cell = editTableView.cellForRow(at: indexPath) as! EditTableViewCell
        
        cell.fillTextField.text = dateFormatter.string(from: caller.date)
        print("date: \(dateFormatter.string(from: caller.date))")
    }
    
    @objc func dismissKeyboard(on: UIButton){
        view.endEditing(true)
    }
    
}
