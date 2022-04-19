//
//  CodeModuleIO.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation

protocol CodeModuleInput: AnyObject {}

protocol CodeModuleOutput: AnyObject {
    func codeModuleWantsToAuthSuccess()
    func codeModuleWantsToClose()
    
    func codeModuleWantsToOpenBiometry()
}
