//
//  AuthorizationSettingsBuilder.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 31.05.2022.
//

import KavUtils
import UIKit

final class AuthorizationSettingsBuilder {
    
    // MARK: Private Properties
    
    private let resolver: KavResolver
    private weak var moduleOutput: AuthorizationSettingsModuleOutput?
    
    // MARK: Life Cycle
    
    init(resolver: KavResolver, moduleOutput: AuthorizationSettingsModuleOutput) {
        self.resolver = resolver
        self.moduleOutput = moduleOutput
    }
    
    func build() -> UIViewController {
        let interactor = AuthorizationSettingsInteractor(
            authorizationService: resolver.resolve()
        )
        let presenter = AuthorizationSettingsPresenter(
            interactor: interactor,
            moduleOutput: moduleOutput
        )
        let view = AuthorizationSettingsViewController(output: presenter)
        
        interactor.output = presenter
        presenter.view = view
        
        return view
    }
}
