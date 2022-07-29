//
//  WalletConnectProxy.swift
//  WalletConnectDemo
//
//  Created by Amaury WEI on 26.06.22.
//

import Foundation
import SwiftUI
import WalletConnectSwift

protocol WalletConnectProxyDelegate {
    func failedToConnect()
    func didConnect(wallet: Session.WalletInfo)
    func didDisconnect()
}

/// Main class to interface with the WalletConnect SwiftUI package
class WalletConnectProxy: ClientDelegate {

    var client: Client!
    var session: Session!
    var delegate: WalletConnectProxyDelegate?
    
    /// Key to store session data in persistent application storage
    let sessionKey = "sessionKey"
    
    /// Main class constructor / initializer
    init() { }
    
    /// Set delegate
    func setDelegate(_ delegate: WalletConnectProxyDelegate) -> Void {
        self.delegate = delegate
    }
    
    // MARK: - Connection functions
    
    /// Open a websocket connection with the WalletConnect bridge server
    func connect() -> String {
        // Create a WalletConnect URL
        let wcUrl =  WCURL(topic: UUID().uuidString,
                           bridgeURL: URL(string: "https://bridge.walletconnect.org/")!,
                           key: try! generateRandomKey())
        
        // Fill in the required information about this decentralized app
        let clientMeta = Session.ClientMeta(name: "WalletConnectDemo",
                                            description: "A mobile application acting as a Dapp to connect to a crypto wallet using the WalletConnect SDK",
                                            icons: [],
                                            url: URL(string: "https://nfscene.com")!)
        let dAppInfo = Session.DAppInfo(peerId: UUID().uuidString, peerMeta: clientMeta)
        
        client = Client(delegate: self, dAppInfo: dAppInfo)
        // Open the web socket connection with the WalletConnect bridge server
        try! client.connect(to: wcUrl)
        
        return wcUrl.absoluteString
    }
    
    /// Try to restore the previous session with the WalletConnect bridge server
    func reconnectIfNeeded() -> Void {
        if let oldSessionObject = UserDefaults.standard.object(forKey: sessionKey) as? Data,
            let session = try? JSONDecoder().decode(Session.self, from: oldSessionObject) {
            client = Client(delegate: self, dAppInfo: session.dAppInfo)
            try? client.reconnect(to: session)
        }
    }
    
    /// Close the session with the WalletConnect bridge server
    func disconnect() -> Void {
        print("sessions count: \(client.openSessions().count)")
        for session in client.openSessions() {
            do {
                try client.disconnect(from: session)
            } catch {
                print("Failed to disconnect")
            }
        }
    }
    
    // MARK: - ClientDelegate functions
    
    func client(_ client: Client, didFailToConnect url: WCURL) -> Void {
        delegate?.failedToConnect()
    }
    
    func client(_ client: Client, didConnect url: WCURL) -> Void {
        // 1st part of the handshake, do nothing
    }
    
    func client(_ client: Client, didConnect session: Session) -> Void {
        // Store the session inside persist app data (UserDefaults here)
        self.session = session
        let sessionData = try! JSONEncoder().encode(session)
        UserDefaults.standard.set(sessionData, forKey: sessionKey)
        
        // Notify the delegate that the session is successfully open
        delegate?.didConnect(wallet: session.walletInfo!)
    }
    
    func client(_ client: Client, didDisconnect session: Session) -> Void {
        // Session is not active anymore, remove it from the persisten app data
        UserDefaults.standard.removeObject(forKey: sessionKey)
        
        // Notify the subscriber that the session has ended
        delegate?.didDisconnect()
    }
    
    func client(_ client: Client, didUpdate session: Session) -> Void {
        // Do nothing
    }
}

