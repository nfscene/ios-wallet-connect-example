//
//  CryptoWallet.swift
//  WalletConnectDemo
//
//  Created by Amaury WEI on 26.06.22.
//

import Foundation

/// Structure to store information about a crypto wallet
struct CryptoWallet: Identifiable {
    /// Wallet address (e.g. 0x..... as string)
    var address: String
    
    /// Unique identifier (for Identifiable protocol)
    var id: String { address }
}
