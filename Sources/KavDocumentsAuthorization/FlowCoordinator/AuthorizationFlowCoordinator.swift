//
//  AuthorizationFlowCoordinator.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 08.03.2022.
//

import UIKit

public protocol AuthorizationFlowCoordinatorOutput: AnyObject {
    func authorizationFlowCoordinatorWantsToOpenMain()
    func authorizationFlowCoordinatorWantsToClose()
}

public final class AuthorizationFlowCoordinator: FlowCoordinatorProtocol {
    
    private let rootNavigationController: UINavigationController
    private let resolver: ResolverProtocol
    private weak var output: AuthorizationFlowCoordinatorOutput?
    
    private let authorizationService: AuthorizationServiceProtocol
    
    public init(resolver: ResolverProtocol, rootNavigationController: UINavigationController, output: AuthorizationFlowCoordinatorOutput?) {
        self.resolver = resolver
        self.authorizationService = resolver.authorizationService
        self.rootNavigationController = rootNavigationController
        self.output = output
    }
    
    public func start(animated: Bool) {
        let state: CodeViewController.CodeModuleState = authorizationService.isAuthorizationEnabled ? .login : .create
        
        let codeVC = CodeViewController(with: state, authorizationService: resolver.authorizationService)
        codeVC.moduleOutput = self
        rootNavigationController.pushViewController(codeVC, animated: true)
    }
    
    public func finish(animated: Bool, completion: (() -> Void)?) {
        completion?()
    }
}

extension AuthorizationFlowCoordinator: CodeModuleOutput {
    func codeModuleWantsToOpenBiometry() {
        
        let biometryViewController = BiometryViewController(resolver: resolver, output: self, state: .creation)
        
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
