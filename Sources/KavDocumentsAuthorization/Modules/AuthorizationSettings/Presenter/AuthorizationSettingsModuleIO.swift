//
//  AuthorizationSettingsModuleIO.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 31.05.2022.
//

import Foundation
import UIKit

protocol AuthorizationSettingsModuleInput: AnyObject {
    func reloadData()
}

protocol AuthorizationSettingsModuleOutput: AnyObject {
    func authorizationSettingsModuleWantsToClose()
    func authorizationSettingsModuleWantsToSetupAuthorization(sender: UISwitch)
    func authorizationSettingsModuleWantsToOpenChangeCode()
    func authorizationSettingsModuleWantsToOpenBiometry(sender: UISwitch)
    func setupModuleInput(_ input: AuthorizationSettingsModuleInput)
    func moduleWantsToRemoveLockButton()
}
