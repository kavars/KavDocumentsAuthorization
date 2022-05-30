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
    
    private weak var rootNavigationController: UINavigationController?
    private let resolver: KavResolver
    private weak var output: AuthorizationSettingsFlowCoordinatorOutput?
    
    private weak var codeViewController: UIViewController?
    private weak var biometryViewController: UIViewController?
    
    private weak var authorizationSwitch: UISwitch?
    private weak var biometrySwitch: UISwitch?
    
    private weak var authorizationModuleInput: AuthorizationSettingsModuleInput?
    
    public init(resolver: KavResolver, rootNavigationController: UINavigationController, output: AuthorizationSettingsFlowCoordinatorOutput) {
        self.resolver = resolver
        self.rootNavigationController = rootNavigationController
        self.output = output
    }
    
    public func start(animated: Bool) {
        let authorizationSettingsViewController = AuthorizationSettingsViewController(resolver: resolver, moduleOutput: self)
        
        rootNavigationController?.pushViewController(authorizationSettingsViewController, animated: animated)
    }
    
    public func finish(animated: Bool, completion: (() -> Void)?) {
        completion?()
    }
}

extension AuthorizationSettingsFlowCoordinator: AuthorizationSettingsModuleOutput {
    
    func setupModuleInput(_ input: AuthorizationSettingsModuleInput) {
        self.authorizationModuleInput = input
    }
    
    func authorizationSettingsModuleWantsToClose() {
        output?.authorizationSettingsFlowCoordinatorWantsToClose()
    }
    
    func authorizationSettingsModuleWantsToSetupAuthorization(sender: UISwitch) {
        
        let moduleBuilder = CodeModuleBuilder(
            viewState: .change,
            resolver: resolver,
            moduleOutput: self
        )
        
        let codeViewController = moduleBuilder.build()
        
        self.codeViewController = codeViewController
        
        self.authorizationSwitch = sender
        
        rootNavigationController?.present(codeViewController, animated: true)
    }
    
    func authorizationSettingsModuleWantsToOpenChangeCode() {
        let moduleBuilder = CodeModuleBuilder(
            viewState: .change,
            resolver: resolver,
            moduleOutput: self
        )

        let codeViewController = moduleBuilder.build()

        self.codeViewController = codeViewController
        
        rootNavigationController?.present(codeViewController, animated: true)
    }
    
    func authorizationSettingsModuleWantsToOpenBiometry(sender: UISwitch) {
        
        let moduleBuilder = BiometryModuleBuilder(
            state: .change,
            resolver: resolver,
            moduleOutput: self
        )
        
        let biometryViewController = moduleBuilder.builder()
        self.biometryViewController = biometryViewController
        
        self.biometrySwitch = sender
        rootNavigationController?.present(biometryViewController, animated: true)
    }
    
    func moduleWantsToRemoveLockButton() {
        output?.authorizationSettingsFlowCoordinatorWantsToRemoveLockButton()
    }
}

extension AuthorizationSettingsFlowCoordinator: CodeModuleOutput {
    func codeModuleWantsToAuthSuccess() {
        authorizationSwitch = nil
        codeViewController?.dismiss(animated: true) { [weak self] in
            self?.authorizationModuleInput?.reloadData()
            self?.output?.authorizationSettingsFlowCoordinatorWantsToSetupLockButton()
        }
    }
    
    func codeModuleWantsToClose() {
        authorizationSwitch?.setOn(false, animated: true)
    }
    
    func codeModuleWantsToOpenBiometry() {
        // unused
    }
}

extension AuthorizationSettingsFlowCoordinator: BiometryModuleOutput {
    func biometryModuleWantsToAuthSuccess() {
        biometryViewController?.dismiss(animated: true)
    }
    
    func biometryModuleWantsToClose() {
        biometryViewController?.dismiss(animated: true) { [weak self] in
            self?.biometrySwitch?.setOn(false, animated: true)
        }
    }
}
