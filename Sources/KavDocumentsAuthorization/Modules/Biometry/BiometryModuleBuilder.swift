//
//  BiometryModuleBuilder.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation
import UIKit

final class BiometryModuleBuilder {
    
    private let state: BiometryState
    private let resolver: ResolverProtocol
    private weak var moduleOutput: BiometryModuleOutput?
    
    init(
        state: BiometryState,
        resolver: ResolverProtocol,
        moduleOutput: BiometryModuleOutput?
    ) {
        self.state = state
        self.resolver = resolver
        self.moduleOutput = moduleOutput
    }
    
    func builder() -> UIViewController {
        let interactor = BiometryInteractor(
            authorizationService: resolver.authorizationService
        )
        let presenter = BiometryPresenter(
            interactor: interactor,
            state: state,
            moduleOutput: moduleOutput
        )
        let view = BiometryViewController(output: presenter)
        
        interactor.output = presenter
        presenter.view = view
        
        return view
    }
}
