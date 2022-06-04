//
//  KeychainService.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 01.06.2022.
//

import Foundation
import Security

public struct KeychainKey<T> {
    var type: T.Type
    var key: String
}

public protocol KeychainServiceProtocol: AnyObject {
    
    func getValue<T: Codable>(for key: KeychainKey<T>) -> T?
    func setValue<T: Codable>(_ value: T, for key: KeychainKey<T>)
}

public final class KeychainService {
    
    // MARK: Private Properties
    
    private let serviceName: String
    
    // MARK: Life Cycle
    
    public init() {
        serviceName = Bundle.main.bundleIdentifier ?? "kav.keychain.service"
    }
    
    // MARK: Private Methods
    
    private func update<T: Codable>(data: Data, for key: KeychainKey<T>) {
        let keychainQueryDictionary = setupKeychainQueryDictionary(for: key)

        let updateDictionary = [kSecValueData: data]
        
        SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary as CFDictionary)
    }
    
    private func set<T: Codable>(data: Data, for key: KeychainKey<T>) {
        var keychainQueryDictionary = setupKeychainQueryDictionary(for: key)

        keychainQueryDictionary[kSecValueData] = data
        keychainQueryDictionary[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlocked

        let status: OSStatus = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            return update(data: data, for: key)
        }
    }
    
    private func data<T: Codable>(for key: KeychainKey<T>) -> Data? {
        var keychainQueryDictionary = setupKeychainQueryDictionary(for: key)
        
        keychainQueryDictionary[kSecMatchLimit] = kSecMatchLimitOne
        keychainQueryDictionary[kSecReturnData] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)
        
        return status == noErr ? result as? Data : nil
    }
    
    private func setupKeychainQueryDictionary<T: Codable>(for key: KeychainKey<T>) -> [CFString: Any] {
        var keychainQueryDictionary: [CFString: Any] = [kSecClass: kSecClassGenericPassword]
        
        keychainQueryDictionary[kSecAttrService] = serviceName
        
        let encodedIdentifier = key.key.data(using: String.Encoding.utf8)
        keychainQueryDictionary[kSecAttrGeneric] = encodedIdentifier
        keychainQueryDictionary[kSecAttrAccount] = encodedIdentifier
        
        return keychainQueryDictionary
    }
}

// MARK: - KeychainServiceProtocol

extension KeychainService: KeychainServiceProtocol {
    
    public func getValue<T: Codable>(for key: KeychainKey<T>) -> T? {
        guard let keychainData = data(for: key) else { return nil }
        
        let object = try? JSONDecoder().decode(key.type, from: keychainData)
        
        return object
    }
    
    public func setValue<T: Codable>(_ value: T, for key: KeychainKey<T>) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        
        set(data: data, for: key)
    }
}
