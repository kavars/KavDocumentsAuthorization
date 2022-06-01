//
//  AuthorizationSettingsInteractor.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 31.05.2022.
//

import Foundation

final class AuthorizationSettingsInteractor {
    
    // MARK: Public Properties
    
    weak var output: AuthorizationSettingsInteractorOutput?
    
    // MARK: Private Properties
    
    private let authorizationService: AuthorizationServiceProtocol
    
    // MARK: Life Cycle
    
    init(authorizationService: AuthorizationServiceProtocol) {
        self.authorizationService = authorizationService
    }
}

// MARK: - AuthorizationSettingsInteractorInput

extension AuthorizationSettingsInteractor: AuthorizationSettingsInteractorInput {
    
    var isAuthorizationEnabled: Bool {
        authorizationService.isAuthorizationEnabled
    }
    
    var isBiometryAvailible: Bool {
        authorizationService.isBiometryAvailible
    }
    
    var isBiometryEnabled: Bool {
        authorizationService.isBiometryEnabled
    }
    
    func disableAuthorization() {
        authorizationService.setAuthorizationEnable(false)
        authorizationService.setBiometry(false)
    }
    
    func disableBiometry() {
        authorizationService.setBiometry(false)
    }
}
