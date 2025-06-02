//
//  HomeHubApp.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//

import SwiftUI

@main
struct HomeHubApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var connectedServer: DiscoveredServer?
    
    var body: some View {
        if let server = connectedServer {
            MainView(server: server) {
                connectedServer = nil
            }
        } else {
            ServerDiscoveryView(onServerConnected: { server in
                connectedServer = server
            })
        }
    }
}
