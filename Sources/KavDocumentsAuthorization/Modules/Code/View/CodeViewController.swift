//
//  CodeViewController.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 09.03.2022.
//

import UIKit

final class CodeViewController: UIViewController {
    
    // MARK: Private Properties
    
    private let output: CodeViewOutput
    private let state: CodeModuleState
        
    private let codeTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 16, height: 0.0)))
        textField.rightViewMode = .always
        textField.rightView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 16, height: 0.0)))
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 12
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        return textField
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .tinted()
        button.setTitle("Continue", for: .normal)
        button.isEnabled = false
        return button
    }()
    
    // MARK: Life Cycle
    
    init(output: CodeViewOutput, with state: CodeModuleState) {
        self.output = output
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    deinit {
        output.codeModuleWantsToClose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupBiometryButtonIfNeeded()
        setupContinueButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startBiometryLoginIfNeeded()
        codeTextField.becomeFirstResponder()
    }
    
    // MARK: Private Methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Code"
        
        codeTextField.delegate = self
        
        view.addSubview(codeTextField)
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            codeTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            codeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            codeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            codeTextField.heightAnchor.constraint(equalToConstant: 44),
            
            continueButton.topAnchor.constraint(equalTo: codeTextField.bottomAnchor, constant: 16),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupContinueButton() {
        continueButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self, let text = self.codeTextField.text else { return }
            switch self.state {
            case .create:
                self.output.setupCode(code: text)
            case .login:
                self.output.loginWithCode(code: text)
            case .change:
                self.output.changeCode(code: text)
            }
        }), for: .touchUpInside)
    }
    
    private func setNormalCodeState() {
        codeTextField.layer.borderColor = UIColor.black.cgColor
        codeTextField.layer.borderWidth = 0.5
    }

    private func setupBiometryButtonIfNeeded() {
        switch state {
        case .login:
            if let biometryImageName = output.biometryImageName() {
                let biometryImage = UIImage(systemName: biometryImageName)
                
                let biometryNavBarButton = UIBarButtonItem(title: nil, image: biometryImage, primaryAction: UIAction(handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.output.startBiometryLoginIfNeeded()
                }), menu: nil)
                
                navigationItem.rightBarButtonItem = biometryNavBarButton
            }
        default:
            break
        }
    }
    
    private func startBiometryLoginIfNeeded() {
        switch state {
        case .login:
            output.startBiometryLoginIfNeeded()
        default:
            break
        }
    }
}

// MARK: - CodeViewInput

extension CodeViewController: CodeViewInput {
    func clearTextField() {
        codeTextField.text = nil
    }
    
    func setIncorrectCodeState() {
        codeTextField.layer.borderWidth = 0.8
        codeTextField.layer.borderColor = UIColor.systemRed.cgColor
    }
}

// MARK: - UITextFieldDelegate

extension CodeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        setNormalCodeState()
        
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                  return false
              }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        if count < 4 {
            continueButton.isEnabled = false
        } else {
            continueButton.isEnabled = true
        }
        
        return count <= 4
    }
}
