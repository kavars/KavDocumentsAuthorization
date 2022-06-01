//
//  AuthorizationSettingsViewIO.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 31.05.2022.
//

import Foundation

protocol AuthorizationSettingsViewInput: AnyObject {
    func setupMainSection(with item: AuthorizationSettingsItem)
    func addSettingsSection(with items: [AuthorizationSettingsItem])
    func removeSettingsSection()
}

protocol AuthorizationSettingsViewOutput: AnyObject {
    func viewDidLoadEvent()
    func viewWantsToClose()
    func buildSettings()
    func changeCodeDidTap()
}
