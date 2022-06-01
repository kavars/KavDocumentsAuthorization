//
//  AuthorizationSettingsInteractorIO.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 31.05.2022.
//

import Foundation

protocol AuthorizationSettingsInteractorInput: AnyObject {
    
    var isAuthorizationEnabled: Bool { get }
    var isBiometryAvailible: Bool { get }
    var isBiometryEnabled: Bool { get }
    
    func disableAuthorization()
    func disableBiometry()
}

protocol AuthorizationSettingsInteractorOutput: AnyObject {
    
}
