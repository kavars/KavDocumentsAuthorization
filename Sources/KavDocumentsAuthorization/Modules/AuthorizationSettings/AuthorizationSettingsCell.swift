//
//  AuthorizationSettingsCell.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 24.03.2022.
//

import UIKit

final class AuthorizationSettingsCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let settingSwitch: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()
    
    var action: ((UISwitch) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        
        accessoryView = settingSwitch
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        ])
        
        settingSwitch.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.action?(self.settingSwitch)
        }), for: .valueChanged)
        
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        selectionStyle = .none
        accessoryType = .none
        accessoryView = settingSwitch
    }
    
    func configure(with model: AuthorizationSettingsViewController.AuthorizationSettingsDataModel) {
        titleLabel.text = model.title
        settingSwitch.isOn = model.isEnable
        action = model.action
        
        if model.action == nil {
            accessoryView = nil
            accessoryType = .disclosureIndicator
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
}
