//
//  KavDocumentsAuthorizationAssembly.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 30.05.2022.
//

import KavUtils
import Swinject

public class KavDocumentsAuthorizationAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(AuthorizationServiceProtocol.self) { resolver in
            return AuthorizationService(keychainService: resolver.resolve())
        }
        .inObjectScope(.weak)
        
        container.register(KeychainServiceProtocol.self) { _ in
            return KeychainService()
        }
        .inObjectScope(.weak)
    }
    
    public init() {}
}
