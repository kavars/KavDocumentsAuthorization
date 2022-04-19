//
//  BiometryModuleIO.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation

protocol BiometryModuleInput: AnyObject {
    
}

protocol BiometryModuleOutput: AnyObject {
    func biometryModuleWantsToAuthSuccess()
    func biometryModuleWantsToClose()
}
