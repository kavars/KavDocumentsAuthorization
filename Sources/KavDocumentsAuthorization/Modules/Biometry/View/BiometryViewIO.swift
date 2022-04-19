//
//  BiometryViewIO.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation

protocol BiometryViewInput: AnyObject {
    
}

protocol BiometryViewOutput: AnyObject {
    func setupBiometry()
    func declineBiometry()
}
