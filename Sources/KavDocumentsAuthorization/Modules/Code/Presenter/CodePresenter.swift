//
//  CodePresenter.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation

final class CodePresenter {
    
    // MARK: Public Properties
    
    weak var view: CodeViewInput?
    
    // MARK: Private Properties
    
    private let interactor: CodeInteractorInput
    private weak var moduleOutput: CodeModuleOutput?
    
    private var isFirstCode: Bool = true
    private var code: String = ""
    
    // MARK: Life Cycle
    
    init(interactor: CodeInteractorInput, moduleOutput: CodeModuleOutput?) {
        self.interactor = interactor
        self.moduleOutput = moduleOutput
    }
    
    // MARK: Private Methods
    
    private func didReceiveError(_ error: Error) {
        // TODO: Add alert service
        print(error)
    }
}

// MARK: - CodeModuleInput

extension CodePresenter: CodeModuleInput {
    
}

// MARK: - CodeInteractorOutput

extension CodePresenter: CodeInteractorOutput {
    func openBiometryModule() {
        moduleOutput?.codeModuleWantsToOpenBiometry()
    }
    
    func authSuccess() {
        moduleOutput?.codeModuleWantsToAuthSuccess()
    }
}

// MARK: - CodeViewOutput

extension CodePresenter: CodeViewOutput {
    func startBiometryLoginIfNeeded() {
        interactor.startBiometryLoginIfNeeded { [weak self] result in
            switch result {
            case .success:
                self?.moduleOutput?.codeModuleWantsToAuthSuccess()
            case .failure(let error):
                self?.didReceiveError(error)
            }
        }
    }
    
    func biometryImageName() -> String? {
        return interactor.biometryImageName()
    }
    
    func setupCode(code: String) {
        if isFirstCode {
            self.code = code
            view?.clearTextField()
            isFirstCode = false
        } else {
            if self.code == code {
                interactor.setupCode(code: code)
            } else {
                view?.setIncorrectCodeState()
            }
        }
    }
    
    func changeCode(code: String) {
        if isFirstCode {
            self.code = code
            view?.clearTextField()
            isFirstCode = false
        } else {
            if self.code == code {
                interactor.changeCode(code: code)
            } else {
                view?.setIncorrectCodeState()
            }
        }
    }
    
    func loginWithCode(code: String) {
        interactor.loginWithCode(code: code) { [weak self] success in
            if success {
                self?.moduleOutput?.codeModuleWantsToAuthSuccess()
            } else {
                self?.view?.setIncorrectCodeState()
            }
        }
    }
    
    func codeModuleWantsToClose() {
        moduleOutput?.codeModuleWantsToClose()
    }
}
