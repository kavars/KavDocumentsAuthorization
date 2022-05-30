//
//  KavDocumentsAuthorizationAssembly.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 30.05.2022.
//

import Swinject

public class KavDocumentsAuthorizationAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(AuthorizationServiceProtocol.self) { _ in
            return AuthorizationService()
        }
    }
}
