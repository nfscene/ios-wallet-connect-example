//
//  RandomKey.swift
//  WalletConnectDemo
//
//  Created by Amaury WEI on 29.06.22.
//

import Foundation

func generateRandomKey() throws -> String {
    enum RandomKeyGenerationError: Error {
        case unknown
    }
    
    var bytes = [Int8](repeating: 0, count: 32)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    if status == errSecSuccess {
        return Data(bytes: bytes, count: 32).toHexString()
    } else {
        throw RandomKeyGenerationError.unknown
    }
}
