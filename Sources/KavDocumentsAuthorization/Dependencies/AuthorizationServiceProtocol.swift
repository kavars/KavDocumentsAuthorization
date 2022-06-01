//
//  AuthorizationServiceProtocol.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 26.03.2022.
//

import Foundation

protocol AuthorizationServiceProtocol {
    var isFirstLaunch: Bool { get }
    var isBiometryAvailible: Bool { get }
    var biometryType: BiometryType { get }
    var isAuthorizationEnabled: Bool { get }
    var isBiometryEnabled: Bool { get }
    
    func setAuthorizationEnable(_ isEnable: Bool)
    func setCode(_ code: String)
    func setBiometry(_ isEnable: Bool)
    func setBiometry(completion: @escaping (Result<Void, Error>) -> Void)
    
    func verifyCode(_ code: String) -> Bool

    func setFirstLaunchFalse()
}
