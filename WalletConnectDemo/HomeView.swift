//
//  HomeView.swift
//  WalletConnectDemo
//
//  Created by Amaury WEI on 26.06.22.
//

import SwiftUI

/// Main view of the WalletConnectDemoApp
struct HomeView: View {
    @ObservedObject var walletStore = WalletStore()
    
    var body: some View {
        VStack {
            Spacer()
            self.appTitle
            self.appDescription
            Spacer()
            if walletStore.wallets.count > 0 {
                self.disconnectButton
                Spacer()
                self.walletAdress
            } else {
                self.connectButton
                Spacer()
                Text("")
            }
            Spacer()
        }
    }
    
    var appTitle: some View {
        Text("WalletConnectDemo")
            .font(.title)
            .padding()
    }
    
    var appDescription: some View {
        Text("Acts as a mobile decentralized app (Dapp) to connect to a crypto wallet using the WalletConnect SDK")
            .multilineTextAlignment(.center)
            .padding()
    }
    
    var connectButton: some View {
        Button("Connect a wallet") {
            walletStore.connectNewWallet()
        }
        .padding()
    }
    
    var disconnectButton: some View {
        Button("Disconnect wallet") {
            walletStore.disconnect()
        }
        .padding()
    }
    
    var walletAdress: some View {
        Text("\(walletStore.wallets[0].address)")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(walletStore: WalletStore())
    }
}
