//
//  AuthorizationSettingsFlowCoordinator.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 24.03.2022.
//

import KavUtils
import UIKit

public protocol AuthorizationSettingsFlowCoordinatorOutput: AnyObject {
    func authorizationSettingsFlowCoordinatorWantsToClose()
    func authorizationSettingsFlowCoordinatorWantsToSetupLockButton()
    func authorizationSettingsFlowCoordinatorWantsToRemoveLockButton()
}

public final class AuthorizationSettingsFlowCoordinator: FlowCoordinatorProtocol {
    
    // MARK: Private Properties
    
    private weak var rootNavigationController: UINavigationController?
    private let resolver: KavResolver
    private weak var output: AuthorizationSettingsFlowCoordinatorOutput?
    
    private weak var codeViewController: UIViewController?
    private weak var biometryViewController: UIViewController?
    
    private var authorizationSwitchCallback: ((Bool) -> Void)?
    private var biometrySwitchCallback: ((Bool) -> Void)?
    
    private weak var authorizationModuleInput: AuthorizationSettingsModuleInput?
    
    // MARK: Life Cycle
    
    public init(resolver: KavResolver, rootNavigationController: UINavigationController, output: AuthorizationSettingsFlowCoordinatorOutput) {
        self.resolver = resolver
        self.rootNavigationController = rootNavigationController
        self.output = output
    }
    
    // MARK: Public Methods
    
    public func start(animated: Bool) {
        let builder = AuthorizationSettingsBuilder(
            resolver: resolver,
            moduleOutput: self
        )
        
        let authorizationSettingsViewController = builder.build()
        
        rootNavigationController?.pushViewController(authorizationSettingsViewController, animated: animated)
    }
    
    public func finish(animated: Bool, completion: (() -> Void)?) {
        completion?()
    }
    
    // MARK: Private Methods
    
    private func openCodeModule() {
        let moduleBuilder = CodeModuleBuilder(
            viewState: .change,
            resolver: resolver,
            moduleOutput: self
        )
        
        let codeViewController = moduleBuilder.build()
        
        self.codeViewController = codeViewController
        
        rootNavigationController?.present(codeViewController, animated: true)
    }
}

// MARK: - AuthorizationSettingsModuleOutput

extension AuthorizationSettingsFlowCoordinator: AuthorizationSettingsModuleOutput {
    
    func setupModuleInput(_ input: AuthorizationSettingsModuleInput) {
        self.authorizationModuleInput = input
    }
    
    func authorizationSettingsModuleWantsToClose() {
        output?.authorizationSettingsFlowCoordinatorWantsToClose()
    }
    
    func authorizationSettingsModuleWantsToOpenChangeCode() {
        openCodeModule()
    }

    func moduleWantsToRemoveLockButton() {
        output?.authorizationSettingsFlowCoordinatorWantsToRemoveLockButton()
    }
    
    func authorizationSettingsModuleWantsToSetupAuthorization(callback: @escaping (Bool) -> Void) {
        openCodeModule()
        self.authorizationSwitchCallback = callback
    }
    
    func authorizationSettingsModuleWantsToOpenBiometry(callback: @escaping (Bool) -> Void) {
        let moduleBuilder = BiometryModuleBuilder(
            state: .change,
            resolver: resolver,
            moduleOutput: self
        )
        
        let biometryViewController = moduleBuilder.builder()
        self.biometryViewController = biometryViewController
        
        self.biometrySwitchCallback = callback
        rootNavigationController?.present(biometryViewController, animated: true)
    }
}

// MARK: - CodeModuleOutput

extension AuthorizationSettingsFlowCoordinator: CodeModuleOutput {
    
    func codeModuleWantsToAuthSuccess() {
        authorizationSwitchCallback = nil
        codeViewController?.dismiss(animated: true) { [weak self] in
            self?.authorizationModuleInput?.reloadData()
            self?.output?.authorizationSettingsFlowCoordinatorWantsToSetupLockButton()
        }
    }
    
    func codeModuleWantsToClose() {
        authorizationSwitchCallback?(false)
    }
    
    func codeModuleWantsToOpenBiometry() {
        // unused
    }
}

// MARK: - BiometryModuleOutput

extension AuthorizationSettingsFlowCoordinator: BiometryModuleOutput {
    
    func biometryModuleWantsToAuthSuccess() {
        biometryViewController?.dismiss(animated: true)
    }
    
    func biometryModuleWantsToClose() {
        biometryViewController?.dismiss(animated: true) { [weak self] in
            self?.biometrySwitchCallback?(false)
        }
    }
}
