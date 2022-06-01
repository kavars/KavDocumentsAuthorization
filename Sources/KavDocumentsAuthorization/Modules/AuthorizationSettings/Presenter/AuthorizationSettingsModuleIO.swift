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
    func authorizationSettingsModuleWantsToOpenChangeCode()
    func setupModuleInput(_ input: AuthorizationSettingsModuleInput)
    func moduleWantsToRemoveLockButton()
    func authorizationSettingsModuleWantsToSetupAuthorization(callback: @escaping (Bool) -> Void)
    func authorizationSettingsModuleWantsToOpenBiometry(callback: @escaping (Bool) -> Void)
}
