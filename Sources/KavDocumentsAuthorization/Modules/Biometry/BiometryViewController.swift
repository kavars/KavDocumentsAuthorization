//
//  BiometryViewController.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 09.03.2022.
//

import UIKit

protocol BiometryModuleOutput: AnyObject {
    func biometryModuleWantsToAuthSuccess()
    func biometryModuleWantsToClose()
}

final class BiometryViewController: UIViewController {
    
    private let resolver: ResolverProtocol
    
    private weak var output: BiometryModuleOutput?
    
    enum BiometryState {
        case creation
        case change
    }
    
    private let state: BiometryState
    
    init(resolver: ResolverProtocol, output: BiometryModuleOutput, state: BiometryState) {
        self.resolver = resolver
        self.output = output
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Biometry"
        
        view.backgroundColor = .systemBackground
        
        let alertController = UIAlertController(title: "Do you want to use biometry authorization?", message: nil, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.resolver.authorizationService.setBiometry { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    switch self.state {
                    case .creation:
                        self.resolver.authorizationService.setAuthorizationEnable(true)
                        self.output?.biometryModuleWantsToAuthSuccess()
                    case .change:
                        self.output?.biometryModuleWantsToAuthSuccess()
                    }
                case .failure:
                    switch self.state {
                    case .creation:
                        self.resolver.authorizationService.setAuthorizationEnable(true)
                        self.output?.biometryModuleWantsToAuthSuccess()
                    case .change:
                        self.output?.biometryModuleWantsToClose()
                    }
                }
            }
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            
            switch self.state {
            case .creation:
                self.resolver.authorizationService.setAuthorizationEnable(true)
                self.output?.biometryModuleWantsToAuthSuccess()
            case .change:
                self.output?.biometryModuleWantsToClose()

            }
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.present(alertController, animated: true)
        }
        
    }
}
