//
//  CodeModuleBuilder.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation
import UIKit

final class CodeModuleBuilder {
    
    private let viewState: CodeModuleState
    private let resolver: ResolverProtocol
    private weak var moduleOutput: CodeModuleOutput?
    
    init(
        viewState: CodeModuleState,
        resolver: ResolverProtocol,
        moduleOutput: CodeModuleOutput?
    ) {
        self.viewState = viewState
        self.resolver = resolver
        self.moduleOutput = moduleOutput
    }
    
    func build() -> UIViewController {
        
        let interactor = CodeInteractor(
            authorizationService: resolver.authorizationService
        )
        let presenter = CodePresenter(
            interactor: interactor,
            moduleOutput: moduleOutput
        )
        let view = CodeViewController(
            output: presenter,
            with: viewState
        )

        interactor.output = presenter
        presenter.view = view
        
        return view
    }
    
}
