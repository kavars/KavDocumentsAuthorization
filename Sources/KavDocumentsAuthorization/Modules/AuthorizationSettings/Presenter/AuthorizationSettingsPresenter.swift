//
//  AuthorizationSettingsPresenter.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 31.05.2022.
//

import Foundation

final class AuthorizationSettingsPresenter {
    
    // MARK: Public Properties
    
    weak var view: AuthorizationSettingsViewInput?
    
    // MARK: Private Properties
    
    private let interactor: AuthorizationSettingsInteractorInput
    private weak var moduleOutput: AuthorizationSettingsModuleOutput?
    
    // MARK: Life Cycle
    
    init(
        interactor: AuthorizationSettingsInteractorInput,
        moduleOutput: AuthorizationSettingsModuleOutput?
    ) {
        self.interactor = interactor
        self.moduleOutput = moduleOutput
    }
    
    // MARK: Private Methods
    
    private func buildMainSection() {
        let authorizationDataModel = AuthorizationSettingsDataModel(
            uuid: UUID(),
            isEnable: interactor.isAuthorizationEnabled,
            title: "Authorization"
        ) { [weak self] isOn, callback in
            guard let self = self else { return }
            
            if isOn {
                self.moduleOutput?.authorizationSettingsModuleWantsToSetupAuthorization(callback: callback)
            } else {
                self.interactor.disableAuthorization()
                
                self.buildSettings()
                self.moduleOutput?.moduleWantsToRemoveLockButton()
            }
        }
        
        view?.setupMainSection(with: .authorization(authorizationDataModel))
    }
}

// MARK: - AuthorizationSettingsViewOutput

extension AuthorizationSettingsPresenter: AuthorizationSettingsViewOutput {
    
    func viewDidLoadEvent() {
        moduleOutput?.setupModuleInput(self)
        buildMainSection()
    }
    
    func viewWantsToClose() {
        moduleOutput?.authorizationSettingsModuleWantsToClose()
    }
    
    func buildSettings() {
        if interactor.isAuthorizationEnabled {
            var items: [AuthorizationSettingsItem] = []
            
            let changeCodeDataModel = AuthorizationSettingsDataModel(
                uuid: UUID(),
                isEnable: true,
                title: "Change code",
                action: nil
            )
            items.append(.changeCode(changeCodeDataModel))
            
            if interactor.isBiometryAvailible {
                let biometryDataModel = AuthorizationSettingsDataModel(
                    uuid: UUID(),
                    isEnable: interactor.isBiometryEnabled,
                    title: "Biometry"
                ) { [weak self] isOn, callback in
                    guard let self = self else { return }

                    if !self.interactor.isBiometryEnabled {
                        self.moduleOutput?.authorizationSettingsModuleWantsToOpenBiometry(callback: callback)
                    } else {
                        self.interactor.disableBiometry()
                    }
                }
                items.append(.biometry(biometryDataModel))
            }
            
            view?.addSettingsSection(with: items)
        } else {
            view?.removeSettingsSection()
        }
    }
    
    func changeCodeDidTap() {
        moduleOutput?.authorizationSettingsModuleWantsToOpenChangeCode()
    }
}

// MARK: - AuthorizationSettingsInteractorOutput

extension AuthorizationSettingsPresenter: AuthorizationSettingsInteractorOutput {

}

// MARK: - AuthorizationSettingsModuleInput

extension AuthorizationSettingsPresenter: AuthorizationSettingsModuleInput {
    
    func reloadData() {
        buildSettings()
    }
}
