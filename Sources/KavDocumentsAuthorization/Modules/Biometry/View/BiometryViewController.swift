//
//  BiometryViewController.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 09.03.2022.
//

import UIKit

final class BiometryViewController: UIViewController {

    // MARK: Private Properties
    
    private let output: BiometryViewOutput
    
    // MARK: Life Cycle
    
    init(output: BiometryViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Biometry"
        view.backgroundColor = .systemBackground
        
        let alertController = buildAlertController()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.present(alertController, animated: true)
        }
    }
    
    // MARK: Private Methods
    
    private func buildAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: "Do you want to use biometry authorization?", message: nil, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.output.setupBiometry()
        }

        let noAction = UIAlertAction(title: "No", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.output.declineBiometry()
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        return alertController
    }
}

// MARK: - BiometryViewInput

extension BiometryViewController: BiometryViewInput {
    
}
