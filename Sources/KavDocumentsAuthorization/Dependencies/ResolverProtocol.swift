//
//  ResolverProtocol.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 26.03.2022.
//

import Foundation

public protocol ResolverProtocol {
    var authorizationService: AuthorizationServiceProtocol { get }
}
