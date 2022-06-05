//
//  BiometryInteractor.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation

final class BiometryInteractor {
    
    // MARK: Public Properties
    
    weak var output: BiometryInteractorOutput?
    
    // MARK: Private Properties
    
    private let authorizationService: AuthorizationServiceProtocol
    
    // MARK: Life Cycle
    
    init(authorizationService: AuthorizationServiceProtocol) {
        self.authorizationService = authorizationService
    }
}

// MARK: - BiometryInteractorInput

extension BiometryInteractor: BiometryInteractorInput {

    func setupBiometry(completion: @escaping (Result<Void, Error>) -> Void) {
        authorizationService.setBiometry { result in
            completion(result)
        }
    }
}
