//
//  CodeInteractorIO.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation

protocol CodeInteractorInput: AnyObject {
    func startBiometryLoginIfNeeded(completion: @escaping (Result<Void, Error>) -> Void)
    
    func biometryImageName() -> String?
    func setupCode(code: String)
    func changeCode(code: String)
    func loginWithCode(code: String, completion: @escaping (Bool) -> Void)
}

protocol CodeInteractorOutput: AnyObject {
    func openBiometryModule()
    func authSuccess()
}
