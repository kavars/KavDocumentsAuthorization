//
//  CodeInteractor.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation

final class CodeInteractor {
    
    // MARK: Public Properties
    
    weak var output: CodeInteractorOutput?
    
    // MARK: Private Properties
    
    private let authorizationService: AuthorizationServiceProtocol
    
    // MARK: Life Cycle
    
    init(authorizationService: AuthorizationServiceProtocol) {
        self.authorizationService = authorizationService
    }
}

// MARK: - CodeInteractorInput

extension CodeInteractor: CodeInteractorInput {
    func startBiometryLoginIfNeeded(completion: @escaping (Result<Void, Error>) -> Void) {
        if authorizationService.isBiometryAvailible && authorizationService.isBiometryEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.authorizationService.setBiometry { result in
                    completion(result)
                }
            }
        }
    }
    
    func biometryImageName() -> String? {
        if authorizationService.isBiometryAvailible && authorizationService.isBiometryEnabled {
            switch authorizationService.biometryType {
            case .faceID:
                return "faceid"
            case .touchID:
                return "touchid"
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    func setupCode(code: String) {
        authorizationService.setCode(code)
        if authorizationService.isBiometryAvailible {
            output?.openBiometryModule()
        } else {
            authorizationService.setAuthorizationEnable(true)
            output?.authSuccess()
        }
    }
    
    func changeCode(code: String) {
        authorizationService.setCode(code)
        authorizationService.setAuthorizationEnable(true)
        output?.authSuccess()
    }
    
    func loginWithCode(code: String, completion: @escaping (Bool) -> Void) {
        completion(authorizationService.verifyCode(code))
    }
}
