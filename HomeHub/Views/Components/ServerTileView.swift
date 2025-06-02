//
//  ServerTileView.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//
import SwiftUI

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
