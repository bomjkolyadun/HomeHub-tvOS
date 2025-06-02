//
//  ServerDiscoveryView.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//

import SwiftUI
import Network

enum FocusedField: Hashable {
    case server(String)
    case manualEntry
}

struct ServerDiscoveryView: View {
    @StateObject private var discovery = HomeHubDiscovery()
    @State private var selectedServer: DiscoveredServer?
    @State private var manualServerURL = ""
    @State private var showingManualEntry = false
    @State private var isConnecting = false
    @State private var connectedServer: DiscoveredServer?
    @State private var connectionError: String?
    @State private var showingMainView = false
    @FocusState private var focusedField: FocusedField?
    @Namespace private var namespace
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 30), count: 3)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                titleSection
                
                Spacer()
                
                serverGrid
                
                Spacer()
                
                connectionStatusSection
                
                actionButtonsSection
            }
            .padding()
            .preferredColorScheme(.dark)
        }
        .fullScreenCover(isPresented: $showingMainView) {
            if let server = connectedServer {
                MainView(server: server)
            }
        }
        .alert("Enter Server URL", isPresented: $showingManualEntry) {
            TextField("http://192.168.1.100:5000", text: $manualServerURL)
            Button("Connect") {
                connectToManualServer()
            }
            Button("Cancel", role: .cancel) { }
        }
        .onAppear {
            discovery.startDiscovery()
        }
        .onDisappear {
            discovery.stopDiscovery()
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "tv.and.hifispeaker.fill")
                .font(.system(size: 80))
                .foregroundColor(.primary)
            
            Text("HomeHub")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Select a HomeHub server to connect")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .padding(.top, 50)
    }
    
    private var serverGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 30) {
            // Discovered servers
            ForEach(discovery.discoveredServers) { server in
                discoveredServerTile(server)
            }
            
            // Manual entry tile
            manualEntryTile
        }
        .focusScope(namespace)
    }
    
    private func discoveredServerTile(_ server: DiscoveredServer) -> some View {
        Button(action: {
            connectToServer(server)
        }) {
            ServerTileView(
                server: server,
                isSelected: focusedField == .server(server.id.uuidString),
                isConnecting: isConnecting && selectedServer?.id == server.id
            )
        }
        .buttonStyle(PlainButtonStyle())
        .focused($focusedField, equals: .server(server.id.uuidString))
        .onChange(of: focusedField) { _, newValue in
            if case .server(let id) = newValue, id == server.id.uuidString {
                selectedServer = server
            }
        }
    }
    
    private var manualEntryTile: some View {
        Button(action: {
            presentManualEntry()
        }) {
            ManualServerTileView(
                isSelected: focusedField == .manualEntry,
                isConnecting: isConnecting && showingManualEntry
            )
        }
        .buttonStyle(PlainButtonStyle())
        .focused($focusedField, equals: .manualEntry)
        .onChange(of: focusedField) { _, newValue in
            if newValue == .manualEntry {
                selectedServer = nil
            }
        }
    }
    
    private var connectionStatusSection: some View {
        Group {
            if let error = connectionError {
                Text("Connection failed: \(error)")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
        }
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 40) {
            connectButton
            refreshButton
        }
        .padding(.bottom, 50)
    }
    
    private var connectButton: some View {
        Button(action: {
            if let server = selectedServer {
                connectToServer(server)
            } else if showingManualEntry {
                presentManualEntry()
            }
        }) {
            Label("Connect", systemImage: "link")
                .font(.title3)
                .padding()
        }
        .disabled(selectedServer == nil && !showingManualEntry)
        .focusable(true)
    }
    
    private var refreshButton: some View {
        Button(action: {
            discovery.startDiscovery()
            connectionError = nil
        }) {
            Label("Refresh", systemImage: "arrow.clockwise")
                .font(.title3)
                .padding()
        }
        .focusable(true)
    }
    
    private func connectToServer(_ server: DiscoveredServer) {
        isConnecting = true
        connectionError = nil
        
        Task {
            // Test connection to server
            let baseURL = "http://\(server.host):\(server.port)"
            let apiService = VideoAPIService(baseURL: baseURL)
            
            await apiService.fetchServerInfo()
            
            await MainActor.run {
                if apiService.errorMessage == nil {
                    // Connection successful
                    connectedServer = server
                    showingMainView = true
                } else {
                    // Connection failed
                    connectionError = apiService.errorMessage
                }
                isConnecting = false
            }
        }
    }
    
    private func connectToManualServer() {
        guard !manualServerURL.isEmpty else { return }
        
        // Create a temporary server from manual URL
        let components = manualServerURL.replacingOccurrences(of: "http://", with: "").split(separator: ":")
        let host = String(components.first ?? "")
        let port = Int(components.last ?? "") ?? 5000
        
        let manualServer = DiscoveredServer(name: "Manual Server", host: host, port: port)
        connectToServer(manualServer)
    }
    
    private func presentManualEntry() {
        showingManualEntry = true
    }
}

struct ServerTileView: View {
    let server: DiscoveredServer
    let isSelected: Bool
    let isConnecting: Bool
    let isTestServer: Bool
    
    init(server: DiscoveredServer, isSelected: Bool, isConnecting: Bool, isTestServer: Bool = false) {
        self.server = server
        self.isSelected = isSelected
        self.isConnecting = isConnecting
        self.isTestServer = isTestServer
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Server Icon
            Image(systemName: isTestServer ? "hammer.fill" : "server.rack")
                .font(.system(size: 50))
                .foregroundColor(isSelected ? .white : .primary)
            
            // Server Info
            VStack(spacing: 5) {
                Text(server.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                
                Text("\(server.host):\(server.port)")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .secondary)
                    .lineLimit(1)
                
                if isTestServer {
                    Text("Test Server")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.orange.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            // Connection Status
            if isConnecting {
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: isSelected ? .white : .primary))
            }
        }
        .frame(width: 200, height: 150)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? Color.blue : Color.secondary.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct ManualServerTileView: View {
    let isSelected: Bool
    let isConnecting: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Manual Entry Icon
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(isSelected ? .white : .primary)
            
            // Label
            VStack(spacing: 5) {
                Text("Manual Entry")
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text("Enter custom server")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            
            // Connection Status
            if isConnecting {
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: isSelected ? .white : .primary))
            }
        }
        .frame(width: 200, height: 150)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? Color.green : Color.secondary.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    ServerDiscoveryView()
}
