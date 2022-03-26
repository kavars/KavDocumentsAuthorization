//
//  CodeViewController.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 09.03.2022.
//

import UIKit

protocol CodeModuleOutput: AnyObject {
    func codeModuleWantsToAuthSuccess()
    func codeModuleWantsToClose()
    
    func codeModuleWantsToOpenBiometry()
}

final class CodeViewController: UIViewController {
    
    enum CodeModuleState {
        case create
        case login
        case change
    }
    
    init(with state: CodeModuleState, authorizationService: AuthorizationServiceProtocol) {
        self.state = state
        self.authorizationService = authorizationService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private let state: CodeModuleState
    private let authorizationService: AuthorizationServiceProtocol
    private var isFirstCode: Bool = true
    private var code: String = ""
    
    weak var moduleOutput: CodeModuleOutput?
    
    let codeTextField: UITextField = {
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
    
    let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .tinted()
        button.setTitle("Continue", for: .normal)
        button.isEnabled = false
        return button
    }()
    
    deinit {
        moduleOutput?.codeModuleWantsToClose()
    }
    
    func setIncorrectCodeState() {
        codeTextField.layer.borderWidth = 0.8
        codeTextField.layer.borderColor = UIColor.systemRed.cgColor
    }
    
    func setNormalCodeState() {
        codeTextField.layer.borderColor = UIColor.black.cgColor
        codeTextField.layer.borderWidth = 0.5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        title = "Code"
        
        codeTextField.delegate = self
        
        view.addSubview(codeTextField)
        view.addSubview(continueButton)
        
        switch state {
        case .login:
            if authorizationService.isBiometryAvailible && authorizationService.isBiometryEnabled {
                
                var biometryImage: UIImage?
                
                switch authorizationService.biometryType {
                case .faceID:
                    biometryImage = UIImage(systemName: "faceid")
                case .touchID:
                    biometryImage = UIImage(systemName: "touchid")
                default:
                    break
                }
                
                let biometryNavBarButton = UIBarButtonItem(title: nil, image: biometryImage, primaryAction: UIAction(handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.authorizationService.setBiometry { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(()):
                            print("Success")
                            self.moduleOutput?.codeModuleWantsToAuthSuccess()
                        case .failure(let error):
                            print("Error:", error)
                            print("Use code")
                        }
                    }
                }), menu: nil)
                
                navigationItem.rightBarButtonItem = biometryNavBarButton
                
            }
        default:
            break
        }
        
        continueButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self, let text = self.codeTextField.text else { return }
            
            switch self.state {
            case .create:
                if self.isFirstCode {
                    self.code = text
                    self.codeTextField.text = nil
                    self.isFirstCode = false
                } else {
                    if self.code == text {
                        self.authorizationService.setCode(text)
                        if self.authorizationService.isBiometryAvailible {
                            self.moduleOutput?.codeModuleWantsToOpenBiometry()
                        } else {
                            self.authorizationService.setAuthorizationEnable(true)
                            self.moduleOutput?.codeModuleWantsToAuthSuccess()
                        }
                    } else {
                        self.setIncorrectCodeState()
                    }
                }
            case .login:
                if self.authorizationService.verifyCode(text) {
                    self.moduleOutput?.codeModuleWantsToAuthSuccess()
                } else {
                    self.setIncorrectCodeState()
                }
            case .change:
                if self.isFirstCode {
                    self.code = text
                    self.codeTextField.text = nil
                    self.isFirstCode = false
                } else {
                    if text == self.code {
                        self.authorizationService.setCode(text)
                        self.authorizationService.setAuthorizationEnable(true)
                        self.moduleOutput?.codeModuleWantsToAuthSuccess()
                    } else {
                        self.setIncorrectCodeState()
                    }
                }
            }
        }), for: .touchUpInside)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch state {
        case .login:
            if authorizationService.isBiometryAvailible && authorizationService.isBiometryEnabled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    self.authorizationService.setBiometry { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(()):
                            self.moduleOutput?.codeModuleWantsToAuthSuccess()
                        case .failure(let error):
                            print("Error:", error)
                        }
                    }
                }
            }
        default:
            break
        }
        
        codeTextField.becomeFirstResponder()
    }
}

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
