//
//  WalletStore.swift
//  WalletConnectDemo
//
//  Created by Amaury WEI on 26.06.22.
//

import Foundation
import SwiftUI
import WalletConnectSwift

/// Main ViewModel for the WalletConnectDemo application
/// Objective: unified interface to connect and store information about crypto wallets
class WalletStore: ObservableObject {
    /// List of crypto wallets connected with WalletConnect
    @Published private var model: [CryptoWallet]
    
    /// Proxy to use the WalletConnect interface
    private var walletConnectProxy: WalletConnectProxy
    
    /// Main class constructor / initializer
    init() {
        // Start with no crypto wallets connected
        self.model = []
        self.walletConnectProxy = WalletConnectProxy()
        self.walletConnectProxy.setDelegate(self)
        
        // Try to recover the previous session if possible
//        self.walletConnectProxy.reconnectIfNeeded()
    }
    
    // MARK: - Exposed data
    
    /// List of all crypto wallets currently connected
    var wallets: [CryptoWallet] { model }
    
    // MARK: - Intents
    
    /// Connect a new crypto wallet with this Dapp using the WalletConnect SDK
    func connectNewWallet() -> Void {
        let connectionUrl = walletConnectProxy.connect()

        // https://docs.walletconnect.org/mobile-linking#for-ios
        let deepLinkUrl = "wc://wc?uri=\(connectionUrl)"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let url = URL(string: deepLinkUrl), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Failed to open deepLinkUrl \(deepLinkUrl)")
            }
        }
    }
    
    /// Close the WalletConnect session
    func disconnect() -> Void {
        walletConnectProxy.disconnect()
    }
}

extension WalletStore: WalletConnectProxyDelegate {
    func failedToConnect() {
        print("failedToConnect")
    }
    
    func didConnect(wallet: Session.WalletInfo) {
        print("didConnect")
        for address in wallet.accounts {
            // Update the user interface on the UI thread
            DispatchQueue.main.async {
                self.model.append(CryptoWallet(address: address))
            }
        }
    }
    
    func didDisconnect() {
        print("didDisconnect")
        DispatchQueue.main.async {
            self.model.removeAll()
        }
    }
}
