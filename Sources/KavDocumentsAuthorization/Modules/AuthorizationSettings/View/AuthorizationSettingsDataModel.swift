//
//  AuthorizationSettingsDataModel.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 31.05.2022.
//

import Foundation

enum AuthorizationSettingsItem: Hashable {
    case authorization(AuthorizationSettingsDataModel)
    case changeCode(AuthorizationSettingsDataModel)
    case biometry(AuthorizationSettingsDataModel)
}

struct AuthorizationSettingsDataModel: Hashable {
    let uuid: UUID
    let isEnable: Bool
    let title: String
    let action: ((Bool, @escaping (Bool) -> Void) -> Void)?
    
    static func ==(lhs: AuthorizationSettingsDataModel, rhs: AuthorizationSettingsDataModel) -> Bool {
        lhs.uuid == rhs.uuid && lhs.isEnable == rhs.isEnable && lhs.title == rhs.title
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
        hasher.combine(isEnable)
        hasher.combine(title)
    }
}
