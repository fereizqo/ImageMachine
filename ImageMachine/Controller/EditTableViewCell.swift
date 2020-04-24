//
//  EditTableViewCell.swift
//  ImageMachine
//
//  Created by Fereizqo Sulaiman on 24/04/20.
//  Copyright © 2020 Fereizqo Sulaiman. All rights reserved.
//

import UIKit

class EditTableViewCell: UITableViewCell {

    @IBOutlet weak var titleEditLabel: UILabel!
    @IBOutlet weak var fillTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(text: String, placeholder: String) {
        fillTextField.text = text
        fillTextField.placeholder = placeholder
        
        fillTextField.accessibilityValue = text
        fillTextField.accessibilityLabel = placeholder
    }

}
