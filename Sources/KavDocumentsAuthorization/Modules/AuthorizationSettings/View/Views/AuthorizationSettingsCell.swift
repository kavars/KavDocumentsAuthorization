//
//  AuthorizationSettingsCell.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 24.03.2022.
//

import KavUtils
import UIKit

final class AuthorizationSettingsCell: UITableViewCell {
    
    // MARK: Private Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let settingSwitch: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()
    
    private var action: ((UISwitch) -> Void)?
    
    // MARK: Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        notImplemented()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        selectionStyle = .none
        accessoryType = .none
        accessoryView = settingSwitch
    }
    
    // MARK: Private Methods
    
    private func setupView() {
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
    
    // MARK: Public Methods
    
    func configure(with model: AuthorizationSettingsDataModel) {
        titleLabel.text = model.title
        settingSwitch.isOn = model.isEnable
        action = model.action
        
        if model.action == nil {
            accessoryView = nil
            accessoryType = .disclosureIndicator
        }
    }
}
