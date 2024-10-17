//
//  TableViewController.swift
//  RestFulApp
//
//  Created by haams on 10/16/24.
//

import Foundation
import UIKit

struct DataKey: Hashable {
    let key: String
    let value: String
}

class TableViewController: UITableViewCell {
    
    let checkBox = UIButton(type: .system)
    let keyTextField = UITextField()
    let valueTextField = UITextField()
    var onTextChange: ((String, String) -> Void)?
    var checkBoxTapped : (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        keyTextField.borderStyle = .roundedRect
        keyTextField.placeholder = "Key"
        keyTextField.translatesAutoresizingMaskIntoConstraints = false
        
        valueTextField.borderStyle = .roundedRect
        valueTextField.placeholder = "Value"
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        
        checkBox.setTitle("☐", for: .normal)
        checkBox.setTitle("☑", for: .selected)
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        checkBox.addTarget(self, action: #selector(checkBoxTappedAction), for: .touchUpInside)
        
        contentView.addSubview(checkBox)
        contentView.addSubview(keyTextField)
        contentView.addSubview(valueTextField)
        
        NSLayoutConstraint.activate([
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBox.widthAnchor.constraint(equalToConstant: 30),
            
            keyTextField.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 10),
            keyTextField.widthAnchor.constraint(equalToConstant: 100),
            keyTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            valueTextField.leadingAnchor.constraint(equalTo: keyTextField.trailingAnchor, constant: 10),
            valueTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            valueTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            
        ])
    }
    @objc func checkBoxTappedAction() {
         checkBox.isSelected.toggle()
         checkBoxTapped?()  // Trigger action when checkbox is tapped
     }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        let key = keyTextField.text ?? ""
        let value = valueTextField.text ?? ""
        onTextChange?(key, value)
    }
}
