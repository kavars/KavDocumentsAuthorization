//
//  BiometryPresenter.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation

final class BiometryPresenter {
    
    // MARK: Public Properties
    
    weak var view: BiometryViewInput?
    
    // MARK: Private Properties
    
    private let state: BiometryState
    private let interactor: BiometryInteractorInput
    private weak var moduleOutput: BiometryModuleOutput?
    
    // MARK: Life Cycle
    
    init(
        interactor: BiometryInteractorInput,
        state: BiometryState,
        moduleOutput: BiometryModuleOutput?
    ) {
        self.interactor = interactor
        self.state = state
        self.moduleOutput = moduleOutput
    }
}

// MARK: - BiometryViewOutput

extension BiometryPresenter: BiometryViewOutput {
    
    func setupBiometry() {
        interactor.setupBiometry { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                switch self.state {
                case .creation:
                    self.interactor.setupAuthorization()
                    self.moduleOutput?.biometryModuleWantsToAuthSuccess()
                case .change:
                    self.moduleOutput?.biometryModuleWantsToAuthSuccess()
                }
            case .failure:
                switch self.state {
                case .creation:
                    self.interactor.setupAuthorization()
                    self.moduleOutput?.biometryModuleWantsToAuthSuccess()
                case .change:
                    self.moduleOutput?.biometryModuleWantsToClose()
                }
            }
        }
    }
    
    func declineBiometry() {
        switch state {
        case .creation:
            interactor.setupAuthorization()
            moduleOutput?.biometryModuleWantsToAuthSuccess()
        case .change:
            moduleOutput?.biometryModuleWantsToClose()
        }
    }
}

// MARK: - BiometryInteractorOutput

extension BiometryPresenter: BiometryInteractorOutput {
    
}

// MARK: - BiometryModuleInput

extension BiometryPresenter: BiometryModuleInput {
    
}
