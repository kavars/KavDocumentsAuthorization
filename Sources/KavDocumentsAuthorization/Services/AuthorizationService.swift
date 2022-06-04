//
//  AuthorizationService.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 26.03.2022.
//

import Foundation
import LocalAuthentication

public final class AuthorizationService: AuthorizationServiceProtocol {
    
    // MARK: Private Data Struct
    
    private struct KeychainKeys {
        static let code = KeychainKey(type: String.self, key: "kCode")
        static let biometry = KeychainKey(type: Bool.self, key: "kBiometry")
        static let authorizationEnable = KeychainKey(type: Bool.self, key: "kAuthEnable")
        static let firstLaunch = KeychainKey(type: Bool.self, key: "kFirstLaunch")
        static let firstLaunchValue = KeychainKey(type: Bool.self, key: "kFirstLaunchValue")
    }
    
    // MARK: Private Properties
    
    private var context = LAContext()
    private let keychainService: KeychainServiceProtocol
    
    // MARK: Life Cycle
    init(keychainService: KeychainServiceProtocol) {
        self.keychainService = keychainService
    }
    
    // MARK: Public Methods
    
    public func verifyCode(_ code: String) -> Bool {
        guard let string = keychainService.getValue(for: KeychainKeys.code) else {
            return false
        }
        
        return string == code
    }
    
    public var isBiometryEnabled: Bool {
        return keychainService.getValue(for: KeychainKeys.biometry) ?? false
    }
    
    public var isBiometryAvailible: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    public var biometryType: BiometryType {
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
    
    public var isAuthorizationEnabled: Bool {
        keychainService.getValue(for: KeychainKeys.authorizationEnable) ?? false
    }
    
    public func setAuthorizationEnable(_ isEnable: Bool) {
        keychainService.setValue(isEnable, for: KeychainKeys.authorizationEnable)
    }
    
    public func setCode(_ code: String) {
        keychainService.setValue(code, for: KeychainKeys.code)
    }
    
    public func setBiometry(_ isEnable: Bool) {
        keychainService.setValue(isEnable, for: KeychainKeys.biometry)
    }
    
    // rename method
    public func setBiometry(completion: @escaping (Result<Void, Error>) -> Void) {
        context = LAContext()
        context.localizedCancelTitle = "Enter Code"
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Log in to your account"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { [weak self] success, error in

                if success {
                    DispatchQueue.main.async { [weak self] in
                        self?.keychainService.setValue(true, for: KeychainKeys.biometry)
                        completion(.success(()))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(error ?? NSError()))
                    }
                }
            }
        } else {
            completion(.failure(error  ?? NSError()))
        }
    }
    
    public var isFirstLaunch: Bool {
        guard keychainService.getValue(for: KeychainKeys.firstLaunchValue) != nil else {
            return true
        }
        
        return keychainService.getValue(for: KeychainKeys.firstLaunch) ?? false
    }
    
    public func setFirstLaunchFalse() {
        keychainService.setValue(false, for: KeychainKeys.firstLaunchValue)
        keychainService.setValue(false, for: KeychainKeys.firstLaunch)
    }
}
