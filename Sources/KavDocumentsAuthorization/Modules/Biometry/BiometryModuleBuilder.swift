//
//  BiometryModuleBuilder.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation
import KavUtils
import UIKit

final class BiometryModuleBuilder {
    
    private let state: BiometryState
    private let resolver: KavResolver
    private weak var moduleOutput: BiometryModuleOutput?
    
    init(
        state: BiometryState,
        resolver: KavResolver,
        moduleOutput: BiometryModuleOutput?
    ) {
        self.state = state
        self.resolver = resolver
        self.moduleOutput = moduleOutput
    }
    
    func builder() -> UIViewController {
        let interactor = BiometryInteractor(
            authorizationService: resolver.resolve()
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
