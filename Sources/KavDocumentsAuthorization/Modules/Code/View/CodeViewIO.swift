//
//  CodeViewIO.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation

protocol CodeViewInput: AnyObject {
    func clearTextField()
    func setIncorrectCodeState()
}

protocol CodeViewOutput: AnyObject {
    func startBiometryLoginIfNeeded()
    func biometryImageName() -> String?
    func setupCode(code: String)
    func changeCode(code: String)
    func loginWithCode(code: String)
    func codeModuleWantsToClose()
}
