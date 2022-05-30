//
//  CodeModuleBuilder.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation
import KavUtils
import UIKit

final class CodeModuleBuilder {
    
    private let viewState: CodeModuleState
    private let resolver: KavResolver
    private weak var moduleOutput: CodeModuleOutput?
    
    init(
        viewState: CodeModuleState,
        resolver: KavResolver,
        moduleOutput: CodeModuleOutput?
    ) {
        self.viewState = viewState
        self.resolver = resolver
        self.moduleOutput = moduleOutput
    }
    
    func build() -> UIViewController {
        
        let interactor = CodeInteractor(
            authorizationService: resolver.resolve()
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
