//
//  AuthorizationService.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 26.03.2022.
//

import Foundation
import LocalAuthentication

final class AuthorizationService: AuthorizationServiceProtocol {
    
    private var context = LAContext()
    
    init() {}
    
    func verifyCode(_ code: String) -> Bool {
        
        guard let string = UserDefaults.standard.string(forKey: "kCode") else {
            return false
        }
        
        return string == code
    }
    
    var isBiometryEnabled: Bool {
        return UserDefaults.standard.bool(forKey: "kBiometry")
    }
    
    var isBiometryAvailible: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    var biometryType: BiometryType {
        
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
    
    var isAuthorizationEnabled: Bool {
        UserDefaults.standard.bool(forKey: "kAuthEnable")
    }
    
    func setAuthorizationEnable(_ isEnable: Bool) {
        UserDefaults.standard.set(isEnable, forKey: "kAuthEnable")
    }
    
    func setCode(_ code: String) {
        UserDefaults.standard.set(code, forKey: "kCode")
    }
    
    func setBiometry(_ isEnable: Bool) {
        UserDefaults.standard.set(isEnable, forKey: "kBiometry")
    }
    
    // rename method
    func setBiometry(completion: @escaping (Result<Void, Error>) -> Void) {
        context = LAContext()
        context.localizedCancelTitle = "Enter Code"
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Log in to your account"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in

                if success {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: "kBiometry")
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
    
    var isFirstLaunch: Bool {
        if UserDefaults.standard.string(forKey: "test") == nil {
            return true
        }
        
        return UserDefaults.standard.bool(forKey: "kFirstLaunch")
    }
    
    func setFirstLaunchFalse() {
        UserDefaults.standard.set("test", forKey: "test")
        UserDefaults.standard.set(false, forKey: "kFirstLaunch")
    }
}
