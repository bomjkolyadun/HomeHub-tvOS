//
//  ServerDiscoveryView.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//

import SwiftUI
import Network

struct ServerDiscoveryView: View {
  @StateObject private var discovery = HomeHubDiscovery()
  @State private var selectedServer: DiscoveredServer?
  @State private var manualServerURL = ""
  @State private var showingManualEntry = false
  @State private var isConnecting = false
  @State private var connectionError: String?
  @FocusState private var focusedField: FocusItem?
  @Namespace private var namespace

  let onServerConnected: (DiscoveredServer) -> Void

  init(onServerConnected: @escaping (DiscoveredServer) -> Void = { _ in }) {
    self.onServerConnected = onServerConnected
  }

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
          onServerConnected(server)
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


#Preview {
  ServerDiscoveryView()
}
