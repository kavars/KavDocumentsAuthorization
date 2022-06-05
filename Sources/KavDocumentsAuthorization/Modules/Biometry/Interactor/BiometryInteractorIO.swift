//
//  BiometryInteractorIO.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 19.04.2022.
//

import Foundation

protocol BiometryInteractorInput: AnyObject {

    func setupBiometry(completion: @escaping (Result<Void, Error>) -> Void)
}

protocol BiometryInteractorOutput: AnyObject {
    
}
