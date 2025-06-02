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

  var body: some View {
    ServerTileBaseView(
      icon: Image(systemName: "server.rack"),
      iconColor: isSelected ? .white : .primary,
      isSelected: isSelected,
      isConnecting: isConnecting,
      backgroundColor: isSelected ? .blue : Color.secondary.opacity(0.2)
    ) {
      VStack(spacing: 5) {
        Text(server.name)
          .font(.headline)
          .foregroundColor(isSelected ? .white : .primary)
          .lineLimit(1)

        Text("\(server.host):\(server.port)")
          .font(.caption)
          .foregroundColor(isSelected ? .white : .secondary)
          .lineLimit(1)
      }
    }
  }
}

