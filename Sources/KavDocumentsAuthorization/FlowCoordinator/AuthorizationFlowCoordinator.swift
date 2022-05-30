//
//  AuthorizationFlowCoordinator.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 08.03.2022.
//

import KavUtils
import UIKit

public protocol AuthorizationFlowCoordinatorOutput: AnyObject {
    func authorizationFlowCoordinatorWantsToOpenMain()
    func authorizationFlowCoordinatorWantsToClose()
}

public final class AuthorizationFlowCoordinator: FlowCoordinatorProtocol {
    
    private let rootNavigationController: UINavigationController
    private let resolver: KavResolver
    private weak var output: AuthorizationFlowCoordinatorOutput?
    
    private let authorizationService: AuthorizationServiceProtocol
    
    public init(resolver: KavResolver, rootNavigationController: UINavigationController, output: AuthorizationFlowCoordinatorOutput?) {
        self.resolver = resolver
        self.authorizationService = resolver.resolve()
        self.rootNavigationController = rootNavigationController
        self.output = output
    }
    
    public func start(animated: Bool) {
        let state: CodeModuleState = authorizationService.isAuthorizationEnabled ? .login : .create

        let codeBuilder = CodeModuleBuilder(
            viewState: state,
            resolver: resolver,
            moduleOutput: self
        )

        let codeVC = codeBuilder.build()

        rootNavigationController.pushViewController(codeVC, animated: true)
    }
    
    public func finish(animated: Bool, completion: (() -> Void)?) {
        completion?()
    }
}

extension AuthorizationFlowCoordinator: CodeModuleOutput {
    func codeModuleWantsToOpenBiometry() {
        
        let moduleBuilder = BiometryModuleBuilder(
            state: .creation,
            resolver: resolver,
            moduleOutput: self
        )
        
        let biometryViewController = moduleBuilder.builder()
        
        rootNavigationController.pushViewController(biometryViewController, animated: true)
    }
    
    func codeModuleWantsToAuthSuccess() {
        output?.authorizationFlowCoordinatorWantsToOpenMain()
    }
    
    func codeModuleWantsToClose() {
        output?.authorizationFlowCoordinatorWantsToClose()
    }
}

extension AuthorizationFlowCoordinator: BiometryModuleOutput {
    func biometryModuleWantsToAuthSuccess() {
        output?.authorizationFlowCoordinatorWantsToOpenMain()
    }
    
    func biometryModuleWantsToClose() {
        // unused
    }
}
